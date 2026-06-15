## Captures preview screenshots of the painted grasslands blockout.
## Run windowed (NOT headless — needs real rendering):
##   godot --path . --script tools/blockout_preview.gd
extends SceneTree

func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var scene := (load("res://scenes/grasslands.tscn") as PackedScene).instantiate()
	root.add_child(scene)
	var cam := Camera2D.new()
	scene.add_child(cam)
	cam.make_current()

	# whole-map overview (map is 5120px tall; 540 / 0.105 covers it)
	cam.position = Vector2.ZERO
	cam.zoom = Vector2(0.105, 0.105)
	for i in 10:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png("res://tools/blockout_overview.png")

	# close-up: village / spawn area
	cam.position = Vector2(0, 1700)
	cam.zoom = Vector2(1, 1)
	for i in 5:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png("res://tools/blockout_close.png")

	# close-up: bridge over the river
	cam.position = Vector2(32, -160)
	for i in 5:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png("res://tools/blockout_bridge.png")
	quit(0)
