class_name TreeNode
extends StaticBody2D
##
## Decorative + harvestable tree placed in a biome. Reads one cell from
## pine-tree.png via region_rect for visual variety. Collision is a small
## circle at the trunk so the hero can walk between trees comfortably.
##
## Harvest flow (C6-S3):
##   1. Hero stands within INTERACTION_RADIUS and holds E for HARVEST_TIME.
##   2. tree_shake() fires on each chop tick (every 0.5s) for visual feedback.
##   3. complete_harvest() swaps the sprite to the stump variant, spawns a
##      "falling log" animation (rotates around the trunk base then fades),
##      disables collision, and returns the wood amount.
##

# Atlas geometry:
#   Cells are packed every 128 px in x and 160 px in y, but the actual
#   row 0 trees are TALLER than 160 — their shadow ellipse + trunk base
#   spills 40 px into row 1's cell space. So we use 160 as the inter-row
#   STRIDE (where each variant starts) but 200 as the crop HEIGHT (so
#   the shadow is included rather than cut off at y=160).
const TREE_CELL_X: int = 128
const TREE_CELL_Y_STRIDE: int = 160
const TREE_CROP_W: int = 128
const TREE_CROP_H: int = 200

# Only row 0 variants (cols 0-2). Other rows would need per-variant offsets
# because their trees occupy different parts of their nominal cell area.
const VARIANTS: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
]

# Stump variant (top-right corner of pine-tree.png).
# Cropped to 128x80 because the stump itself is small and the rest of that
# cell region contains shadow ovals we don't want.
const STUMP_REGION: Rect2 = Rect2(384, 0, 128, 80)
# Where the stump renders + collides relative to the StaticBody origin.
# Found empirically: changing sprite.offset had no visible effect (Godot
# rendering quirk?), but sprite.position works. Collision and visual are
# co-located so they read as one object.
const STUMP_OFFSET: Vector2 = Vector2(0, 65)
const STUMP_COLLISION_POSITION: Vector2 = Vector2(0, 65)
const STUMP_COLLISION_RADIUS: float = 14.0

# Harvest tuning.
const HARVEST_TIME: float = 3.0       # seconds of held E to chop down
const WOOD_PER_HARVEST: int = 5
const INTERACTION_RADIUS: float = 56.0  # hero must be this close to start harvest
const SHAKE_AMPLITUDE: float = 3.0

signal harvested(wood_amount: int)

@export var variant: int = 0
@export var randomize_variant_on_ready: bool = true

@onready var sprite: Sprite2D = $Sprite
@onready var collision: CollisionShape2D = $CollisionShape2D

var is_chopped: bool = false
var _original_sprite_offset: Vector2

func _enter_tree() -> void:
	add_to_group("harvestable")
	add_to_group("tree")

func _ready() -> void:
	if randomize_variant_on_ready:
		variant = randi() % VARIANTS.size()
	_apply_variant()
	if sprite != null:
		_original_sprite_offset = sprite.offset

func _apply_variant() -> void:
	if sprite == null:
		return
	var v: Vector2i = VARIANTS[variant % VARIANTS.size()]
	sprite.region_enabled = true
	sprite.region_rect = Rect2(v.x * TREE_CELL_X, v.y * TREE_CELL_Y_STRIDE, TREE_CROP_W, TREE_CROP_H)


# --- Harvest interaction ----------------------------------------------------

func is_harvestable() -> bool:
	return not is_chopped

func tree_shake() -> void:
	if is_chopped or sprite == null:
		return
	var origin: Vector2 = _original_sprite_offset
	var t := create_tween()
	t.tween_property(sprite, "offset", origin + Vector2(SHAKE_AMPLITUDE, 0), 0.04)
	t.tween_property(sprite, "offset", origin - Vector2(SHAKE_AMPLITUDE, 0), 0.04)
	t.tween_property(sprite, "offset", origin, 0.06)

func complete_harvest() -> int:
	if is_chopped:
		return 0
	is_chopped = true
	# Re-shape the collision to match the smaller stump footprint and move it
	# to overlap the stump visual. Build a fresh CircleShape2D so we don't
	# mutate the shared trunk shape that other Tree instances are still using.
	if collision != null:
		var stump_shape := CircleShape2D.new()
		stump_shape.radius = STUMP_COLLISION_RADIUS
		collision.shape = stump_shape
		collision.position = STUMP_COLLISION_POSITION
	_spawn_falling_log()
	_swap_to_stump()
	harvested.emit(WOOD_PER_HARVEST)
	return WOOD_PER_HARVEST

func _swap_to_stump() -> void:
	if sprite == null:
		return
	# Shift via sprite.position rather than sprite.offset — setting offset
	# at runtime produced no visible movement during Chunk 3a playtest
	# (likely a Godot quirk around centered sprites + offset reassignment).
	# Moving the sprite node directly works as expected.
	sprite.offset = Vector2.ZERO
	sprite.position = STUMP_OFFSET
	sprite.region_rect = STUMP_REGION

func _spawn_falling_log() -> void:
	# Snapshot the original tree visual into a free-standing pivot Node2D
	# positioned at this tree's trunk base, then tween-rotate it 90deg around
	# the base so it visually falls to the right, fading out at the end.
	var pivot := Node2D.new()
	pivot.global_position = global_position

	var log_sprite := Sprite2D.new()
	log_sprite.texture = sprite.texture
	log_sprite.region_enabled = true
	var v: Vector2i = VARIANTS[variant % VARIANTS.size()]
	log_sprite.region_rect = Rect2(v.x * TREE_CELL_X, v.y * TREE_CELL_Y_STRIDE, TREE_CROP_W, TREE_CROP_H)
	log_sprite.offset = _original_sprite_offset
	log_sprite.z_index = 1  # draw above the stump that replaces us

	pivot.add_child(log_sprite)
	# Add as sibling of this tree (under the same World container) so it
	# y-sorts naturally alongside us.
	get_parent().add_child(pivot)

	var t := create_tween()
	t.tween_property(pivot, "rotation", PI / 2.0, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	t.tween_property(log_sprite, "modulate:a", 0.0, 0.3)
	t.tween_callback(pivot.queue_free)
