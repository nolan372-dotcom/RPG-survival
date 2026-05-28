class_name Enemy
extends CharacterBody2D
##
## Prototype roaming enemy for the C6 procgen biome. Idles near its camp,
## aggros the hero within a radius, chases and melee-attacks, and leashes
## back home if the hero escapes. Visuals driven by EnemySpriteController
## (goblin), facing flipped to match movement.
##

enum State { IDLE, CHASE, ATTACK, RETURN, DEAD }

@export var max_hp: int = 30
@export var move_speed: float = 55.0
@export var attack_damage: int = 8
@export var attack_interval: float = 1.5
@export var attack_range: float = 30.0
@export var aggro_radius: float = 165.0
@export var leash_radius: float = 300.0
## Each enemy rolls its own wander distance in this range — some hug the
## campfire, others roam wider.
@export var wander_radius_min: float = 18.0
@export var wander_radius_max: float = 75.0
@export var drop_kind: StringName = &"gold"
@export var drop_amount: int = 2

const LOOT_ICON_SCENE: PackedScene = preload("res://entities/loot_icon.tscn")
const ICON_WOOD: Texture2D = preload("res://art/ui/icons/wood.png")
const ICON_FOOD: Texture2D = preload("res://art/ui/icons/food.png")
const ICON_GOLD: Texture2D = preload("res://art/ui/icons/gold.png")
const HOME_ARRIVE_DIST: float = 8.0
const ATTACK_EXIT_BUFFER: float = 14.0    # hysteresis: stay in ATTACK until the hero is clearly out of range
const ATTACK_WINDUP: float = 0.45         # delay from swing start to the hit landing (matches the strike frame)
const WANDER_SPEED: float = 22.0          # slow amble while idling at camp
const WANDER_PAUSE_MIN: float = 0.8
const WANDER_PAUSE_MAX: float = 2.6
const WANDER_ARRIVE_DIST: float = 4.0

@onready var sprite: EnemySpriteController = $Sprite
@onready var hp_bar: ProgressBar = $HPBar
@onready var dmg_number_scene: PackedScene = preload("res://entities/damage_number.tscn")

var current_hp: int = 0
var state: State = State.IDLE
var home_position: Vector2 = Vector2.ZERO
var _attack_timer: float = 0.0
var _staggered_for: float = 0.0
var _wander_target: Vector2 = Vector2.ZERO
var _wander_pause: float = 0.0
var _wander_radius: float = 0.0  # rolled once per enemy in _ready
var _face_left: bool = false


func _enter_tree() -> void:
	add_to_group("enemy")


func _ready() -> void:
	current_hp = max_hp
	home_position = global_position
	_wander_radius = randf_range(wander_radius_min, wander_radius_max)
	_pick_wander_target()
	_wander_pause = randf_range(0.0, WANDER_PAUSE_MAX)  # desync campmates
	if hp_bar != null:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp


func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	_staggered_for = maxf(0.0, _staggered_for - delta)
	if _staggered_for > 0.0:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	_update_ai(delta)
	move_and_slide()
	_update_sprite()


func _update_sprite() -> void:
	# Facing follows AI intent, not velocity.x — move_and_slide zeroes velocity
	# when the goblin is blocked or in ATTACK state, which would freeze facing.
	var hero: Node = get_tree().get_first_node_in_group("hero")
	match state:
		State.CHASE, State.ATTACK:
			if hero != null and is_instance_valid(hero):
				var hx: float = (hero as Node2D).global_position.x
				if absf(hx - global_position.x) > 1.0:
					_face_left = hx < global_position.x
		State.RETURN:
			if absf(home_position.x - global_position.x) > 1.0:
				_face_left = home_position.x < global_position.x
		State.IDLE:
			if absf(velocity.x) > 1.0:
				_face_left = velocity.x < 0.0
	sprite.set_facing(_face_left)
	# Animation from state, not per-frame velocity — keeps run/idle from
	# flickering. The controller holds a one-shot (attack/hurt) to its end.
	match state:
		State.CHASE, State.RETURN:
			sprite.play_state(&"run")
		State.ATTACK:
			sprite.play_state(&"idle")
		_:
			sprite.play_state(&"run" if velocity.length() > 5.0 else &"idle")


# --- AI -----------------------------------------------------------------------

func _update_ai(delta: float) -> void:
	var hero: Node = get_tree().get_first_node_in_group("hero")
	var hero_valid: bool = hero != null and is_instance_valid(hero)
	var hero_pos: Vector2 = (hero as Node2D).global_position if hero_valid else home_position
	var dist_to_hero: float = global_position.distance_to(hero_pos) if hero_valid else INF
	var dist_from_home: float = global_position.distance_to(home_position)

	match state:
		State.IDLE:
			if hero_valid and dist_to_hero <= aggro_radius and _has_los_to(hero as Node2D):
				state = State.CHASE
			else:
				_update_wander(delta)
		State.CHASE:
			# Leash on distance-to-hero so it shares a scale with the re-aggro
			# check (aggro_radius) — that gap is the hysteresis that stops a
			# CHASE/RETURN thrash at the boundary.
			if not hero_valid or dist_to_hero > leash_radius:
				state = State.RETURN
			elif dist_to_hero <= attack_range:
				state = State.ATTACK
				_attack_timer = attack_interval * 0.5  # short wind-up before first swing
			else:
				velocity = (hero_pos - global_position).normalized() * move_speed
		State.ATTACK:
			velocity = Vector2.ZERO
			if not hero_valid or dist_to_hero > leash_radius:
				state = State.RETURN
			elif dist_to_hero > attack_range + ATTACK_EXIT_BUFFER:
				state = State.CHASE
			else:
				_attack_timer += delta
				if _attack_timer >= attack_interval:
					_attack_timer = 0.0
					_start_swing(hero as Node2D)
		State.RETURN:
			if hero_valid and dist_to_hero <= aggro_radius and _has_los_to(hero as Node2D):
				state = State.CHASE
			elif dist_from_home <= HOME_ARRIVE_DIST:
				state = State.IDLE
			else:
				velocity = (home_position - global_position).normalized() * move_speed
		State.DEAD:
			velocity = Vector2.ZERO


