class_name GoldDeposit
extends StaticBody2D
##
## Mineable gold deposit. Slow to mine, valuable. Cycles through 5 sprite
## stages as the player chips away — frame 1 is full, frame 5 is the
## mined-out remnant that stays in the world (still blocks movement).
##

const INTERACTION_RADIUS: float = 52.0
const HARVEST_TIME: float = 4.0  # slower than tree
const SHAKE_AMPLITUDE: float = 1.5

const STAGES: Array[Texture2D] = [
	preload("res://art/biomes/grasslands/gold-ore-1.png"),
	preload("res://art/biomes/grasslands/gold-ore-2.png"),
	preload("res://art/biomes/grasslands/gold-ore-3.png"),
	preload("res://art/biomes/grasslands/gold-ore-4.png"),
	preload("res://art/biomes/grasslands/gold-ore-5.png"),
]

@export var resource_kind: StringName = &"gold"
@export var resource_amount: int = 8

signal harvested(amount: int)

@onready var sprite: Sprite2D = $Sprite
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var burst: CPUParticles2D = $Burst

var is_mined: bool = false
var _base_sprite_offset: Vector2 = Vector2.ZERO
var _stage_index: int = 0  # 0 = full ore, STAGES.size()-1 = mined remnant


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
	if burst != null:
		burst.restart()
		burst.emitting = true

# Driven by the hero every physics frame during mining. Maps elapsed/total
# to a frame index so all 5 stages display for equal time (e.g. 4s harvest =
# 0.8s per frame).
func on_harvest_progress(elapsed: float, total: float) -> void:
	if is_mined or sprite == null or total <= 0.0:
		return
	var idx: int = int(elapsed / total * STAGES.size())
	idx = clamp(idx, 0, STAGES.size() - 1)
	if idx != _stage_index:
		_stage_index = idx
		sprite.texture = STAGES[idx]

func complete_harvest() -> int:
	if is_mined:
		return 0
	is_mined = true
	# Ore disappears entirely once mined out — the player walked away with all
	# of it. Disable collision so the hero can walk through immediately, then
	# free the node at end of frame (loot icons read global_position above
	# before the free actually runs).
	if collision != null:
		collision.set_deferred("disabled", true)
	harvested.emit(resource_amount)
	queue_free()
	return resource_amount
