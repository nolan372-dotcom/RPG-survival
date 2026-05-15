class_name MiniBossData
extends EnemyData

@export var biome_id: StringName
@export var is_mandatory: bool = false
@export var heirloom_drop_pool: Array[Resource] = []  # Array of HeirloomData
@export var guaranteed_heirloom_rarity: int = 0  # 0=Common, 1=Rare, 2=Epic
@export var encounter_music: AudioStream
