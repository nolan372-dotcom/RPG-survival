class_name ThreatLinePreview
extends Node2D
##
## C8-S4: while the player is placing a building, faintly trace lines from each
## enemy spawn point straight to the castle. If the ghost's footprint sits on
## one of those lines, highlight the line in red — telling the player the
## building will eat damage on enemies' direct paths from that spawn.
##

@export var grid: GridManager
@export var castle_world_position: Vector2 = Vector2.ZERO
@export var spawn_points_world: Array[Vector2] = []

const FAINT_COLOR: Color = Color(0.85, 0.2, 0.2, 0.18)
const HIGHLIGHT_COLOR: Color = Color(1.0, 0.25, 0.25, 0.85)
const LINE_WIDTH: float = 2.0

var _show: bool = false
var _highlighted: Array[bool] = []

func _ready() -> void:
	_highlighted.resize(spawn_points_world.size())
	queue_redraw()

func clear() -> void:
	_show = false
	queue_redraw()

func update_for_ghost(origin_cell: Vector2i, footprint: Vector2i, data_present: bool) -> void:
	_show = data_present
	if not _show or grid == null:
		queue_redraw()
		return
	# Build the ghost's world-space rect in this node's local coords.
	var top_left: Vector2 = to_local(grid.cell_to_world(origin_cell))
	var size := Vector2(footprint.x * GridManager.CELL_SIZE, footprint.y * GridManager.CELL_SIZE)
	var ghost_rect := Rect2(top_left, size)
	# Test each spawn->castle segment against the ghost rect.
	_highlighted.resize(spawn_points_world.size())
	for i in spawn_points_world.size():
		var a: Vector2 = to_local(spawn_points_world[i])
		var b: Vector2 = to_local(castle_world_position)
		_highlighted[i] = _segment_intersects_rect(a, b, ghost_rect)
	queue_redraw()

func _draw() -> void:
	if not _show:
		return
	for i in spawn_points_world.size():
		var a: Vector2 = to_local(spawn_points_world[i])
		var b: Vector2 = to_local(castle_world_position)
		var color: Color = HIGHLIGHT_COLOR if (i < _highlighted.size() and _highlighted[i]) else FAINT_COLOR
		draw_line(a, b, color, LINE_WIDTH, true)


# --- Geometry helpers --------------------------------------------------------

## Liang-Barsky-ish segment vs. axis-aligned rect test.
static func _segment_intersects_rect(a: Vector2, b: Vector2, r: Rect2) -> bool:
	# Fast accept: either endpoint inside the rect.
	if r.has_point(a) or r.has_point(b):
		return true
	# Test each of the 4 rect edges as segments.
	var top_left := r.position
	var top_right := r.position + Vector2(r.size.x, 0)
	var bot_right := r.position + r.size
	var bot_left := r.position + Vector2(0, r.size.y)
	return _segments_intersect(a, b, top_left, top_right) \
		or _segments_intersect(a, b, top_right, bot_right) \
		or _segments_intersect(a, b, bot_right, bot_left) \
		or _segments_intersect(a, b, bot_left, top_left)

static func _segments_intersect(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2) -> bool:
	var r: Vector2 = p2 - p1
	var s: Vector2 = p4 - p3
	var rxs: float = r.x * s.y - r.y * s.x
	if absf(rxs) < 0.0001:
		return false  # parallel or collinear — treat as no intersection
	var q_p: Vector2 = p3 - p1
	var t: float = (q_p.x * s.y - q_p.y * s.x) / rxs
	var u: float = (q_p.x * r.y - q_p.y * r.x) / rxs
	return t >= 0.0 and t <= 1.0 and u >= 0.0 and u <= 1.0
