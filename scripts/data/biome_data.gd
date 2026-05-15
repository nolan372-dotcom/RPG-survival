class_name BiomeData
extends Resource

enum Tier { HOME = 0, STARTER = 1, EARLY = 2, MID = 3, LATE = 4, ENDGAME_APPROACH = 5, ENDGAME = 6 }
enum Layer { SURFACE, UNDERGROUND }

@export var id: StringName
@export var display_name: String
@export var tier: Tier = Tier.STARTER
@export var layer: Layer = Layer.SURFACE
@export var tileset_ref: BiomeTilesetData
@export var music_day: AudioStream
@export var music_night: AudioStream
@export var ambient_palette: Array[Color] = []
@export var resource_node_density: float = 1.0
@export var enemy_spawn_density: float = 1.0
@export var enemy_pool: Array[Resource] = []  # Array of EnemyData
@export var mini_boss_pool: Array[Resource] = []  # Array of MiniBossData
@export var quest_pool: Array[Resource] = []  # Array of QuestData
@export var shrine_locations: Array[Vector2] = []
@export_multiline var description: String = ""
