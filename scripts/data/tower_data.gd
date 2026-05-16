class_name TowerData
extends BuildingData

enum TargetingRule { NEAREST, DENSEST_CLUSTER, HIGHEST_HP, LOWEST_HP }

@export var damage: int = 10
@export var attack_range: float = 200.0
@export var fire_rate: float = 1.0  # shots per second
@export var projectile_scene: PackedScene
@export var targeting_rule: TargetingRule = TargetingRule.NEAREST
@export var aoe_radius: float = 0.0  # 0 = single-target; >0 = aoe (Cannon Tower)
@export var slow_modifier: float = 0.0  # 0 = no slow; >0 = applies slow on hit (Mage Tower)
