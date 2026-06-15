## Paints the organic grasslands blockout into scenes/grasslands.tscn.
## Run headless:
##   godot --headless --path . --script tools/paint_grasslands_blockout.gd
##
## Layout: 80x40 char grid, each char = 2x4 tiles -> 160x160 tiles (5120px),
## origin at map center. Chars:
##   T forest  . grass  ~ water  s sand  : path  = bridge  o ford
##   # cliff(blockout=dirt)  / ramp  H cave hole  % farm soil  f fence(grass)
##   W shrine  S spawn  R ruin  * grove  A hut  D wolf den  c camp  C camp
##   G gold  b berries  t trees   (everything entity-like paints as grass;
##   props/entities come later)
extends SceneTree

const SCENE_PATH := "res://scenes/grasslands.tscn"
const TILESET_PATH := "res://art/biomes/grasslands/world_tileset.tres"

const SRC_TERRAIN := 9 # Tileset-Terrain.png
const SRC_BEACH := 4   # beach - standard - no thick foam
const SRC_COAST := 7   # coast platform (animated water at 1,0)

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
const WATER := Vector2i(1, 0) # animated 5-frame tile

var T := "T"
var D := "."


func _build_map() -> PackedStringArray:
	var m := PackedStringArray()
	m.append(T.repeat(48) + D.repeat(6) + T.repeat(14) + "sss" + "~".repeat(9))
	m.append(T.repeat(42) + D.repeat(6) + "::" + D.repeat(4) + T.repeat(12) + "sss" + "~".repeat(11))
	m.append("TTT" + D.repeat(22) + T.repeat(20) + ".." + "::" + D.repeat(4) + T.repeat(13) + "sss" + "~".repeat(11))
	m.append("TT." + "#".repeat(13) + D.repeat(9) + T.repeat(20) + ".." + "::" + D.repeat(5) + "C".repeat(11) + "." + "sss" + "~".repeat(11))
	m.append("TT." + "#..GG.......#" + D.repeat(3) + "DDDDDD" + T.repeat(20) + "::" + D.repeat(7) + "C".repeat(11) + "." + "sss" + "~".repeat(11))
	m.append("TT." + "#.....HH....#" + D.repeat(3) + "DDDDDD" + T.repeat(20) + "::" + D.repeat(7) + "C".repeat(11) + "." + "sss" + "~".repeat(11))
	m.append("TT." + "#.........../" + D.repeat(3) + "DDDDDD" + T.repeat(20) + "::" + D.repeat(7) + "C".repeat(11) + "." + "sss" + "~".repeat(11))
	m.append("TT." + "#".repeat(13) + D.repeat(9) + T.repeat(18) + "::" + D.repeat(10) + "C".repeat(9) + ".." + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(41) + "::" + D.repeat(8) + "HH" + D.repeat(11) + "sss" + "~".repeat(11))
	m.append("TT" + T.repeat(11) + "." + T.repeat(6) + D.repeat(23) + "::" + D.repeat(21) + "sss" + "~".repeat(11))
	m.append("TT" + ".GG......." + T.repeat(8) + D.repeat(23) + "::" + ".." + "RR" + D.repeat(17) + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(10) + T.repeat(8) + D.repeat(23) + "::" + ".." + "RR" + D.repeat(17) + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(8) + T.repeat(10) + D.repeat(19) + ".." + "::" + D.repeat(23) + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(36) + ".." + "::" + D.repeat(8) + "bb" + D.repeat(14) + "sss" + "~".repeat(11))
	m.append("~".repeat(8) + "oo" + "~".repeat(8) + D.repeat(20) + ".." + "::" + D.repeat(24) + "sss" + "~".repeat(11))
	m.append("~".repeat(18) + D.repeat(20) + ".." + "::" + D.repeat(24) + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(10) + "~".repeat(18) + D.repeat(8) + ".." + "::" + D.repeat(16) + "T" + "." + "******" + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(10) + "~".repeat(18) + D.repeat(8) + ".." + "::" + D.repeat(16) + "TT" + "******" + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(22) + "~".repeat(16) + "==" + "~".repeat(6) + D.repeat(18) + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(22) + "~".repeat(16) + "==" + "~".repeat(6) + D.repeat(18) + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(36) + ".." + "::" + ".." + "~".repeat(20) + ".." + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(36) + ".." + "::" + ".." + "~".repeat(20) + ".." + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(36) + ".." + "::" + D.repeat(8) + "~".repeat(30))
	m.append("TT" + D.repeat(36) + ".." + "::" + D.repeat(8) + "~".repeat(30))
	m.append("TT" + T.repeat(12) + D.repeat(24) + ".." + "::" + D.repeat(12) + "bb" + D.repeat(10) + "sss" + "~".repeat(11))
	m.append("TT" + "T" + "ccccc" + T.repeat(6) + D.repeat(24) + ".." + "::" + D.repeat(24) + "sss" + "~".repeat(11))
	m.append("TT" + "T" + "ccccc" + T.repeat(5) + "." + D.repeat(24) + ".." + "::" + D.repeat(24) + "sss" + "~".repeat(11))
	m.append("TT" + T.repeat(12) + D.repeat(24) + ".." + "::" + D.repeat(8) + "tt" + D.repeat(14) + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(18) + "f".repeat(17) + "." + ".." + "::" + D.repeat(24) + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(18) + "f" + "AA..%%%..AA..%%" + "f" + "." + ".." + "::" + D.repeat(24) + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(18) + "f" + ".%%%..HH..%%%.." + "f" + "." + ".." + "::" + D.repeat(24) + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(18) + "f" + "AA....AA....AA." + "f" + "." + ".." + "::" + D.repeat(24) + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(18) + "f".repeat(8) + ".." + "f".repeat(7) + "." + ".." + "::" + D.repeat(24) + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(36) + ".." + "::" + D.repeat(24) + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(36) + ".." + "::" + "." + "W" + D.repeat(22) + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(36) + ".." + "SS" + D.repeat(24) + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(36) + ".." + "::" + D.repeat(24) + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(36) + ".." + "::" + D.repeat(24) + "sss" + "~".repeat(11))
	m.append("TT" + D.repeat(36) + ".." + "::" + D.repeat(24) + "sss" + "~".repeat(11))
	m.append(T.repeat(38) + D.repeat(6) + T.repeat(22) + "sss" + "~".repeat(11))
	return m


