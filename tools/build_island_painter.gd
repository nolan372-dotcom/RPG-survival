## Builds scenes/island_painter.tscn — a ready-to-use canvas for drag-painting
## islands with the coast autotiler. Two layers both using coast_autotile.tres:
##   WaterBase : opaque water fill (the bottom)
##   Land      : pre-filled with Water terrain; drag the Grass terrain to carve
##               islands. Coast autotiles; transparent water reveals the base.
##
## Run: godot --headless --path . --script tools/build_island_painter.gd
extends SceneTree

const OUT := "res://scenes/island_painter.tscn"
const TS := "res://art/biomes/grasslands/coast_autotile.tres"
const WATER := 1
const X0 := -40
const X1 := 40
const Y0 := -25
const Y1 := 25


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var ts: TileSet = load(TS)
	var root := Node2D.new()
	root.name = "IslandPainter"

	var base := TileMapLayer.new()
	base.name = "WaterBase"
	base.tile_set = ts
	base.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.add_child(base)
	base.owner = root

	var land := TileMapLayer.new()
	land.name = "Land"
	land.tile_set = ts
	land.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.add_child(land)
	land.owner = root

	var all: Array[Vector2i] = []
	for y in range(Y0, Y1):
		for x in range(X0, X1):
			base.set_cell(Vector2i(x, y), 3, Vector2i(1, 0))
			all.append(Vector2i(x, y))
	land.set_cells_terrain_connect(all, 0, WATER, false)

	var cam := Camera2D.new()
	cam.name = "Camera2D"
	cam.zoom = Vector2(0.5, 0.5)
	root.add_child(cam)
	cam.owner = root

	var packed := PackedScene.new()
	var err := packed.pack(root)
	if err != OK:
		push_error("pack failed: %d" % err)
		quit(1)
		return
	err = ResourceSaver.save(packed, OUT)
	if err != OK:
		push_error("save failed: %d" % err)
		quit(1)
		return
	print("OK wrote %s  (%dx%d water canvas, ready to paint Grass)" % [OUT, X1 - X0, Y1 - Y0])
	quit(0)