func _start_swing(hero: Node2D) -> void:
	if hero == null or not is_instance_valid(hero):
		return
	sprite.play_state(&"attack")  # facing is handled each frame by _update_sprite
	# The hit lands partway through the swing — not on frame 0 — so the damage
	# matches the moment the goblin's weapon visually connects.
	get_tree().create_timer(ATTACK_WINDUP).timeout.connect(_land_hit)


func _land_hit() -> void:
	if state == State.DEAD:
		return
	var hero: Node = get_tree().get_first_node_in_group("hero")
	if hero == null or not is_instance_valid(hero):
		return
	var hero_2d: Node2D = hero as Node2D
	# If the hero slipped out of range during the wind-up, the swing whiffs.
	if global_position.distance_to(hero_2d.global_position) > attack_range + 12.0:
		return
	if hero.has_method("take_damage"):
		var from_dir: Vector2 = (hero_2d.global_position - global_position).normalized()
		hero.take_damage(attack_damage, self, from_dir)


func _update_wander(delta: float) -> void:
	# Gentle amble around the camp — walk to a nearby point, pause, repeat.
	if _wander_pause > 0.0:
		_wander_pause -= delta
		velocity = Vector2.ZERO
		return
	if global_position.distance_to(_wander_target) <= WANDER_ARRIVE_DIST:
		_wander_pause = randf_range(WANDER_PAUSE_MIN, WANDER_PAUSE_MAX)
		_pick_wander_target()
		velocity = Vector2.ZERO
		return
	velocity = (_wander_target - global_position).normalized() * WANDER_SPEED


func _pick_wander_target() -> void:
	var angle: float = randf() * TAU
	var radius: float = randf() * _wander_radius
	_wander_target = home_position + Vector2(cos(angle), sin(angle)) * radius


func _has_los_to(target: Node2D) -> bool:
	# Clear line of sight if the ray to the hero hits nothing, or hits the
	# hero before any world obstacle. Trees / rocks (layer 1) break sight;
	# other enemies (layer 2) and the campfire do not.
	if target == null:
		return false
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	if space == null:
		return true
	var query := PhysicsRayQueryParameters2D.create(global_position, target.global_position)
	query.collision_mask = 1
	query.exclude = [self]
	var hit: Dictionary = space.intersect_ray(query)
	if hit.is_empty():
		return true
	return hit.get("collider") == target


# --- Combat hooks (called by the hero) ----------------------------------------

func take_damage(amount: int, _source: Node = null) -> void:
	if state == State.DEAD:
		return
	current_hp = maxi(0, current_hp - amount)
	if hp_bar != null:
		hp_bar.value = current_hp
	if dmg_number_scene != null:
		var dn: Node2D = dmg_number_scene.instantiate()
		dn.global_position = global_position + Vector2(randf_range(-8, 8), -28)
		get_tree().current_scene.add_child(dn)
		if dn.has_method("setup"):
			dn.setup(amount)
	if current_hp <= 0:
		_die()
		return
	_flash(Color(1.8, 0.4, 0.4), 0.1)
	sprite.play_state(&"hurt")
	if state == State.IDLE:
		state = State.CHASE  # getting hit aggros it


func on_parried(stagger_duration: float) -> void:
	if state == State.DEAD:
		return
	_staggered_for = stagger_duration
	_flash(Color(0.4, 0.6, 1.4), 0.4)
	sprite.play_state(&"hurt")


# --- Death --------------------------------------------------------------------

func _die() -> void:
	state = State.DEAD
	collision_layer = 0
	collision_mask = 0
	if hp_bar != null:
		hp_bar.visible = false
	sprite.play_state(&"die")
	_drop_loot()
	# Let the death animation play out, then fade and free.
	var t := create_tween()
	t.tween_interval(0.9)
	t.tween_property(self, "modulate:a", 0.0, 0.3)
	t.tween_callback(queue_free)


func _drop_loot() -> void:
	if drop_amount <= 0:
		return
	ResourceState.add(drop_kind, drop_amount)
	var texture: Texture2D = _icon_for_kind(drop_kind)
	if texture == null:
		return
	var base_pos: Vector2 = global_position + Vector2(0, -10)
	for i in range(drop_amount):
		var x_offset: float = (float(i) - (drop_amount - 1) * 0.5) * 5.0
		var icon: Node2D = LOOT_ICON_SCENE.instantiate()
		icon.global_position = base_pos + Vector2(x_offset, 0)
		get_tree().current_scene.add_child(icon)
		if icon.has_method("setup"):
			icon.setup(texture)


func _icon_for_kind(kind: StringName) -> Texture2D:
	match kind:
		&"wood": return ICON_WOOD
		&"food": return ICON_FOOD
		&"gold": return ICON_GOLD
	return null


# --- Visual feedback ----------------------------------------------------------

func _flash(target: Color, duration: float) -> void:
	if sprite == null:
		return
	sprite.modulate = target
	get_tree().create_timer(duration, true, false, true).timeout.connect(func() -> void:
		if is_instance_valid(sprite):
			sprite.modulate = Color.WHITE
	)
