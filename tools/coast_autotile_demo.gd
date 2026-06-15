## Verifies coast_autotile.tres: fills water, then paints a grass island via
## the terrain system (the same call the drag-paint brush uses). Screenshots it.
## Run windowed: godot --path . --script tools/coast_autotile_demo.gd
extends SceneTree

const TS := "res://art/biomes/grasslands/coast_autotile.tres"
const GRASS := 0
const WATER := 1
const W := 40
const H := 26


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var ts: TileSet = load(TS)

	# bottom layer: opaque water base fill (source 3, tile (1,0)), everywhere
	var base := TileMapLayer.new()
	base.tile_set = ts
	base.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.add_child(base)
	for y in H:
		for x in W:
			base.set_cell(Vector2i(x, y), 3, Vector2i(1, 0))

	# top layer: the terrain (drag-to-paint islands)
	var layer := TileMapLayer.new()
	layer.tile_set = ts
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.add_child(layer)

	# 1) fill the whole rect with water terrain (transparent — base shows through)
	var water_cells: Array[Vector2i] = []
	for y in H:
		for x in W:
			water_cells.append(Vector2i(x, y))
	layer.set_cells_terrain_connect(water_cells, 0, WATER, false)

	# 2) carve a grass island (irregular blob) with the grass terrain
	var cx := 20.0
	var cy := 13.0
	var grass_cells: Array[Vector2i] = []
	for y in H:
		for x in W:
			var dx := (x - cx) / 13.0
			var dy := (y - cy) / 8.0
			# wobble the radius so the coast isn't a perfect ellipse
			var wob := 0.18 * sin(x * 0.9) + 0.15 * cos(y * 1.1)
			if dx * dx + dy * dy < 0.8 + wob:
				grass_cells.append(Vector2i(x, y))
	layer.set_cells_terrain_connect(grass_cells, 0, GRASS, false)

	# small detached islet to exercise convex corners
	for cell in [Vector2i(5, 4), Vector2i(6, 4), Vector2i(5, 5), Vector2i(6, 5)]:
		pass
	layer.set_cells_terrain_connect(
		[Vector2i(5, 4), Vector2i(6, 4), Vector2i(5, 5), Vector2i(6, 5)] as Array[Vector2i],
		0, GRASS, false)

	print("island painted: %d grass cells over %dx%d water" % [grass_cells.size(), W, H])

	# camera to frame the map
	var cam := Camera2D.new()
	cam.position = Vector2(W * 16, H * 16)
	cam.zoom = Vector2(0.7, 0.7)
	root.add_child(cam)
	cam.make_current()
	for i in 8:
		await process_frame
	root.get_viewport().get_texture().get_image().save_png("res://tools/coast_autotile_demo.png")
	quit(0)
