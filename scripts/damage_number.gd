class_name DamageNumber
extends Node2D
##
## Float-up damage popup. Spawn at world position, set value, it does the rest.
##

@onready var label: Label = $Label
var _velocity: Vector2
var _lifetime: float = 0.0
const TOTAL_LIFETIME: float = 0.7
const RISE_SPEED: float = 40.0

func _ready() -> void:
	_velocity = Vector2(randf_range(-12.0, 12.0), -RISE_SPEED)

func setup(value: int, is_critical: bool = false) -> void:
	# Called before _ready in some flows; defer until label exists.
	await get_tree().process_frame
	if not is_inside_tree():
		return
	if label == null:
		label = $Label
	label.text = str(value)
	if is_critical:
		label.modulate = Color(1.0, 0.55, 0.3)
		label.scale = Vector2(1.4, 1.4)
	else:
		label.modulate = Color(1.0, 0.95, 0.85)

func _process(delta: float) -> void:
	_lifetime += delta
	position += _velocity * delta
	_velocity.y += 80.0 * delta  # ease the rise into a small fall arc
	var t: float = clamp(_lifetime / TOTAL_LIFETIME, 0.0, 1.0)
	modulate.a = 1.0 - t
	if _lifetime >= TOTAL_LIFETIME:
		queue_free()
