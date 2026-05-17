class_name Hero
extends CharacterBody2D
##
## Player hero. Knight is the only class for now, but the script is generic enough
## to host all three by selecting different HeroData / CharacterAnimationSet.
##
## Combat philosophy (Knight):
##   - "Heavy and certain" — committed attacks, parry rewards timing.
##   - Mouse aim drives sprite facing + attack direction.
##   - Block: 8-frame parry window, then sustained block stance.
##   - Stalwart passive: -15% incoming damage when HP < 50%.
##

enum State { IDLE, WALK, ATTACK, BLOCK_START, BLOCK_HOLD, HURT, DEAD, HARVEST }

signal hp_changed(current: int, max_hp: int)
signal died

@export var hero_data: HeroData

# --- Tuning -------------------------------------------------------------------
const ATTACK_HITBOX_DURATION: float = 0.18  # how long the hitbox is live during an attack
const ATTACK_HITBOX_DELAY: float = 0.10     # delay before the hitbox activates (windup)
const ATTACK_TOTAL_DURATION: float = 0.45   # total attack lockout duration
const PARRY_WINDOW: float = 0.20            # 12 frames at 60fps — also the BLOCK_START duration
const BLOCK_START_DURATION: float = PARRY_WINDOW
const BLOCK_COOLDOWN: float = 0.35          # after exiting block, can't block again for this long
const HURT_LOCKOUT: float = 0.20
const HIT_STOP_DURATION: float = 0.05
const STALWART_HP_THRESHOLD: float = 0.5
const STALWART_DAMAGE_REDUCTION: float = 0.15
const HARVEST_TICK_INTERVAL: float = 0.5  # chop-tick visual feedback cadence

# --- State --------------------------------------------------------------------
var current_hp: int = 100
var max_hp: int = 100
var base_damage: int = 12
var move_speed: float = 110.0
var state: State = State.IDLE
var _state_timer: float = 0.0
var _attack_hitbox_armed: bool = false
var _parry_window_remaining: float = 0.0
var _block_cooldown_remaining: float = 0.0
var _hit_targets_this_swing: Array[Node] = []
# Gating flag — set true while UI modes (e.g. building placement) consume
# attack/ability inputs. The hero still moves and faces the mouse.
var input_locked: bool = false

# Harvest state.
var _harvest_target: Node = null
var _harvest_total_time: float = 0.0
var _next_harvest_tick_at: float = 0.0
var _harvest_target_duration: float = 3.0

# --- Node refs ----------------------------------------------------------------
@onready var sprite: HeroSpriteController = $Sprite
@onready var attack_pivot: Node2D = $AttackPivot
@onready var attack_hitbox: Area2D = $AttackPivot/AttackHitbox
@onready var attack_collision: CollisionShape2D = $AttackPivot/AttackHitbox/CollisionShape2D
@onready var hurt_box: Area2D = $HurtBox
@onready var stalwart_aura: Sprite2D = $StalwartAura
@onready var camera: Camera2D = $Camera2D
@onready var dmg_number_scene: PackedScene = preload("res://entities/damage_number.tscn")

# --- Lifecycle ----------------------------------------------------------------

func _ready() -> void:
	if hero_data == null:
		hero_data = ContentRegistry.get_hero(&"knight")
	if hero_data == null:
		push_error("Hero: no HeroData available; ContentRegistry has no &\"knight\" entry")
		return
	max_hp = hero_data.base_hp
	current_hp = max_hp
	base_damage = hero_data.base_damage
	move_speed = hero_data.move_speed
	sprite.animation_set = hero_data.animation_set
	sprite.rebuild()
	attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)
	attack_hitbox.monitoring = false
	attack_collision.disabled = true
	stalwart_aura.visible = false
	hp_changed.emit(current_hp, max_hp)

