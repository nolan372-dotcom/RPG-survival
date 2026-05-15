class_name HeroAbilityData
extends Resource

enum AbilityType { BLOCK_PARRY, DASH, BLINK, OTHER }

@export var id: StringName
@export var display_name: String
@export var type: AbilityType = AbilityType.OTHER
@export var cooldown: float = 0.0
@export var parameters: Dictionary = {}
@export_multiline var description: String = ""
