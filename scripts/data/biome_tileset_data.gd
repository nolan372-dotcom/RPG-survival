class_name BiomeTilesetData
extends Resource

@export var id: StringName
@export var display_name: String
@export var tileset: TileSet
@export var transition_tiles: Dictionary = {}  # neighbor_biome_id -> TileSet for transition
@export var ambient_decoration_scenes: Array[PackedScene] = []