func _physics_process(delta: float) -> void:
	_state_timer += delta
	_parry_window_remaining = max(0.0, _parry_window_remaining - delta)
	_block_cooldown_remaining = max(0.0, _block_cooldown_remaining - delta)
	_update_facing()

	match state:
		State.IDLE, State.WALK:
			_handle_free_movement(delta)
			_check_action_inputs()
		State.ATTACK:
			velocity = velocity.lerp(Vector2.ZERO, 10.0 * delta)
			move_and_slide()
			if _attack_hitbox_armed and _state_timer >= ATTACK_HITBOX_DELAY:
				_enable_attack_hitbox()
			if _state_timer >= ATTACK_HITBOX_DELAY + ATTACK_HITBOX_DURATION:
				_disable_attack_hitbox()
			if _state_timer >= ATTACK_TOTAL_DURATION:
				_enter_idle_or_walk()
		State.BLOCK_START:
			velocity = velocity.lerp(Vector2.ZERO, 12.0 * delta)
			move_and_slide()
			if not Input.is_action_pressed("ability"):
				_exit_block_to_idle()
			elif _state_timer >= BLOCK_START_DURATION:
				_enter_block_hold()
		State.BLOCK_HOLD:
			velocity = velocity.lerp(Vector2.ZERO, 18.0 * delta)
			move_and_slide()
			if not Input.is_action_pressed("ability"):
				_exit_block_to_idle()
			elif Input.is_action_just_pressed("attack"):
				_exit_block_to_idle(false)  # release block on the way to swing
				_enter_attack()  # break out of block to attack
		State.HURT:
			velocity = velocity.lerp(Vector2.ZERO, 8.0 * delta)
			move_and_slide()
			if _state_timer >= HURT_LOCKOUT:
				_enter_idle_or_walk()
		State.HARVEST:
			velocity = velocity.lerp(Vector2.ZERO, 20.0 * delta)
			move_and_slide()
			_update_harvest(delta)
		State.DEAD:
			velocity = Vector2.ZERO

	_update_stalwart_aura()

# --- Movement / input ---------------------------------------------------------

func _handle_free_movement(delta: float) -> void:
	var input_vec := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	if input_vec.length_squared() > 1.0:
		input_vec = input_vec.normalized()
	var target_velocity := input_vec * move_speed
	velocity = velocity.lerp(target_velocity, 18.0 * delta)
	move_and_slide()
	if input_vec.length_squared() > 0.01:
		_set_state(State.WALK)
	else:
		_set_state(State.IDLE)

func _check_action_inputs() -> void:
	if input_locked:
		return
	if Input.is_action_just_pressed("attack"):
		_enter_attack()
	elif Input.is_action_just_pressed("ability") and _block_cooldown_remaining <= 0.0:
		_enter_block_start()
	elif Input.is_action_just_pressed("interact"):
		_try_start_harvest()

func _update_facing() -> void:
	# Sprite facing always follows the mouse cursor, regardless of state.
	var aim_dir: Vector2 = get_global_mouse_position() - global_position
	sprite.set_facing_from_aim(aim_dir)
	# Attack pivot follows the same direction so the hitbox rotates with aim.
	attack_pivot.rotation = aim_dir.angle()

# --- State transitions --------------------------------------------------------

func _set_state(s: State) -> void:
	if state == s:
		return
	state = s
	_state_timer = 0.0
	_play_state_anim()

func _enter_idle_or_walk() -> void:
	_attack_hitbox_armed = false
	_disable_attack_hitbox()
	# Let _handle_free_movement reclassify next physics tick. Default to idle.
	_set_state(State.IDLE)

func _enter_attack() -> void:
	_set_state(State.ATTACK)
	_attack_hitbox_armed = true
	_hit_targets_this_swing.clear()

func _enter_block_start() -> void:
	_set_state(State.BLOCK_START)
	_parry_window_remaining = PARRY_WINDOW

func _enter_block_hold() -> void:
	_set_state(State.BLOCK_HOLD)

func _exit_block_to_idle(transition_state: bool = true) -> void:
	_block_cooldown_remaining = BLOCK_COOLDOWN
	if transition_state:
		_enter_idle_or_walk()

func _enter_hurt() -> void:
	_set_state(State.HURT)
	_flash_modulate(Color(1.6, 0.4, 0.4), 0.12)

# --- Harvest ----------------------------------------------------------------

func _try_start_harvest() -> void:
	var target: Node = _find_nearest_harvestable()
	if target == null:
		return
	_harvest_target = target
	_harvest_total_time = 0.0
	_next_harvest_tick_at = 0.5
	# Harvest duration is per-target (a berry forage is quicker than a tree chop).
	_harvest_target_duration = TreeNode.HARVEST_TIME
	if "HARVEST_TIME" in target:
		_harvest_target_duration = target.HARVEST_TIME
	_set_state(State.HARVEST)
	# Face the target while harvesting so the swing animation aims at it.
	var dir: Vector2 = target.global_position - global_position
	sprite.set_facing_from_aim(dir)

