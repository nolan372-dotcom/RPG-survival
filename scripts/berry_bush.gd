class_name BerryBush
extends StaticBody2D
##
## Forageable berry bush. Faster than chopping a tree, smaller yield.
## After foraging, the sprite swaps to the empty-bush variant; collision
## is disabled so the hero can walk where the picked bush used to be.
##

const INTERACTION_RADIUS: float = 48.0
const HARVEST_TIME: float = 1.5  # quicker than tree
const SHAKE_AMPLITUDE: float = 2.0

@export var resource_kind: StringName = &"food"
@export var resource_amount: int = 3
@export var full_texture: Texture2D
@export var empty_texture: Texture2D

signal harvested(amount: int)

@onready var sprite: Sprite2D = $Sprite
@onready var collision: CollisionShape2D = $CollisionShape2D

var is_picked: bool = false
var _base_sprite_offset: Vector2 = Vector2.ZERO


func _enter_tree() -> void:
	add_to_group("harvestable")
	add_to_group("berry_bush")


func _ready() -> void:
	if sprite != null:
		_base_sprite_offset = sprite.offset
		if full_texture != null:
			sprite.texture = full_texture


# --- Harvest interaction ----------------------------------------------------

func is_harvestable() -> bool:
	return not is_picked

func tree_shake() -> void:
	if is_picked or sprite == null:
		return
	var origin: Vector2 = _base_sprite_offset
	var t := create_tween()
	t.tween_property(sprite, "offset", origin + Vector2(SHAKE_AMPLITUDE, 0), 0.04)
	t.tween_property(sprite, "offset", origin - Vector2(SHAKE_AMPLITUDE, 0), 0.04)
	t.tween_property(sprite, "offset", origin, 0.06)

func complete_harvest() -> int:
	if is_picked:
		return 0
	is_picked = true
	# Swap to the empty-bush texture and stop blocking.
	if sprite != null and empty_texture != null:
		sprite.texture = empty_texture
	if collision != null:
		collision.set_deferred("disabled", true)
	harvested.emit(resource_amount)
	return resource_amount
