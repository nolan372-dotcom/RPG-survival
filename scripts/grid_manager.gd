class_name GridManager
extends Node2D
##
## Owns the castle plot's tile grid: bounds, occupancy, and placement validation.
##
## Grid origin (0, 0) is the top-left of the buildable area in this node's local
## coordinates. Position the GridManager wherever you want the plot to sit.
##

const CELL_SIZE: int = 32

@export var grid_cols: int = 30
@export var grid_rows: int = 30

# cell (Vector2i) -> Node (the placed building); also each cell of a multi-tile
# footprint maps back to the same node, for collision checks.
var _occupancy: Dictionary = {}

signal building_placed(building: Node, origin: Vector2i, footprint: Vector2i)
signal building_removed(building: Node)


# --- Coordinate conversion ----------------------------------------------------

func world_to_cell(world_pos: Vector2) -> Vector2i:
	var local: Vector2 = to_local(world_pos)
	return Vector2i(int(floor(local.x / float(CELL_SIZE))), int(floor(local.y / float(CELL_SIZE))))

func cell_to_world(cell: Vector2i) -> Vector2:
	return to_global(Vector2(cell.x * CELL_SIZE, cell.y * CELL_SIZE))

## World position of a footprint's center, given its top-left cell + size.
func footprint_center_world(origin_cell: Vector2i, footprint: Vector2i) -> Vector2:
	var local := Vector2(
		(origin_cell.x + footprint.x * 0.5) * CELL_SIZE,
		(origin_cell.y + footprint.y * 0.5) * CELL_SIZE
	)
	return to_global(local)


# --- Bounds & occupancy ------------------------------------------------------

func is_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < grid_cols and cell.y < grid_rows

func is_cell_occupied(cell: Vector2i) -> bool:
	return _occupancy.has(cell)

func get_occupant(cell: Vector2i) -> Node:
	return _occupancy.get(cell, null)


# --- Placement queries --------------------------------------------------------

## Returns true if the given footprint can be placed with origin at this cell.
func can_place(origin: Vector2i, footprint: Vector2i) -> bool:
	for dx in footprint.x:
		for dy in footprint.y:
			var c := Vector2i(origin.x + dx, origin.y + dy)
			if not is_in_bounds(c):
				return false
			if is_cell_occupied(c):
				return false
	return true

## Cells a footprint at origin would cover.
func footprint_cells(origin: Vector2i, footprint: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for dx in footprint.x:
		for dy in footprint.y:
			cells.append(Vector2i(origin.x + dx, origin.y + dy))
	return cells


# --- Mutations ---------------------------------------------------------------

## Reserve cells for `building` at `origin` (top-left) with size `footprint`.
## Caller is responsible for adding the building node to the scene tree.
func reserve(building: Node, origin: Vector2i, footprint: Vector2i) -> bool:
	if not can_place(origin, footprint):
		return false
	for cell in footprint_cells(origin, footprint):
		_occupancy[cell] = building
	building_placed.emit(building, origin, footprint)
	return true

## Reserve cells unconditionally (used for pre-placed castle / shrine / etc).
## Does NOT check overlap — caller asserts the area is clear.
func reserve_forced(building: Node, origin: Vector2i, footprint: Vector2i) -> void:
	for cell in footprint_cells(origin, footprint):
		_occupancy[cell] = building
	building_placed.emit(building, origin, footprint)

func release(building: Node) -> void:
	var to_remove: Array[Vector2i] = []
	for cell in _occupancy:
		if _occupancy[cell] == building:
			to_remove.append(cell)
	for cell in to_remove:
		_occupancy.erase(cell)
	building_removed.emit(building)
