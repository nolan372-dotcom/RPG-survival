class_name TreeNode
extends StaticBody2D
##
## Decorative + harvestable tree placed in a biome. Reads one cell from
## pine-tree.png via region_rect for visual variety. Collision is a small
## circle at the trunk so the hero can walk between trees comfortably.
##
## Harvest interaction is wired up in C6 Chunk 3 (E to chop, time, drop wood).
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

@export var variant: int = 0
@export var randomize_variant_on_ready: bool = true

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	if randomize_variant_on_ready:
		variant = randi() % VARIANTS.size()
	_apply_variant()

func _apply_variant() -> void:
	if sprite == null:
		return
	var v: Vector2i = VARIANTS[variant % VARIANTS.size()]
	sprite.region_enabled = true
	sprite.region_rect = Rect2(v.x * TREE_CELL_X, v.y * TREE_CELL_Y_STRIDE, TREE_CROP_W, TREE_CROP_H)
