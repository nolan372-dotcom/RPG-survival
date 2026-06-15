## Recreates the user's reference map (Stardew-style overview) as a fresh
## scene painted with tiles we already own. Writes scenes/reference_map.tscn.
## Run:
##   godot --headless --path . --script tools/paint_reference_map.gd
##
## 80x18 char grid, each char = 2x4 tiles -> 160x72 tiles (5120x2304 px),
## matching the reference's ~2.2:1 aspect. Origin at map center.
##
## Material translation (blockout fidelity — props/buildings come later):
##   ~ water (animated)   s sand     . grass      T forest (also snow stand-in)
##   : road (dirt)        = bridge/pier (dirt)    % farm plot (tilled soil)
##   # building footprint (dirt)     I island (grass)
extends SceneTree

const OUT_PATH := "res://scenes/reference_map.tscn"
const TILESET_PATH := "res://art/biomes/grasslands/world_tileset.tres"

const SRC_TERRAIN := 9
const SRC_BEACH := 4
const SRC_COAST := 7

var GRASS: Array[Vector2i] = [
	Vector2i(16, 2), Vector2i(17, 2), Vector2i(18, 2),
	Vector2i(16, 5), Vector2i(17, 5), Vector2i(18, 5),
	Vector2i(16, 8), Vector2i(17, 8),
]
var FOREST: Array[Vector2i] = [Vector2i(10, 1), Vector2i(10, 2)]
var DIRT: Array[Vector2i] = [
	Vector2i(32, 3), Vector2i(33, 3), Vector2i(34, 3),
	Vector2i(32, 4), Vector2i(33, 4), Vector2i(34, 4),
	Vector2i(32, 5), Vector2i(33, 5),
]
var FARM: Array[Vector2i] = [Vector2i(33, 7), Vector2i(34, 7)]
var SAND: Array[Vector2i] = [
	Vector2i(2, 2), Vector2i(3, 2), Vector2i(2, 3), Vector2i(3, 3),
]
const WATER := Vector2i(1, 0)

var T := "T"
var D := "."


