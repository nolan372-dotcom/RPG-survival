extends Node2D
##
## C6 Grasslands prototype scene. Chunk 2: hand-placed trees replaced by
## seeded procgen via BiomeZones. Chunk 3 adds harvest interaction.
## Chunk 4 adds enemy camps. Chunk 5 adds debug overlay + docs.
##
## Scene navigation:
##   F9  -> test_arena (combat)
##   F10 -> castle_plot (build mode)
##   F11 -> grasslands (this scene)
##
## Procgen:
##   G   -> regenerate with a new random seed
##   V   -> toggle BiomeZone debug rectangles
##

@onready var hero: Hero = $Hero
@onready var trees_root: Node2D = $Trees
@onready var zones_root: Node2D = $BiomeZones
@onready var generator: BiomeGenerator = $BiomeGenerator
@onready var seed_label: Label = $UI/SeedLabel

var current_seed: int = 0


func _ready() -> void:
	hero.add_to_group("hero")
	add_to_group("grasslands")
	# Exploration zoom — wider view than combat (2x) but tighter than build (0.6x).
	if hero.has_node("Camera2D"):
		(hero.get_node("Camera2D") as Camera2D).zoom = Vector2(1.5, 1.5)
	_regenerate(_pick_seed())


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F9:
				get_tree().change_scene_to_file("res://scenes/test_arena.tscn")
			KEY_F10:
				get_tree().change_scene_to_file("res://scenes/castle_plot.tscn")
			KEY_G:
				_regenerate(_pick_seed())
			KEY_V:
				_toggle_zone_debug()


# --- Procgen plumbing --------------------------------------------------------

func _pick_seed() -> int:
	# Use the system RNG seeded by time so different launches differ;
	# log the value so the user can reproduce a layout if they want.
	return randi()


func _regenerate(new_seed: int) -> void:
	current_seed = new_seed
	for child in trees_root.get_children():
		child.queue_free()
	var zones: Array = zones_root.get_children()
	var clearance: Array[Vector2] = [hero.global_position]
	var count: int = generator.populate(zones, trees_root, current_seed, clearance)
	_update_seed_label(count)


func _update_seed_label(tree_count: int) -> void:
	if seed_label != null:
		seed_label.text = "seed: %d    trees: %d    (G: regenerate, V: zones)" % [current_seed, tree_count]


func _toggle_zone_debug() -> void:
	for zone_node in zones_root.get_children():
		if zone_node is BiomeZone:
			(zone_node as BiomeZone).debug_draw = not (zone_node as BiomeZone).debug_draw
			(zone_node as BiomeZone).queue_redraw()
