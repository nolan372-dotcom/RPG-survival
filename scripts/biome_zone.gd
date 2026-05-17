class_name BiomeZone
extends Node2D
##
## Designer-marked area where the BiomeGenerator can place procedural content
## (trees today; resource nodes / enemy camps in later chunks).
##
## The zone's footprint is an axis-aligned rectangle centered on this Node2D's
## position. Add as children of a BiomeZones container in the biome scene.
##

enum ContentKind { TREES, BERRIES, GOLD, ENEMY_CAMP }

@export var size: Vector2 = Vector2(800, 600)
@export var content_kind: ContentKind = ContentKind.TREES
@export var min_count: int = 12
@export var max_count: int = 22
## Minimum world-space distance between two spawned entities in this zone.
## Used by the generator's rejection sampling. Larger = sparser.
@export var min_separation: float = 96.0
## No spawns will land within this radius of any point in `clearance_points`
## (typically the hero's spawn so they don't start wedged inside a tree).
@export var clearance_radius: float = 120.0
## Debug-only: draw the zone bounds.
@export var debug_draw: bool = false


func rect() -> Rect2:
	return Rect2(global_position - size * 0.5, size)


func _draw() -> void:
	if not debug_draw:
		return
	# In local coords — size centered on this node.
	var r := Rect2(-size * 0.5, size)
	draw_rect(r, Color(0.4, 0.9, 1.0, 0.08), true)
	draw_rect(r, Color(0.4, 0.9, 1.0, 0.55), false, 2.0)
