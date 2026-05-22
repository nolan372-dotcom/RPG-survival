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

## World is the y-sorted parent of both Hero and all spawned trees, so they
## render in the correct z-order based on their y position.
@onready var world: Node2D = $World
@onready var hero: Hero = $World/Hero
@onready var zones_root: Node2D = $BiomeZones
@onready var generator: BiomeGenerator = $BiomeGenerator
@onready var seed_label: Label = $UI/SeedLabel
@onready var resource_hud: Label = $UI/ResourceHUD
@onready var death_screen: ColorRect = $UI/DeathScreen

var current_seed: int = 0
var _hero_dead: bool = false


func _ready() -> void:
	hero.add_to_group("hero")
	add_to_group("grasslands")
	hero.died.connect(_on_hero_died)
	# Exploration uses the same 2x zoom as combat — pixel art needs a
	# whole-number zoom or it shimmers/blurs while the camera moves.
	if hero.has_node("Camera2D"):
		(hero.get_node("Camera2D") as Camera2D).zoom = Vector2(2, 2)
	_regenerate(_pick_seed())
	ResourceState.resources_changed.connect(_on_resources_changed)
	_on_resources_changed(ResourceState.wood, ResourceState.food, ResourceState.gold)


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
			KEY_R:
				if _hero_dead:
					get_tree().reload_current_scene()


# --- Death -------------------------------------------------------------------

func _on_hero_died() -> void:
	_hero_dead = true
	# Let the death animation read for a beat before the overlay drops in.
	await get_tree().create_timer(0.7).timeout
	if death_screen != null:
		death_screen.visible = true


# --- Procgen plumbing --------------------------------------------------------

func _pick_seed() -> int:
	# Use the system RNG seeded by time so different launches differ;
	# log the value so the user can reproduce a layout if they want.
	return randi()


func _regenerate(new_seed: int) -> void:
	current_seed = new_seed
	# Clear all spawned trees in World, but leave Hero (and any future
	# persistent entities) alone.
	for child in world.get_children():
		if child == hero:
			continue
		child.queue_free()
	var zones: Array = zones_root.get_children()
	var clearance: Array[Vector2] = [hero.global_position]
	var count: int = generator.populate(zones, world, current_seed, clearance)
	_update_seed_label(count)


func _update_seed_label(entity_count: int) -> void:
	if seed_label != null:
		seed_label.text = "seed: %d    entities: %d    (G: regenerate, V: zones)" % [current_seed, entity_count]


func _toggle_zone_debug() -> void:
	for zone_node in zones_root.get_children():
		if zone_node is BiomeZone:
			(zone_node as BiomeZone).debug_draw = not (zone_node as BiomeZone).debug_draw
			(zone_node as BiomeZone).queue_redraw()


# --- Resource HUD ------------------------------------------------------------

func _on_resources_changed(wood: int, food: int, gold: int) -> void:
	if resource_hud != null:
		resource_hud.text = "Wood:  %d\nFood:  %d\nGold:  %d" % [wood, food, gold]
