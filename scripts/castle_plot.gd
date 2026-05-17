extends Node2D
##
## C8 prototype scene. 30x30 buildable plot with a pre-placed castle and
## Waypoint Shrine. Three enemy spawn markers at the northern edge feed the
## threat-line preview during placement. Hero is in-scene so you can walk
## around between placements.
##

const BUILDING_SCENE: PackedScene = preload("res://entities/building.tscn")
const HERO_GREYED_MODULATE: Color = Color(0.55, 0.55, 0.6, 0.55)

@onready var grid: GridManager = $Grid
@onready var build_placement: BuildPlacement = $Grid/BuildPlacement
@onready var threat_line: ThreatLinePreview = $Grid/ThreatLinePreview
@onready var build_menu: BuildMenu = $UI/BuildMenu
@onready var resource_label: Label = $UI/ResourceLabel
@onready var hero: Hero = $Hero
@onready var hero_camera: Camera2D = $Hero/Camera2D
@onready var build_camera: Camera2D = $BuildCamera
@onready var castle_pre: StaticBody2D = $Grid/PrePlaced/Castle
@onready var shrine_pre: Node2D = $Grid/PrePlaced/Shrine
@onready var spawn_markers: Node2D = $Grid/SpawnMarkers
@onready var buildings_root: Node2D = $Grid/Buildings

var _build_mode: bool = false


func _ready() -> void:
	add_to_group("castle_plot")
	hero.add_to_group("hero")

	# Castle-plot uses a wider view than combat — drop the hero's camera zoom
	# from 2× so you can see more of the 30×30 grid at once.
	if hero.has_node("Camera2D"):
		var cam: Camera2D = hero.get_node("Camera2D")
		cam.zoom = Vector2(1, 1)

	# Wire cross-references that .tscn can't easily express.
	build_placement.grid = grid
	build_placement.threat_line = threat_line
	threat_line.grid = grid

	hero.global_position = grid.cell_to_world(Vector2i(15, 22)) + Vector2(GridManager.CELL_SIZE * 0.5, GridManager.CELL_SIZE * 0.5)

	# Reserve the castle (4x4 centered) and shrine (1x1 east of castle).
	# These never get destroyed, so reserve_forced bypasses overlap checks.
	grid.reserve_forced(castle_pre, Vector2i(13, 13), Vector2i(4, 4))
	grid.reserve_forced(shrine_pre, Vector2i(17, 14), Vector2i(1, 1))

	# Wire spawn marker world positions into the threat line preview.
	var spawn_world: Array[Vector2] = []
	for child in spawn_markers.get_children():
		if child is Node2D:
			spawn_world.append((child as Node2D).global_position)
	threat_line.spawn_points_world = spawn_world
	threat_line.castle_world_position = grid.footprint_center_world(Vector2i(13, 13), Vector2i(4, 4))

	build_menu.build_button_pressed.connect(_on_build_button_pressed)
	build_placement.placement_confirmed.connect(_on_placement_confirmed)
	ResourceState.resources_changed.connect(_on_resources_changed)
	_on_resources_changed(ResourceState.wood, ResourceState.food, ResourceState.gold)

	# Start in explore mode: hero camera live, build UI hidden, grid lines off.
	hero_camera.make_current()
	build_menu.visible = false
	grid.set_lines_visible(false)
	# Park the build camera over the castle's center so it doesn't drift.
	build_camera.global_position = grid.footprint_center_world(Vector2i(13, 13), Vector2i(4, 4))


func _unhandled_input(event: InputEvent) -> void:
	# B — toggle build mode (action is bound in project.godot as open_build_menu).
	if event.is_action_pressed("open_build_menu"):
		_toggle_build_mode()
		get_viewport().set_input_as_handled()
		return
	# F8 — quick scene swap to combat test arena.
	if event is InputEventKey and event.pressed and event.keycode == KEY_F8:
		get_tree().change_scene_to_file("res://scenes/test_arena.tscn")


# --- Build mode toggle -------------------------------------------------------

func _toggle_build_mode() -> void:
	if _build_mode:
		_exit_build_mode()
	else:
		_enter_build_mode()

func _enter_build_mode() -> void:
	_build_mode = true
	hero.input_locked = true
	hero.modulate = HERO_GREYED_MODULATE
	hero.velocity = Vector2.ZERO
	build_camera.make_current()
	grid.set_lines_visible(true)
	build_menu.visible = true

func _exit_build_mode() -> void:
	_build_mode = false
	if build_placement.is_active():
		build_placement.cancel()
	hero.input_locked = false
	hero.modulate = Color.WHITE
	hero_camera.make_current()
	grid.set_lines_visible(false)
	build_menu.visible = false


func _on_build_button_pressed(data: BuildingData) -> void:
	build_placement.begin(data)


func _on_placement_confirmed(data: BuildingData, origin_cell: Vector2i, footprint: Vector2i) -> void:
	var b: Building = BUILDING_SCENE.instantiate()
	buildings_root.add_child(b)
	b.global_position = grid.cell_to_world(origin_cell)
	b.setup(data, origin_cell, footprint)
	grid.reserve_forced(b, origin_cell, footprint)


func _on_resources_changed(wood: int, food: int, gold: int) -> void:
	if resource_label != null:
		resource_label.text = "Wood: %d    Food: %d    Gold: %d" % [wood, food, gold]
