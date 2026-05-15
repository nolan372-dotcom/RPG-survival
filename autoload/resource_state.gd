extends Node
##
## Tracks the player's wood / food / gold stockpile for the current campaign.
## Lives as an autoload because building placement, harvesting, training, and
## the upcoming day-tick all consume or produce these.
##
## Save/load comes in VS7 (Phase 2). For now, values reset on launch.
##

signal resources_changed(wood: int, food: int, gold: int)

const WOOD: StringName = &"wood"
const FOOD: StringName = &"food"
const GOLD: StringName = &"gold"

# Tunable starting values for the Concept-phase prototype. Replaced by meta upgrades + day-1 grant later.
const START_WOOD: int = 200
const START_FOOD: int = 100
const START_GOLD: int = 100

# Soft caps; harvest above this is wasted. Storehouse raises caps later.
const CAP_WOOD: int = 999
const CAP_FOOD: int = 999
const CAP_GOLD: int = 999

var wood: int = START_WOOD
var food: int = START_FOOD
var gold: int = START_GOLD


func _ready() -> void:
	_emit()


func reset() -> void:
	wood = START_WOOD
	food = START_FOOD
	gold = START_GOLD
	_emit()


# --- Queries ------------------------------------------------------------------

func get_amount(kind: StringName) -> int:
	match kind:
		WOOD: return wood
		FOOD: return food
		GOLD: return gold
	push_warning("ResourceState.get_amount: unknown kind %s" % String(kind))
	return 0


func can_afford(cost_wood: int = 0, cost_food: int = 0, cost_gold: int = 0) -> bool:
	return wood >= cost_wood and food >= cost_food and gold >= cost_gold


# --- Mutations ---------------------------------------------------------------

func try_spend(cost_wood: int = 0, cost_food: int = 0, cost_gold: int = 0) -> bool:
	if not can_afford(cost_wood, cost_food, cost_gold):
		return false
	wood -= cost_wood
	food -= cost_food
	gold -= cost_gold
	_emit()
	return true


func add(kind: StringName, amount: int) -> void:
	if amount == 0:
		return
	match kind:
		WOOD: wood = clamp(wood + amount, 0, CAP_WOOD)
		FOOD: food = clamp(food + amount, 0, CAP_FOOD)
		GOLD: gold = clamp(gold + amount, 0, CAP_GOLD)
		_:
			push_warning("ResourceState.add: unknown kind %s" % String(kind))
			return
	_emit()


func _emit() -> void:
	resources_changed.emit(wood, food, gold)
