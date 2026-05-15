class_name CurseData
extends Resource

enum Category { ENEMY, ECONOMY, DEFENSE, HERO }

@export var id: StringName
@export var display_name: String
@export var category: Category = Category.ENEMY
@export var effect_modifiers: Dictionary = {}  # stat_id -> modifier_value
@export_multiline var lore_text: String = ""
@export var card_art: Texture2D
@export_multiline var effect_summary: String = ""
