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
# Only rows 0-1 are used: those tree variants share the same trunk-base
# alignment in their cells, so a single sprite offset roots them correctly.
# Rows 2-3 contain progressively smaller trees positioned differently within
# their cells — using them produced floating / stump-like artifacts.
# The 4th column (cells 3,*) holds a stump + shadow ovals — also excluded.
const VARIANTS: Array[Vector2i] = [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
	Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1),
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
