class_name WaveData
extends Resource

@export var id: StringName
@export var display_name: String
@export var enemy_composition: Array[EnemyData] = []
@export var enemy_counts: Array[int] = []  # parallel to composition
@export var spawn_cadence: float = 1.0  # seconds between spawns
@export var spawn_lanes: PackedInt32Array = PackedInt32Array([0])  # indices into castle plot's spawn point array
@export var duration: float = 60.0
@export var is_boss_wave: bool = false
@export var boss_ref: BossData
