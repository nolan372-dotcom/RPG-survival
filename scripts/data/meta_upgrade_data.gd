class_name MetaUpgradeData
extends Resource

enum UpgradeCategory { STARTING_RESOURCES, CASTLE, HERO, BUILDINGS, COSMETIC }

@export var id: StringName
@export var display_name: String
@export var category: UpgradeCategory = UpgradeCategory.STARTING_RESOURCES
@export var tier_effects: Array[float] = []  # parallel: [tier_1_effect, tier_2_effect, ...]
@export var tier_costs: Array[int] = []      # parallel: crown cost per tier
@export var stat_id: StringName              # which stat to modify
@export_multiline var description: String = ""
@export var icon: Texture2D
