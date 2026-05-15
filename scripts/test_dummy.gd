class_name TestDummy
extends CharacterBody2D
##
## Stationary punching bag for verifying Hero attack mechanics in the test arena.
## Logs hits, flashes red on damage, despawns at 0 HP.
##

@export var max_hp: int = 200
@export var attacks_back: bool = false
@export var attack_damage: int = 10
@export var attack_interval: float = 2.0

var current_hp: int = 200
var _attack_timer: float = 0.0
var _staggered_for: float = 0.0
var _dead: bool = false
@onready var sprite: Sprite2D = $Sprite
@onready var hp_bar: ProgressBar = $HPBar
@onready var dmg_number_scene: PackedScene = preload("res://entities/damage_number.tscn")

func _ready() -> void:
	current_hp = max_hp
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp

func _physics_process(delta: float) -> void:
	if _dead:
		return
	_staggered_for = max(0.0, _staggered_for - delta)
	if attacks_back and _staggered_for <= 0.0:
		_attack_timer += delta
		if _attack_timer >= attack_interval:
			_attack_timer = 0.0
			_swing_at_player()

func take_damage(amount: int, source: Node = null) -> void:
	if _dead:
		return
	current_hp = max(0, current_hp - amount)
	hp_bar.value = current_hp
	_flash_red()
	if dmg_number_scene != null:
		var dn: Node2D = dmg_number_scene.instantiate()
		dn.global_position = global_position + Vector2(randf_range(-8, 8), -28)
		get_tree().current_scene.add_child(dn)
		if dn.has_method("setup"):
			dn.setup(amount)
	if current_hp <= 0:
		_die()

func on_parried(stagger_duration: float) -> void:
	_staggered_for = stagger_duration
	_flash_modulate(Color(0.4, 0.6, 1.4), 0.4)

func _flash_red() -> void:
	_flash_modulate(Color(1.8, 0.4, 0.4), 0.1)

func _flash_modulate(target: Color, duration: float) -> void:
	sprite.modulate = target
	get_tree().create_timer(duration, true, false, true).timeout.connect(func() -> void:
		if is_instance_valid(sprite):
			sprite.modulate = Color.WHITE
	)

func _swing_at_player() -> void:
	# Find a hero in the scene and deal damage if close enough.
	var hero: Node = get_tree().get_first_node_in_group("hero")
	if hero == null:
		return
	if global_position.distance_to(hero.global_position) > 80.0:
		return
	if hero.has_method("take_damage"):
		var from_dir: Vector2 = (hero.global_position - global_position).normalized()
		hero.take_damage(attack_damage, self, from_dir)

func _die() -> void:
	_dead = true
	hp_bar.visible = false
	sprite.modulate = Color(0.3, 0.3, 0.3, 0.4)
	collision_layer = 0
	# Stay in scene so the player can see "killed dummy". Respawn handled by test scene.
