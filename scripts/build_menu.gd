class_name BuildMenu
extends Control
##
## Placeholder build menu. A row of buttons at the bottom of the screen. Each
## button starts placement of a specific BuildingData when clicked.
##

signal build_button_pressed(data: BuildingData)

@onready var farm_button: Button = $HBoxContainer/FarmButton
@onready var wall_button: Button = $HBoxContainer/WallButton
@onready var tower_button: Button = $HBoxContainer/TowerButton
@onready var storehouse_button: Button = $HBoxContainer/StorehouseButton

var _farm: BuildingData
var _wall: BuildingData
var _tower: BuildingData
var _storehouse: BuildingData


func _ready() -> void:
	_farm = ContentRegistry.get_building(&"farm")
	_wall = ContentRegistry.get_wall(&"wall_segment")
	_tower = ContentRegistry.get_tower(&"archer_tower")
	_storehouse = ContentRegistry.get_building(&"storehouse")
	_relabel_button(farm_button, _farm)
	_relabel_button(wall_button, _wall)
	_relabel_button(tower_button, _tower)
	_relabel_button(storehouse_button, _storehouse)
	farm_button.pressed.connect(_on_farm_pressed)
	wall_button.pressed.connect(_on_wall_pressed)
	tower_button.pressed.connect(_on_tower_pressed)
	storehouse_button.pressed.connect(_on_storehouse_pressed)
	ResourceState.resources_changed.connect(_on_resources_changed)
	_on_resources_changed(ResourceState.wood, ResourceState.food, ResourceState.gold)


func _relabel_button(b: Button, data: BuildingData) -> void:
	if b == null or data == null:
		return
	b.text = "%s\n%s" % [data.display_name, _cost_string(data)]


static func _cost_string(data: BuildingData) -> String:
	var parts: PackedStringArray = []
	if data.cost_wood > 0:
		parts.append("%dW" % data.cost_wood)
	if data.cost_food > 0:
		parts.append("%dF" % data.cost_food)
	if data.cost_gold > 0:
		parts.append("%dG" % data.cost_gold)
	if parts.is_empty():
		return "free"
	return " / ".join(parts)


# --- Buttons -----------------------------------------------------------------

func _on_farm_pressed() -> void:
	if _farm != null:
		build_button_pressed.emit(_farm)

func _on_wall_pressed() -> void:
	if _wall != null:
		build_button_pressed.emit(_wall)

func _on_tower_pressed() -> void:
	if _tower != null:
		build_button_pressed.emit(_tower)

func _on_storehouse_pressed() -> void:
	if _storehouse != null:
		build_button_pressed.emit(_storehouse)


# --- Resource-driven enable/disable -----------------------------------------

func _on_resources_changed(_wood: int, _food: int, _gold: int) -> void:
	_update_button_state(farm_button, _farm)
	_update_button_state(wall_button, _wall)
	_update_button_state(tower_button, _tower)
	_update_button_state(storehouse_button, _storehouse)

func _update_button_state(b: Button, data: BuildingData) -> void:
	if b == null or data == null:
		b.disabled = true
		return
	b.disabled = not ResourceState.can_afford(data.cost_wood, data.cost_food, data.cost_gold)
