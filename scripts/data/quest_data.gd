class_name QuestData
extends Resource

enum ObjectiveType { KILL, ESCORT, DELIVER, RITUAL, EXPLORE }

@export var id: StringName
@export var display_name: String
@export var biome_id: StringName
@export var prerequisites: Array[StringName] = []  # ids of quests that must be complete
@export var objective_type: ObjectiveType = ObjectiveType.KILL
@export var objective_parameters: Dictionary = {}
@export var reward_table: Dictionary = {}  # "heirloom"|"gold"|"food"|"wood" -> amount or HeirloomData
@export_multiline var giver_dialogue: String = ""
@export_multiline var completion_dialogue: String = ""