func _find_nearest_harvestable() -> Node:
	var best: Node = null
	var best_dist: float = INF
	for node in get_tree().get_nodes_in_group("harvestable"):
		if not (node is Node2D):
			continue
		if node.has_method("is_harvestable") and not node.is_harvestable():
			continue
		var radius: float = 56.0
		if "INTERACTION_RADIUS" in node:
			radius = node.INTERACTION_RADIUS
		var d: float = global_position.distance_to((node as Node2D).global_position)
		if d <= radius and d < best_dist:
			best = node
			best_dist = d
	return best

func _update_harvest(delta: float) -> void:
	# Cancel if hero released E, target died, or hero starts another action.
	if not Input.is_action_pressed("interact"):
		_cancel_harvest()
		return
	if _harvest_target == null or not is_instance_valid(_harvest_target):
		_cancel_harvest()
		return
	if _harvest_target.has_method("is_harvestable") and not _harvest_target.is_harvestable():
		_cancel_harvest()
		return
	# Visual: re-play melee swing as a chop loop. play_state() is safe to call
	# every frame — its internal guard restarts the animation when it finishes
	# (the melee animation has loop=false, so without this it'd freeze on the
	# final frame after one swing and the knight would just stand still for
	# the rest of the 3s).
	sprite.play_state(&"melee")
	_harvest_total_time += delta
	# Per-tick visual: shake the tree.
	if _harvest_total_time >= _next_harvest_tick_at:
		_next_harvest_tick_at += HARVEST_TICK_INTERVAL
		if _harvest_target.has_method("tree_shake"):
			_harvest_target.tree_shake()
	# Done?
	if _harvest_total_time >= _harvest_target_duration:
		_complete_harvest()

func _complete_harvest() -> void:
	var target: Node = _harvest_target
	_harvest_target = null
	var amount: int = 0
	var kind: StringName = &"wood"
	if target != null and target.has_method("complete_harvest"):
		amount = target.complete_harvest()
		if "resource_kind" in target:
			kind = target.resource_kind
	if amount > 0:
		ResourceState.add(kind, amount)
		_spawn_resource_popup(target as Node2D, amount, kind)
	_enter_idle_or_walk()

func _cancel_harvest() -> void:
	_harvest_target = null
	_enter_idle_or_walk()

func _spawn_resource_popup(at_node: Node2D, amount: int, kind: StringName) -> void:
	if at_node == null:
		return
	var node: Node2D = dmg_number_scene.instantiate()
	# Anchor the popup just above the stump (not above the tree's StaticBody
	# origin, which is well above the stump). Float-up animation will carry
	# it up from there, drawing the eye to where the harvest landed.
	node.global_position = at_node.global_position + Vector2(0, -8)
	get_tree().current_scene.add_child(node)
	if node.has_method("setup"):
		node.setup(amount)
	# The damage_number defaults to a cream tint; tint for resource type so it
	# reads as a gain not a hit.
	await get_tree().process_frame
	if is_instance_valid(node) and node.has_node("Label"):
		var label: Label = node.get_node("Label")
		match kind:
			&"wood":  label.modulate = Color(0.85, 0.65, 0.35)
			&"food":  label.modulate = Color(0.85, 0.4, 0.4)
			&"gold":  label.modulate = Color(1.0, 0.9, 0.35)
			_:        label.modulate = Color(0.9, 0.9, 0.9)
		label.text = "+%d %s" % [amount, String(kind)]

func _enter_dead() -> void:
	_set_state(State.DEAD)
	_disable_attack_hitbox()
	hurt_box.monitoring = false
	died.emit()

func _play_state_anim() -> void:
	match state:
		State.IDLE: sprite.play_state(&"idle")
		State.WALK: sprite.play_state(&"walk")
		State.ATTACK: sprite.play_state(&"melee")
		State.BLOCK_START: sprite.play_state(&"block_start")
		State.BLOCK_HOLD: sprite.play_state(&"block_mid")
		State.HURT: sprite.play_state(&"hurt")
		State.HARVEST: sprite.play_state(&"melee")  # reuse melee swing as chop loop
		State.DEAD: sprite.play_state(&"die")

# --- Attack hitbox ------------------------------------------------------------

