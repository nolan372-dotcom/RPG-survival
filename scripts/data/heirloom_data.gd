class_name HeirloomData
extends Resource

enum Rarity { COMMON = 0, RARE = 1, EPIC = 2 }
enum ClassRestriction { KNIGHT, ROGUE, WIZARD }

@export var id: StringName
@export var display_name: String
@export var class_restriction: ClassRestriction = ClassRestriction.KNIGHT
@export var rarity: Rarity = Rarity.COMMON
@export var effect_modifiers: Dictionary = {}  # stat_id -> additive_or_multiplicative_value
@export_multiline var lore_text: String = ""
@export var icon: Texture2D
@export_multiline var effect_summary: String = ""
