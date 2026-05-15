class_name EnemyData
extends Resource

enum ArmorType { NONE, LIGHT, HEAVY, MAGICAL }

@export var id: StringName
@export var display_name: String
@export var hp: int = 30
@export var speed: float = 60.0
@export var damage: int = 8
@export var attack_range: float = 24.0
@export var armor_type: ArmorType = ArmorType.NONE
@export var drop_table: Dictionary = {}  # { "wood": [min,max], "food": [min,max], "gold": [min,max] }
@export var sprite_frames: SpriteFrames
@export var biome_origin: StringName  # which biome this enemy comes from
@export_multiline var codex_entry: String = ""
