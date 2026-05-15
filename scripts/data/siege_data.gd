class_name SiegeData
extends Resource

@export var id: StringName
@export var display_name: String
@export var day_number: int = 7  # 7, 14, or 21
@export var waves: Array[WaveData] = []
@export var boss_ref: BossData
@export var music_ref: AudioStream
@export var pre_siege_horn: AudioStream
@export_multiline var briefing_text: String = ""
