class_name BuildingData
extends Resource

enum FunctionType {
	RESOURCE,    # Farm, Lumber Mill, Market, Storehouse
	MILITARY,    # Barracks, Mercenary Camp, Watchtower
	DEFENSE,     # Wall, Gate, Towers
	UTILITY      # Forge, Mason's Workshop, Heirloom Altar
}

@export var id: StringName
@export var display_name: String
@export var footprint_x: int = 1
@export var footprint_y: int = 1
@export var cost_wood: int = 0
@export var cost_food: int = 0
@export var cost_gold: int = 0
@export var hp: int = 100
@export var function_type: FunctionType = FunctionType.RESOURCE
@export var parameters: Dictionary = {}
@export var icon: Texture2D
@export var sprite: Texture2D
@export_multiline var description: String = ""