func _init() -> void:
	# defer: in --script mode, loading scenes during _init happens before
	# autoloads register, which breaks compilation of scripts that reference
	# them (grasslands.gd, hero.gd) and silently strips them from the scene
	call_deferred("_run")


func _run() -> void:
	var map := _build_map()
	var ok := true
	for i in map.size():
		if map[i].length() != 80:
			push_error("row %d has length %d (want 80)" % [i, map[i].length()])
			ok = false
	if map.size() != 40:
		push_error("map has %d rows (want 40)" % map.size())
		ok = false
	if not ok:
		quit(1)
		return

	var packed: PackedScene = load(SCENE_PATH)
	var scene := packed.instantiate()
	# pack()/save roundtrip outside the editor can silently drop the root
	# node's script — re-attach it so the scene keeps its behavior
	if scene.get_script() == null:
		scene.set_script(load("res://scripts/grasslands.gd"))
	var tm: TileMapLayer = scene.get_node("Map/TileMap")
	var ts: TileSet = load(TILESET_PATH)
	tm.tile_set = ts
	tm.clear()

	# sanity: every paint coord must exist in its atlas source
	var checks := {
		SRC_TERRAIN: GRASS + FOREST + DIRT + FARM,
		SRC_BEACH: SAND,
		SRC_COAST: [WATER],
	}
	for src_id: int in checks:
		var src := ts.get_source(src_id) as TileSetAtlasSource
		for coord: Vector2i in checks[src_id]:
			if not src.has_tile(coord):
				push_error("source %d missing tile %s" % [src_id, coord])
				ok = false
	if not ok:
		quit(1)
		return

	var rng := RandomNumberGenerator.new()
	rng.seed = 1337
	var counts := {}
	for row in 40:
		for col in 80:
			var ch := map[row][col]
			for dy in 4:
				for dx in 2:
					var pos := Vector2i(-80 + col * 2 + dx, -80 + row * 4 + dy)
					var src := SRC_TERRAIN
					var coord: Vector2i
					match ch:
						"~":
							src = SRC_COAST
							coord = WATER
						"s", "o":
							src = SRC_BEACH
							coord = SAND[rng.randi() % SAND.size()]
						"T":
							coord = FOREST[rng.randi() % FOREST.size()]
						":", "=", "#", "/", "H":
							coord = DIRT[rng.randi() % DIRT.size()]
						"%":
							coord = FARM[rng.randi() % FARM.size()]
						_:
							coord = GRASS[rng.randi() % GRASS.size()]
					tm.set_cell(pos, src, coord)
					counts[ch] = counts.get(ch, 0) + 1

	# painted terrain replaces the flat-green TextureRect and mockup underlay
	(scene.get_node("Ground") as CanvasItem).visible = false
	(scene.get_node("Map/Reference") as CanvasItem).visible = false

	var out := PackedScene.new()
	var err := out.pack(scene)
	if err != OK:
		push_error("pack failed: %d" % err)
		quit(1)
		return
	err = ResourceSaver.save(out, SCENE_PATH)
	if err != OK:
		push_error("save failed: %d" % err)
		quit(1)
		return
	print("painted %d cells -> %s" % [tm.get_used_cells().size(), SCENE_PATH])
	print("per-char tile counts: ", counts)
	quit(0)
