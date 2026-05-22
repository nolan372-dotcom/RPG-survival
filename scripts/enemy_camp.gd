class_name EnemyCamp
extends Node2D
##
## A cluster of enemies around a campfire. Placed by the BiomeGenerator;
## on spawn it scatters its enemies into the World so they y-sort and roam
## as peers of the hero. The camp node itself stays as the campfire marker
## and each enemy leashes back to its own spawn point.
##

## Each camp rolls a random headcount in this range when it spawns.
@export var enemy_count_min: int = 2
@export var enemy_count_max: int = 6
@export var spawn_radius: float = 46.0
@export var enemy_scene: PackedScene = preload("res://entities/enemy.tscn")


func _ready() -> void:
	_spawn_enemies()


func _spawn_enemies() -> void:
	var parent: Node = get_parent()
	if parent == null or enemy_scene == null:
		return
	var count: int = randi_range(enemy_count_min, enemy_count_max)
	for i in range(count):
		# Ring layout around the campfire, with a little jitter so it doesn't
		# read as a perfect circle.
		var angle: float = TAU * float(i) / float(maxi(count, 1))
		var radius: float = spawn_radius * randf_range(0.7, 1.1)
		var offset: Vector2 = Vector2(cos(angle), sin(angle)) * radius
		var enemy: Node2D = enemy_scene.instantiate()
		enemy.global_position = global_position + offset
		parent.add_child(enemy)
