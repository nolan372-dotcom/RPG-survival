extends Node2D
##
## C8 prototype scene. 30x30 buildable plot with a pre-placed castle and
## Waypoint Shrine. Three enemy spawn markers at the northern edge feed the
## threat-line preview during placement. Hero is in-scene so you can walk
## around between placements.
##

const BUILDING_SCENE: PackedScene = preload("res://entities/building.tscn")

@onready var grid: GridManager = $Grid
@onready var build_placement: BuildPlacement = $Grid/BuildPlacement
@onready var threat_line: ThreatLinePreview = $Grid/ThreatLinePreview
@onready var build_menu: BuildMenu = $UI/BuildMenu
@onready var resource_label: Label = $UI/ResourceLabel
@onready var hero: Hero = $Hero
@onready var castle_pre: StaticBody2D = $Grid/PrePlaced/Castle
@onready var shrine_pre: Node2D = $Grid/PrePlaced/Shrine
@onready var spawn_markers: Node2D = $Grid/SpawnMarkers
@onready var buildings_root: Node2D = $Grid/Buildings


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


func _unhandled_input(event: InputEvent) -> void:
	# F8 — quick scene swap to combat test arena.
	if event is InputEventKey and event.pressed and event.keycode == KEY_F8:
		get_tree().change_scene_to_file("res://scenes/test_arena.tscn")


func _on_build_button_pressed(data: BuildingData) -> void:
	build_placement.begin(data)


func _on_placement_confirmed(data: BuildingData, origin_cell: Vector2i, footprint: Vector2i) -> void:
	print("[CastlePlot] spawning ", data.display_name, " at cell ", origin_cell, " footprint ", footprint)
	var b: Building = BUILDING_SCENE.instantiate()
	buildings_root.add_child(b)
	b.global_position = grid.cell_to_world(origin_cell)
	b.setup(data, origin_cell, footprint)
	grid.reserve_forced(b, origin_cell, footprint)
	print("[CastlePlot] spawned at global_position=", b.global_position, " visual_size=(", footprint.x * GridManager.CELL_SIZE, ",", footprint.y * GridManager.CELL_SIZE, ")")


func _on_resources_changed(wood: int, food: int, gold: int) -> void:
	if resource_label != null:
		resource_label.text = "Wood: %d    Food: %d    Gold: %d" % [wood, food, gold]
