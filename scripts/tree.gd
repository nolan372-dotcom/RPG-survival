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
# Column/row of tree variants on pine-tree.png (4 cols x 4 rows of usable trees,
# the top-right cell is a stump, last column is mostly shadow ovals).
const VARIANTS: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
	Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1),
	Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2),
	Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3),
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
