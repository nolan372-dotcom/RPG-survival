class_name GoldDeposit
extends StaticBody2D
##
## Mineable gold deposit. Slow to mine, valuable, leaves a hollow rock
## behind that still blocks movement (it's a chunk of rock either way).
##
## Visual is drawn programmatically via _draw() — placeholder until a
## proper gold-ore sprite is sourced.
##

const INTERACTION_RADIUS: float = 52.0
const HARVEST_TIME: float = 4.0  # slower than tree
const SHAKE_AMPLITUDE: float = 1.5

@export var resource_kind: StringName = &"gold"
@export var resource_amount: int = 8

signal harvested(amount: int)

@onready var collision: CollisionShape2D = $CollisionShape2D

var is_mined: bool = false
var _shake_offset: Vector2 = Vector2.ZERO


func _enter_tree() -> void:
	add_to_group("harvestable")
	add_to_group("gold_deposit")


func _draw() -> void:
	# Rock body — grey, with a hint of brown earth.
	var rock_color: Color = Color(0.4, 0.4, 0.42)
	var gold_color: Color = Color(0.95, 0.78, 0.25)
	# Shadow under the rock.
	draw_circle(_shake_offset + Vector2(0, 5), 14, Color(0, 0, 0, 0.22))
	# Rock as overlapping circles (gives it a chunky outline).
	draw_circle(_shake_offset + Vector2(-6, -1), 9, rock_color)
	draw_circle(_shake_offset + Vector2(4, 0), 11, rock_color)
	draw_circle(_shake_offset + Vector2(-1, -5), 9, rock_color)
	# Highlight edge.
	draw_circle(_shake_offset + Vector2(-1, -7), 3, Color(0.55, 0.55, 0.58, 0.7))
	if not is_mined:
		# Gold flecks embedded in the rock.
		draw_circle(_shake_offset + Vector2(-3, -2), 1.8, gold_color)
		draw_circle(_shake_offset + Vector2(5, -1), 2.0, gold_color)
		draw_circle(_shake_offset + Vector2(-5, 1), 1.4, gold_color)
		draw_circle(_shake_offset + Vector2(2, -5), 1.6, gold_color)
	else:
		# After mining: a dark hollow in the rock.
		draw_circle(_shake_offset + Vector2(0, -1), 4, Color(0.1, 0.08, 0.1, 0.7))


# --- Harvest interaction ----------------------------------------------------

func is_harvestable() -> bool:
	return not is_mined

func tree_shake() -> void:
	if is_mined:
		return
	# Smaller wiggle than a tree (rocks don't sway).
	var t := create_tween()
	t.tween_method(_set_shake_offset, Vector2.ZERO, Vector2(SHAKE_AMPLITUDE, 0), 0.03)
	t.tween_method(_set_shake_offset, Vector2(SHAKE_AMPLITUDE, 0), Vector2(-SHAKE_AMPLITUDE, 0), 0.03)
	t.tween_method(_set_shake_offset, Vector2(-SHAKE_AMPLITUDE, 0), Vector2.ZERO, 0.05)

func _set_shake_offset(v: Vector2) -> void:
	_shake_offset = v
	queue_redraw()

func complete_harvest() -> int:
	if is_mined:
		return 0
	is_mined = true
	# Collision intentionally kept — rock chunk still blocks movement.
	queue_redraw()
	harvested.emit(resource_amount)
	return resource_amount
