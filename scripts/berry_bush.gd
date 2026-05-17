class_name BerryBush
extends StaticBody2D
##
## Forageable berry bush. Faster than chopping a tree, smaller yield.
## After foraging, the bush stays as a dim/leafless silhouette and stops
## blocking movement so the hero can pass through where it used to be.
##
## Visual is drawn programmatically via _draw() — placeholder until a
## berry-bush sprite is sourced.
##

const INTERACTION_RADIUS: float = 48.0
const HARVEST_TIME: float = 1.5  # quicker than tree
const SHAKE_AMPLITUDE: float = 2.0

@export var resource_kind: StringName = &"food"
@export var resource_amount: int = 3

signal harvested(amount: int)

@onready var collision: CollisionShape2D = $CollisionShape2D

var is_picked: bool = false
var _shake_offset: Vector2 = Vector2.ZERO


func _enter_tree() -> void:
	add_to_group("harvestable")
	add_to_group("berry_bush")


func _draw() -> void:
	# Pick a green for the bush body — dim if foraged.
	var bush_color: Color = Color(0.35, 0.62, 0.32) if not is_picked else Color(0.35, 0.42, 0.32, 0.6)
	var berry_color: Color = Color(0.85, 0.2, 0.25) if not is_picked else Color(0.4, 0.3, 0.3, 0.4)
	# Soft shadow under the bush.
	draw_circle(_shake_offset + Vector2(0, 4), 12, Color(0, 0, 0, 0.18))
	# Bush body — a slightly squashed lump.
	draw_circle(_shake_offset + Vector2(-4, -2), 8, bush_color)
	draw_circle(_shake_offset + Vector2(5, -1), 9, bush_color)
	draw_circle(_shake_offset + Vector2(0, -5), 8, bush_color)
	if not is_picked:
		# Berry dots scattered on the bush.
		draw_circle(_shake_offset + Vector2(-3, -3), 1.6, berry_color)
		draw_circle(_shake_offset + Vector2(4, -4), 1.6, berry_color)
		draw_circle(_shake_offset + Vector2(-1, 1), 1.6, berry_color)
		draw_circle(_shake_offset + Vector2(6, 2), 1.6, berry_color)


# --- Harvest interaction ----------------------------------------------------

func is_harvestable() -> bool:
	return not is_picked

func tree_shake() -> void:
	if is_picked:
		return
	# Small wiggle for forage feedback. Tween the _shake_offset and redraw.
	var t := create_tween()
	t.tween_method(_set_shake_offset, Vector2.ZERO, Vector2(SHAKE_AMPLITUDE, 0), 0.04)
	t.tween_method(_set_shake_offset, Vector2(SHAKE_AMPLITUDE, 0), Vector2(-SHAKE_AMPLITUDE, 0), 0.04)
	t.tween_method(_set_shake_offset, Vector2(-SHAKE_AMPLITUDE, 0), Vector2.ZERO, 0.06)

func _set_shake_offset(v: Vector2) -> void:
	_shake_offset = v
	queue_redraw()

func complete_harvest() -> int:
	if is_picked:
		return 0
	is_picked = true
	# Stop blocking — small bush, hero can walk where it used to be.
	if collision != null:
		collision.set_deferred("disabled", true)
	queue_redraw()
	harvested.emit(resource_amount)
	return resource_amount
