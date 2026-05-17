class_name BuildPlacement
extends Node2D
##
## Placement controller. The BuildMenu calls `begin(data)` with a chosen
## BuildingData; this node renders a ghost preview at the cursor, snapped to the
## GridManager's grid, and confirms/cancels via LMB / ESC. R rotates non-square
## footprints (swaps footprint X and Y).
##

signal placement_confirmed(data: BuildingData, origin_cell: Vector2i, footprint: Vector2i)
signal placement_cancelled

@export var grid: GridManager
@export var hero_path: NodePath
@export var threat_line: Node  # ThreatLinePreview reference, optional

const VALID_TINT: Color = Color(0.55, 1.0, 0.55, 0.45)
const INVALID_TINT: Color = Color(1.0, 0.35, 0.35, 0.45)
const OUTLINE_COLOR: Color = Color(0.0, 0.0, 0.0, 0.6)

var _active: bool = false
var _data: BuildingData
var _footprint: Vector2i = Vector2i(1, 1)
var _origin_cell: Vector2i = Vector2i.ZERO
var _ghost_valid: bool = false

@onready var _hero: Hero = get_node_or_null(hero_path) as Hero


# --- Public API ---------------------------------------------------------------

func begin(data: BuildingData) -> void:
	if data == null or grid == null:
		push_warning("BuildPlacement.begin() bailed — data or grid not set")
		return
	_active = true
	_data = data
	_footprint = Vector2i(max(1, data.footprint_x), max(1, data.footprint_y))
	if _hero != null:
		_hero.input_locked = true
	_update_ghost()
	queue_redraw()

func cancel() -> void:
	if not _active:
		return
	_finish()
	placement_cancelled.emit()

func is_active() -> bool:
	return _active


# --- Per-frame update --------------------------------------------------------

func _process(_delta: float) -> void:
	if not _active:
		return
	_update_ghost()
	queue_redraw()
	if threat_line != null and threat_line.has_method("update_for_ghost"):
		threat_line.update_for_ghost(_origin_cell, _footprint, _data != null)


# _input fires BEFORE GUI processing, so on the frame the user clicks a menu
# button this method runs while _active is still false (placement hasn't started
# yet) and harmlessly returns. The button's pressed signal then triggers begin().
# Subsequent grass clicks fire _input while _active is true and route through
# _try_confirm. No suppression hacks needed.
func _input(event: InputEvent) -> void:
	if not _active:
		return
	if not (event is InputEventMouseButton):
		return
	var mb := event as InputEventMouseButton
	if not mb.pressed or mb.button_index != MOUSE_BUTTON_LEFT:
		return
	# Don't confirm if the cursor is over a UI button. Decorative ColorRects
	# should be set to mouse_filter=IGNORE so they aren't reported here.
	if get_viewport().gui_get_hovered_control() != null:
		return
	_try_confirm()
	get_viewport().set_input_as_handled()


func _update_ghost() -> void:
	if grid == null:
		return
	var mouse_world: Vector2 = get_global_mouse_position()
	_origin_cell = grid.world_to_cell(mouse_world)
	# Roughly center the footprint under the cursor (intentional integer division).
	@warning_ignore("integer_division")
	_origin_cell.x -= _footprint.x / 2
	@warning_ignore("integer_division")
	_origin_cell.y -= _footprint.y / 2
	var valid: bool = grid.can_place(_origin_cell, _footprint)
	var affordable: bool = _affordable()
	_ghost_valid = valid and affordable


func _draw() -> void:
	if not _active or grid == null:
		return
	# Draw the ghost in local coordinates because we're a Node2D in the same
	# parent as GridManager — convert the cell's world position to our local space.
	var world_pos: Vector2 = grid.cell_to_world(_origin_cell)
	var local_pos: Vector2 = to_local(world_pos)
	var size := Vector2(_footprint.x * GridManager.CELL_SIZE, _footprint.y * GridManager.CELL_SIZE)
	var rect := Rect2(local_pos, size)
	var fill: Color = VALID_TINT if _ghost_valid else INVALID_TINT
	draw_rect(rect, fill, true)
	draw_rect(rect, OUTLINE_COLOR, false, 2.0)


# --- Input -------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if not _active:
		return
	if event.is_action_pressed("cancel"):
		cancel()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("rotate_placement"):
		_footprint = Vector2i(_footprint.y, _footprint.x)
		_update_ghost()
		queue_redraw()
		get_viewport().set_input_as_handled()


# --- Confirm / cancel -------------------------------------------------------

func _try_confirm() -> void:
	if not grid.can_place(_origin_cell, _footprint):
		return
	if not _affordable():
		return
	if not ResourceState.try_spend(_data.cost_wood, _data.cost_food, _data.cost_gold):
		return
	var origin: Vector2i = _origin_cell
	var footprint: Vector2i = _footprint
	var data: BuildingData = _data
	_finish()
	placement_confirmed.emit(data, origin, footprint)

func _affordable() -> bool:
	if _data == null:
		return false
	return ResourceState.can_afford(_data.cost_wood, _data.cost_food, _data.cost_gold)

func _finish() -> void:
	_active = false
	_data = null
	if _hero != null:
		_hero.input_locked = false
	if threat_line != null and threat_line.has_method("clear"):
		threat_line.clear()
	queue_redraw()
