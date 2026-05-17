extends Node2D
##
## C6 Grasslands prototype scene. Chunk 1: scene shell with hero + a few
## hand-placed trees + tiled grass ground. Chunk 2 adds BiomeZone procgen.
## Chunk 3 adds harvest interaction. Chunk 4 adds enemy camps.
##
## Press F9 to swap to test_arena (combat playground).
## Press F10 to swap back to castle_plot.
##

const TREE_SCENE: PackedScene = preload("res://entities/tree.tscn")

# Hand-placed tree positions for Chunk 1 sanity test. Chunk 2 replaces with procgen.
const SAMPLE_TREE_POSITIONS: Array[Vector2] = [
	Vector2(-220, -60), Vector2(-150, 40), Vector2(-80, -150),
	Vector2(120, -100), Vector2(200, 30), Vector2(180, 160),
	Vector2(40, 200), Vector2(-100, 240), Vector2(-280, 120),
]

@onready var hero: Hero = $Hero
@onready var trees_root: Node2D = $Trees


func _ready() -> void:
	hero.add_to_group("hero")
	add_to_group("grasslands")
	for pos in SAMPLE_TREE_POSITIONS:
		var t: Node2D = TREE_SCENE.instantiate()
		t.position = pos
		trees_root.add_child(t)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F9:
				get_tree().change_scene_to_file("res://scenes/test_arena.tscn")
			KEY_F10:
				get_tree().change_scene_to_file("res://scenes/castle_plot.tscn")
