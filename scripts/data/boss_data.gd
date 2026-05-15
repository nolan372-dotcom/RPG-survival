class_name BossData
extends EnemyData

@export var siege_number: int = 1  # 1, 2, or 3
@export var phase_count: int = 3
@export var phase_hp_thresholds: PackedFloat32Array = PackedFloat32Array([0.66, 0.33])  # fraction of HP at which to transition to next phase
@export var telegraph_data: Dictionary = {}  # attack_id -> windup_seconds
@export var retinue: Array[EnemyData] = []
@export var boss_music: AudioStream
@export var guaranteed_heirloom_rarity: int = 1  # 0=Common, 1=Rare, 2=Epic
