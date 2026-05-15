class_name WaypointShrineData
extends Resource

@export var id: StringName
@export var display_name: String
@export var biome_id: StringName
@export var location: Vector2
@export var activation_encounter: WaveData  # the small encounter that must be cleared
@export var always_activated: bool = false  # castle & village shrines
@export var icon: Texture2D
