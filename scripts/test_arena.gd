extends Node2D
##
## Temporary playtest arena for C5. Hosts a Hero plus a few TestDummies.
## Press R to respawn dead dummies. Replaced by real biome scenes in Phase 2.
##

@onready var hero: Hero = $Hero
@onready var dummy_container: Node2D = $Dummies
@onready var instructions: Label = $UI/Instructions
@onready var hp_label: Label = $UI/HPLabel
@onready var debug_label: Label = $UI/DebugLabel

const DUMMY_SCENE: PackedScene = preload("res://entities/test_dummy.tscn")

const SPAWN_LAYOUT: Array = [
	{"pos": Vector2(160, 0),  "attacks_back": false, "interval": 2.0},
	{"pos": Vector2(-160, 0), "attacks_back": false, "interval": 2.0},
	{"pos": Vector2(0, -160), "attacks_back": true,  "interval": 1.6},  # the aggressive one
]

func _ready() -> void:
	hero.add_to_group("hero")
	hero.hp_changed.connect(_on_hp_changed)
	_on_hp_changed(hero.current_hp, hero.max_hp)
	_spawn_dummies()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		_clear_dummies()
		_spawn_dummies()
		hero.current_hp = hero.max_hp
		hero.hp_changed.emit(hero.current_hp, hero.max_hp)

func _spawn_dummies() -> void:
	for spec in SPAWN_LAYOUT:
		var d: Node2D = DUMMY_SCENE.instantiate()
		d.position = spec.pos
		d.attacks_back = spec.attacks_back
		d.attack_interval = spec.interval
		dummy_container.add_child(d)

func _clear_dummies() -> void:
	for child in dummy_container.get_children():
		child.queue_free()

func _on_hp_changed(current: int, max_hp: int) -> void:
	if hp_label != null:
		hp_label.text = "HP: %d / %d" % [current, max_hp]

func _process(_delta: float) -> void:
	if debug_label == null or hero == null or not is_instance_valid(hero):
		return
	var aim: Vector2 = hero.current_aim_dir()
	debug_label.text = "facing: %s    state: %s    aim: (%.0f, %.0f)" % [
		String(hero.current_facing_name()),
		String(hero.current_state_name()),
		aim.x, aim.y
	]
