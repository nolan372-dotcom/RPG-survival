class_name TreeNode
extends StaticBody2D
##
## Decorative + harvestable tree placed in a biome. Reads one cell from
## pine-tree.png via region_rect for visual variety. Collision is a small
## circle at the trunk so the hero can walk between trees comfortably.
##
## Harvest interaction is wired up in C6 Chunk 3 (E to chop, time, drop wood).
##

const TREE_CELL_SIZE: Vector2i = Vector2i(128, 160)
# Only row 0 is used. The row 0 trees are taller than 160px, so their
# shadow + base overflow into row 1's cell area. Cropping row 1 produces
# a "ghost stump" at the top of the sprite — visible as floating
# stump-like artifacts at playtest. Rows 2-3 have similar overflow plus
# their own variant inconsistencies. Col 3 contains the standalone stump
# and shadow ovals.
# Net: 3 clean variants from row 0 cols 0-2. Plenty of variety; all
# render as full upright pines.
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
	sprite.region_rect = Rect2(v.x * TREE_CELL_SIZE.x, v.y * TREE_CELL_SIZE.y, TREE_CELL_SIZE.x, TREE_CELL_SIZE.y)
