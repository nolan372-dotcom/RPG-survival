class_name GoldDeposit
extends StaticBody2D
##
## Mineable gold deposit. Slow to mine, valuable, leaves a darkened rock
## behind that still blocks movement (it's a chunk of rock either way).
##

const INTERACTION_RADIUS: float = 52.0
const HARVEST_TIME: float = 4.0  # slower than tree
const SHAKE_AMPLITUDE: float = 1.5
const MINED_MODULATE: Color = Color(0.5, 0.5, 0.5, 1.0)  # dim to grey when mined

@export var resource_kind: StringName = &"gold"
@export var resource_amount: int = 8

signal harvested(amount: int)

@onready var sprite: Sprite2D = $Sprite
@onready var collision: CollisionShape2D = $CollisionShape2D

var is_mined: bool = false
var _base_sprite_offset: Vector2 = Vector2.ZERO


func _enter_tree() -> void:
	add_to_group("harvestable")
	add_to_group("gold_deposit")


func _ready() -> void:
	if sprite != null:
		_base_sprite_offset = sprite.offset


# --- Harvest interaction ----------------------------------------------------

func is_harvestable() -> bool:
	return not is_mined

func tree_shake() -> void:
	if is_mined or sprite == null:
		return
	var origin: Vector2 = _base_sprite_offset
	var t := create_tween()
	t.tween_property(sprite, "offset", origin + Vector2(SHAKE_AMPLITUDE, 0), 0.03)
	t.tween_property(sprite, "offset", origin - Vector2(SHAKE_AMPLITUDE, 0), 0.03)
	t.tween_property(sprite, "offset", origin, 0.05)

func complete_harvest() -> int:
	if is_mined:
		return 0
	is_mined = true
	# Collision stays — rock chunk still blocks movement.
	# Visual: dim the sprite so the gold flecks read as 'gone'.
	if sprite != null:
		var t := create_tween()
		t.tween_property(sprite, "modulate", MINED_MODULATE, 0.25)
	harvested.emit(resource_amount)
	return resource_amount
