## Captures an overview screenshot of scenes/reference_map.tscn.
## Run windowed: godot --path . --script tools/reference_map_preview.gd
extends SceneTree

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene := (load("res://scenes/reference_map.tscn") as PackedScene).instantiate()
	root.add_child(scene)
	var cam: Camera2D = scene.get_node("Camera2D")
	cam.make_current()
	for i in 10:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png("res://tools/reference_map_overview.png")
	quit(0)
