class_name HeroData
extends Resource

@export var id: StringName
@export var display_name: String
@export var class_name_label: String  # "Knight" | "Rogue" | "Wizard"
@export var base_hp: int = 100
@export var base_damage: int = 10
@export var move_speed: float = 120.0
@export var ability_id: StringName
@export var passive_id: StringName
@export var animation_set: Resource  # CharacterAnimationSet
@export_multiline var lore: String = ""
