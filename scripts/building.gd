class_name Building
extends StaticBody2D
##
## Generic placed building. Reads BuildingData for everything that varies
## (footprint, cost, HP, sprite). For the prototype the sprite is a colored
## rectangle with a label; real building art comes in Phase 2.
##

signal hp_changed(current: int, max_hp: int)
signal destroyed

@export var data: BuildingData

var origin_cell: Vector2i  # top-left cell on the GridManager
var footprint: Vector2i = Vector2i(1, 1)
var current_hp: int = 100
var max_hp: int = 100

@onready var visual: ColorRect = $Visual
@onready var label: Label = $Visual/Label
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hp_bar: ProgressBar = $HPBar


func setup(building_data: BuildingData, origin: Vector2i, override_footprint: Vector2i = Vector2i.ZERO) -> void:
	data = building_data
	origin_cell = origin
	if override_footprint != Vector2i.ZERO:
		footprint = override_footprint
	else:
		footprint = Vector2i(data.footprint_x, data.footprint_y)
	max_hp = data.hp
	current_hp = max_hp
	_apply_visual()
	hp_changed.emit(current_hp, max_hp)


func _ready() -> void:
	# If setup() was already called before _ready (e.g. from placement code),
	# re-apply now that nodes are ready.
	if data != null:
		_apply_visual()


func _apply_visual() -> void:
	if visual == null:
		return
	var w: float = footprint.x * GridManager.CELL_SIZE
	var h: float = footprint.y * GridManager.CELL_SIZE
	# Visual sits with origin at the top-left of the footprint.
	visual.size = Vector2(w, h)
	visual.position = Vector2.ZERO
	visual.color = _color_for_function(data.function_type)
	if label != null:
		label.text = data.display_name
		label.size = visual.size
	if collision != null and collision.shape is RectangleShape2D:
		(collision.shape as RectangleShape2D).size = Vector2(w, h)
		collision.position = Vector2(w * 0.5, h * 0.5)
	if hp_bar != null:
		hp_bar.max_value = max_hp
		hp_bar.value = current_hp
		hp_bar.size = Vector2(w, 4)
		hp_bar.position = Vector2(0, -8)


func take_damage(amount: int, _source: Node = null) -> void:
	current_hp = max(0, current_hp - amount)
	if hp_bar != null:
		hp_bar.value = current_hp
	hp_changed.emit(current_hp, max_hp)
	if current_hp <= 0:
		destroyed.emit()
		queue_free()


static func _color_for_function(function_type: int) -> Color:
	# BuildingData.FunctionType: RESOURCE=0, MILITARY=1, DEFENSE=2, UTILITY=3
	match function_type:
		0: return Color(0.55, 0.45, 0.25, 1)  # warm earth — Farms/Lumber/Markets
		1: return Color(0.45, 0.35, 0.45, 1)  # muted purple — Barracks/Merc/Watchtower
		2: return Color(0.40, 0.40, 0.45, 1)  # stone grey — walls/towers
		3: return Color(0.55, 0.35, 0.30, 1)  # forge red — Forge/Mason's
	return Color(0.5, 0.5, 0.5, 1)
