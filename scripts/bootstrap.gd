extends Node2D
##
## Bootstrap scene — temporary entry point that confirms the project boots,
## ContentRegistry loaded everything, and the F1 debug dump works.
## Replace with a proper main menu in Phase 2.
##

@onready var label: Label = $UI/Label

func _ready() -> void:
	_refresh_label()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_dump"):
		print(ContentRegistry.dump_summary())
		_refresh_label()

func _refresh_label() -> void:
	if label == null:
		return
	var counts: PackedStringArray = []
	for cat in ContentRegistry.CATEGORIES:
		var n: int = ContentRegistry.all_of(cat.key).size()
		if n > 0:
			counts.append("%s: %d" % [cat.key, n])
	var summary: String = "\n".join(counts) if counts.size() > 0 else "(no content loaded yet)"
	label.text = "Crown & Wall — bootstrap\n\nContentRegistry:\n%s\n\nPress F1 to dump registry to console." % summary