func _enable_attack_hitbox() -> void:
	_attack_hitbox_armed = false
	attack_collision.disabled = false
	attack_hitbox.monitoring = true

func _disable_attack_hitbox() -> void:
	attack_collision.disabled = true
	attack_hitbox.monitoring = false

func _on_attack_hitbox_body_entered(body: Node) -> void:
	if body == self or body in _hit_targets_this_swing:
		return
	if not body.has_method("take_damage"):
		return
	_hit_targets_this_swing.append(body)
	body.take_damage(base_damage, self)
	_apply_hit_stop()

func _apply_hit_stop() -> void:
	# Brief engine time slowdown that decays after the hit-stop window.
	Engine.time_scale = 0.05
	get_tree().create_timer(HIT_STOP_DURATION, true, false, true).timeout.connect(func() -> void:
		Engine.time_scale = 1.0
	)

# --- Damage taking ------------------------------------------------------------

func take_damage(amount: int, _source: Node = null, from_dir: Vector2 = Vector2.ZERO) -> void:
	if state == State.DEAD:
		return
	var effective: float = float(amount)
	if state == State.BLOCK_START and _parry_window_remaining > 0.0:
		_parry(_source)
		return
	if state == State.BLOCK_START or state == State.BLOCK_HOLD:
		effective *= _block_multiplier(from_dir)
	if _stalwart_active():
		effective *= (1.0 - STALWART_DAMAGE_REDUCTION)
	var final_amount: int = max(0, int(round(effective)))
	current_hp = max(0, current_hp - final_amount)
	hp_changed.emit(current_hp, max_hp)
	_spawn_damage_number(final_amount)
	if current_hp <= 0:
		_enter_dead()
	else:
		_enter_hurt()

func _block_multiplier(from_dir: Vector2) -> float:
	# Block: 0% from front, 50% from sides, 100% from back.
	if from_dir.length_squared() < 0.0001:
		return 0.0  # treat ambient damage as blocked from front
	var aim_dir: Vector2 = (get_global_mouse_position() - global_position).normalized()
	var dot: float = aim_dir.dot(-from_dir.normalized())  # +1 = blocked head-on, -1 = back-hit
	if dot > 0.5:
		return 0.0
	elif dot > -0.5:
		return 0.5
	return 1.0

func _parry(attacker: Node) -> void:
	# Slow-mo + brief flash. Stagger handled by attacker if it supports it.
	Engine.time_scale = 0.3
	get_tree().create_timer(0.3, true, false, true).timeout.connect(func() -> void:
		Engine.time_scale = 1.0
	)
	_flash_modulate(Color(2.0, 2.0, 1.0), 0.25)
	if attacker != null and attacker.has_method("on_parried"):
		attacker.on_parried(1.5)

func _flash_modulate(target: Color, duration: float) -> void:
	sprite.modulate = target
	get_tree().create_timer(duration, true, false, true).timeout.connect(func() -> void:
		if is_instance_valid(sprite):
			sprite.modulate = Color.WHITE
	)

func _spawn_damage_number(value: int) -> void:
	var node: Node2D = dmg_number_scene.instantiate()
	node.global_position = global_position + Vector2(0, -32)
	get_tree().current_scene.add_child(node)
	if node.has_method("setup"):
		node.setup(value)

# --- Stalwart -----------------------------------------------------------------

func _stalwart_active() -> bool:
	if hero_data == null or hero_data.passive_id != &"stalwart":
		return false
	return float(current_hp) / float(max_hp) < STALWART_HP_THRESHOLD

func _update_stalwart_aura() -> void:
	stalwart_aura.visible = _stalwart_active() and state != State.DEAD

# --- Camera -------------------------------------------------------------------
# Camera tracks the hero strictly — no smoothing, no mouse-aim lookahead.
# Re-enable position_smoothing_enabled in hero.tscn if you want drift back.

# --- Public accessors (for debug / UI) ---------------------------------------

func current_facing_name() -> StringName:
	return sprite.direction_name()

func current_aim_dir() -> Vector2:
	return get_global_mouse_position() - global_position

func current_state_name() -> StringName:
	return State.keys()[state].to_lower()

func block_cooldown_remaining() -> float:
	return _block_cooldown_remaining

func block_cooldown_fraction() -> float:
	return clamp(_block_cooldown_remaining / BLOCK_COOLDOWN, 0.0, 1.0)
