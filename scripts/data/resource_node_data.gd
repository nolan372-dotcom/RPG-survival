class_name ResourceNodeData
extends Resource

enum NodeType { TREE, BERRY_BUSH, GOLD_DEPOSIT, ORE_VEIN, CHEST }
enum ResourceType { WOOD, FOOD, GOLD }

@export var id: StringName
@export var display_name: String
@export var node_type: NodeType = NodeType.TREE
@export var resource_type: ResourceType = ResourceType.WOOD
@export var harvest_yield_min: int = 5
@export var harvest_yield_max: int = 10
@export var harvest_time: float = 3.0
@export var respawn_time: float = -1.0  # negative = does not respawn
@export var biome_id: StringName
@export var sprite: Texture2D
