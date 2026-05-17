class_name BiomeGenerator
extends Node
##
## Populates BiomeZones with procedural content using a seeded RNG.
##
## Algorithm: rejection sampling.
##   1. For each zone, pick a random count between min_count..max_count.
##   2. Try up to count*10 candidate positions within the zone's rect.
##   3. Reject candidates that fall within `clearance_radius` of any
##      `clearance_points` (e.g. hero spawn) OR within `min_separation`
##      of an already-placed entity in the same zone.
##   4. Accepted candidates spawn the kind of entity the zone wants.
##
## Not perfect Poisson-disc — but cheap, deterministic for a given seed,
## and produces visually-reasonable distributions for prototype scale.
##

const TREE_SCENE: PackedScene = preload("res://entities/tree.tscn")
const BERRY_BUSH_SCENE: PackedScene = preload("res://entities/berry_bush.tscn")
const GOLD_DEPOSIT_SCENE: PackedScene = preload("res://entities/gold_deposit.tscn")

## Returns total entities placed across all zones.
func populate(
	zones: Array,
	output_root: Node,
	seed_value: int,
	clearance_points: Array[Vector2] = []
) -> int:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var total: int = 0
	for zone_node in zones:
		if not (zone_node is BiomeZone):
			continue
		var zone: BiomeZone = zone_node
		total += _populate_zone(zone, output_root, rng, clearance_points)
	return total


func _populate_zone(
	zone: BiomeZone,
	output_root: Node,
	rng: RandomNumberGenerator,
	clearance_points: Array[Vector2]
) -> int:
	var target_count: int = rng.randi_range(zone.min_count, zone.max_count)
	var placed: Array[Vector2] = []
	var attempts: int = 0
	var max_attempts: int = target_count * 12

	var zone_origin: Vector2 = zone.global_position
	var half: Vector2 = zone.size * 0.5

	while placed.size() < target_count and attempts < max_attempts:
		attempts += 1
		var local := Vector2(
			rng.randf_range(-half.x, half.x),
			rng.randf_range(-half.y, half.y)
		)
		var world: Vector2 = zone_origin + local

		# Clearance: not too close to any protected point.
		var blocked: bool = false
		for cp in clearance_points:
			if world.distance_to(cp) < zone.clearance_radius:
				blocked = true
				break
		if blocked:
			continue

		# Separation: not too close to another entity already placed.
		for existing in placed:
			if world.distance_to(existing) < zone.min_separation:
				blocked = true
				break
		if blocked:
			continue

		placed.append(world)

	# Spawn entities for this zone.
	for world_pos in placed:
		var entity: Node2D = _spawn_for(zone.content_kind)
		if entity == null:
			continue
		entity.global_position = world_pos
		output_root.add_child(entity)

	return placed.size()


func _spawn_for(kind: int) -> Node2D:
	match kind:
		BiomeZone.ContentKind.TREES:
			return TREE_SCENE.instantiate()
		BiomeZone.ContentKind.BERRIES:
			return BERRY_BUSH_SCENE.instantiate()
		BiomeZone.ContentKind.GOLD:
			return GOLD_DEPOSIT_SCENE.instantiate()
		# BiomeZone.ContentKind.ENEMY_CAMP -- wired in Chunk 4.
	return null