func _build_map() -> PackedStringArray:
	var m := PackedStringArray()
	# r0: ocean | beach | snow forest, aqueduct, north-exit road
	m.append("~".repeat(7) + "ss" + T.repeat(20) + "~~" + T.repeat(10) + "::" + T.repeat(37))
	# r1-3: factory footprint (#) in the snow, aqueduct beside it
	m.append("~".repeat(7) + "ss" + T.repeat(10) + "#".repeat(9) + T + "~~" + T.repeat(10) + "::" + T.repeat(37))
	m.append("~".repeat(6) + "sss" + T.repeat(10) + "#".repeat(9) + T + "~~" + T.repeat(10) + "::" + T.repeat(37))
	m.append("~".repeat(6) + "ss" + D + T.repeat(10) + "#".repeat(9) + T + "~~" + T.repeat(10) + "::" + T.repeat(37))
	# r4: snow retreats; factory exit road (col 22)
	m.append("~".repeat(6) + "ss" + D.repeat(2) + T.repeat(8) + D.repeat(4) + "::" + D.repeat(5) + "~~" + D.repeat(10) + "::" + D.repeat(4) + T.repeat(33))
	# r5: meadow band; river enters (cols 49-50)
	m.append("~".repeat(5) + "ss" + D.repeat(15) + "::" + D.repeat(17) + "::" + D.repeat(6) + "~~" + D.repeat(15) + T.repeat(14))
	# r6: MAIN ROAD west-east with bridge over the river
	m.append("~".repeat(5) + "ss" + ":".repeat(42) + "==" + ":".repeat(6) + D.repeat(9) + T.repeat(14))
	# r7-9: farm plots west + east, river flowing south, right vertical road
	m.append("~".repeat(5) + "ss" + D.repeat(15) + "::" + D.repeat(7) + "%".repeat(8) + D.repeat(10) + "~~" + D.repeat(5) + "::" + D + "%".repeat(6) + D + T.repeat(14))
	m.append("~".repeat(5) + "ss" + D.repeat(15) + "::" + D.repeat(7) + "%".repeat(8) + D.repeat(10) + "~~" + D.repeat(2) + "##" + D + "::" + D + "%".repeat(6) + D + T.repeat(14))
	m.append("~".repeat(5) + "ss" + D.repeat(15) + "::" + D.repeat(7) + "%".repeat(8) + D.repeat(10) + "~~" + D.repeat(5) + "::" + D + "%".repeat(6) + D + T.repeat(14))
	# r10: small lake left-center
	m.append("~".repeat(5) + "ss" + D.repeat(15) + "::" + D + "~~~~" + D.repeat(20) + "~~" + D.repeat(5) + "::" + D.repeat(8) + T.repeat(14))
	# r11: pier into the ocean + spur road from beach
	m.append("~" + "=".repeat(5) + "ss" + ":".repeat(14) + "::" + D.repeat(25) + "~~" + D.repeat(5) + "::" + D.repeat(8) + T.repeat(14))
	# r12-15: pond (island r13), village house footprints, south farm plot
	m.append("~".repeat(4) + "ss" + D.repeat(16) + "::" + D.repeat(19) + "~".repeat(8) + D.repeat(2) + "##" + D + "::" + D + "%".repeat(6) + D + T.repeat(14))
	m.append("~".repeat(4) + "ss" + D.repeat(16) + "::" + D.repeat(19) + "~~" + "II" + "~~~~" + D.repeat(5) + "::" + D + "%".repeat(6) + D + T.repeat(14))
	m.append("~".repeat(4) + "ss" + D.repeat(16) + "::" + D.repeat(19) + "~".repeat(8) + D.repeat(5) + "::" + D.repeat(8) + T.repeat(14))
	m.append("~".repeat(4) + "ss" + D.repeat(16) + "::" + D.repeat(19) + D.repeat(2) + "~~~~" + D.repeat(7) + "::" + D.repeat(8) + T.repeat(14))
	# r16: BOTTOM ROAD connecting the two verticals
	m.append("~".repeat(4) + "ss" + D.repeat(16) + ":".repeat(36) + D.repeat(8) + T.repeat(14))
	# r17: south edge
	m.append("~".repeat(4) + "ss" + D.repeat(52) + T.repeat(22))
	return m


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var map := _build_map()
	var ok := true
	for i in map.size():
		if map[i].length() != 80:
			push_error("row %d has length %d (want 80)" % [i, map[i].length()])
			ok = false
	if not ok:
		quit(1)
		return

	var rows := map.size() # 18
	var root := Node2D.new()
	root.name = "ReferenceMap"
	var tm := TileMapLayer.new()
	tm.name = "TileMap"
	tm.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tm.tile_set = load(TILESET_PATH)
	root.add_child(tm)
	tm.owner = root
	# fit-to-screen camera so F6 shows the whole map
	var cam := Camera2D.new()
	cam.name = "Camera2D"
	cam.zoom = Vector2(0.18, 0.18)
	root.add_child(cam)
	cam.owner = root

	var rng := RandomNumberGenerator.new()
	rng.seed = 4242
	for row in rows:
		for col in 80:
			var ch := map[row][col]
			for dy in 4:
				for dx in 2:
					var pos := Vector2i(-80 + col * 2 + dx, -rows * 2 + row * 4 + dy)
					var src := SRC_TERRAIN
					var coord: Vector2i
					match ch:
						"~":
							src = SRC_COAST
							coord = WATER
						"s":
							src = SRC_BEACH
							coord = SAND[rng.randi() % SAND.size()]
						"T":
							coord = FOREST[rng.randi() % FOREST.size()]
						":", "=", "#":
							coord = DIRT[rng.randi() % DIRT.size()]
						"%":
							coord = FARM[rng.randi() % FARM.size()]
						_:
							coord = GRASS[rng.randi() % GRASS.size()]
					tm.set_cell(pos, src, coord)

	var out := PackedScene.new()
	var err := out.pack(root)
	if err != OK:
		push_error("pack failed: %d" % err)
		quit(1)
		return
	err = ResourceSaver.save(out, OUT_PATH)
	if err != OK:
		push_error("save failed: %d" % err)
		quit(1)
		return
	print("painted %d cells -> %s" % [tm.get_used_cells().size(), OUT_PATH])
	quit(0)
