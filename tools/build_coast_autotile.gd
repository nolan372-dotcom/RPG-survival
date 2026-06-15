## Builds art/biomes/grasslands/coast_autotile.tres — a 2-terrain (Grass/Water)
## corner-match autotile TileSet for painting islands by dragging.
##
## Source of truth: the ERW pack author's own Godot corner-Wang set
## (platform - grass(transparency) - coast-godot.tsx). Each wangtile's corner
## pattern is translated into Godot terrain peering bits.
##
## Run: godot --headless --path . --script tools/build_coast_autotile.gd
extends SceneTree

const OUT := "res://art/biomes/grasslands/coast_autotile.tres"
const COAST_PNG := "res://grasslands_2.0/Tilesets/coast-autotile-godot.png"
const GRASS_PNG := "res://grasslands_2.0/Tilesets/Tileset-Terrain.png"
const CLEAR_PNG := "res://grasslands_2.0/Tilesets/transparent32.png"

const GRASS := 0
const WATER := 1

# Coast sheet is 17 columns. Each entry: atlas coord (col,row) -> the 4 corner
# terrains [top_left, top_right, bottom_left, bottom_right].
# Derived from the .tsx wangtiles (color 1 = water/sea).
var COAST_TILES := [
	# single-corner water (convex grass points)
	{ "c": Vector2i(0, 1),  "tl": WATER, "tr": GRASS, "bl": GRASS, "br": GRASS }, # id17
	{ "c": Vector2i(0, 15), "tl": GRASS, "tr": WATER, "bl": GRASS, "br": GRASS }, # id255
	{ "c": Vector2i(0, 5),  "tl": GRASS, "tr": GRASS, "bl": WATER, "br": GRASS }, # id85
	{ "c": Vector2i(0, 10), "tl": GRASS, "tr": GRASS, "bl": GRASS, "br": WATER }, # id170
	# straight edges
	{ "c": Vector2i(0, 18), "tl": WATER, "tr": WATER, "bl": GRASS, "br": GRASS }, # id306 N
	{ "c": Vector2i(0, 13), "tl": GRASS, "tr": WATER, "bl": GRASS, "br": WATER }, # id221 E
	{ "c": Vector2i(0, 9),  "tl": GRASS, "tr": GRASS, "bl": WATER, "br": WATER }, # id153 S
	{ "c": Vector2i(0, 4),  "tl": WATER, "tr": GRASS, "bl": WATER, "br": GRASS }, # id68  W
	# diagonals
	{ "c": Vector2i(0, 19), "tl": WATER, "tr": GRASS, "bl": GRASS, "br": WATER }, # id323
	{ "c": Vector2i(0, 20), "tl": GRASS, "tr": WATER, "bl": WATER, "br": GRASS }, # id340
	# three-corner water (concave grass corners)
	{ "c": Vector2i(0, 2),  "tl": WATER, "tr": WATER, "bl": WATER, "br": GRASS }, # id34
	{ "c": Vector2i(0, 6),  "tl": WATER, "tr": GRASS, "bl": WATER, "br": WATER }, # id102
	{ "c": Vector2i(0, 11), "tl": GRASS, "tr": WATER, "bl": WATER, "br": WATER }, # id187
	{ "c": Vector2i(0, 16), "tl": WATER, "tr": WATER, "bl": GRASS, "br": WATER }, # id272
]

# plain grass interior (all-grass corners) from the terrain sheet
const GRASS_CELL := Vector2i(16, 2)


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var coast_tex: Texture2D = load(COAST_PNG)
	var grass_tex: Texture2D = load(GRASS_PNG)
	var clear_tex: Texture2D = load(CLEAR_PNG)
	if coast_tex == null or grass_tex == null or clear_tex == null:
		push_error("texture load failed (coast=%s grass=%s clear=%s)" % [coast_tex, grass_tex, clear_tex])
		quit(1)
		return

	var ts := TileSet.new()
	ts.tile_size = Vector2i(32, 32)

	# terrain set: corner matching, two terrains
	ts.add_terrain_set()
	ts.set_terrain_set_mode(0, TileSet.TERRAIN_MODE_MATCH_CORNERS)
	ts.add_terrain(0)
	ts.add_terrain(0)
	ts.set_terrain_name(0, GRASS, "Grass")
	ts.set_terrain_color(0, GRASS, Color(0.36, 0.72, 0.30))
	ts.set_terrain_name(0, WATER, "Water")
	ts.set_terrain_color(0, WATER, Color(0.25, 0.62, 0.92))

	# --- coast atlas source ---
	var coast_src := TileSetAtlasSource.new()
	coast_src.texture = coast_tex
	coast_src.texture_region_size = Vector2i(32, 32)
	for t: Dictionary in COAST_TILES:
		var c: Vector2i = t["c"]
		coast_src.create_tile(c)
		var td: TileData = coast_src.get_tile_data(c, 0)
		td.terrain_set = 0
		# center terrain = majority corner (cosmetic in corner mode)
		var nwater := int(t["tl"] == WATER) + int(t["tr"] == WATER) + int(t["bl"] == WATER) + int(t["br"] == WATER)
		td.terrain = WATER if nwater >= 3 else GRASS
		td.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER, t["tl"])
		td.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER, t["tr"])
		td.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER, t["bl"])
		td.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER, t["br"])
	ts.add_source(coast_src, 0)

	# --- grass interior source ---
	var grass_src := TileSetAtlasSource.new()
	grass_src.texture = grass_tex
	grass_src.texture_region_size = Vector2i(32, 32)
	grass_src.create_tile(GRASS_CELL)
	var gd: TileData = grass_src.get_tile_data(GRASS_CELL, 0)
	gd.terrain_set = 0
	gd.terrain = GRASS
	gd.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER, GRASS)
	gd.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER, GRASS)
	gd.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER, GRASS)
	gd.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER, GRASS)
	ts.add_source(grass_src, 1)

	# --- open-water source ---
	# Transparent tile = the WATER terrain's "open ocean" piece. It reveals the
	# water base layer underneath (and matches the coast tiles' transparent
	# water edges). An opaque water tile (id 1 = atlas (1,0) on the coast sheet)
	# is also registered, WITHOUT terrain, as a plain base-layer fill.
	var water_src := TileSetAtlasSource.new()
	water_src.texture = clear_tex
	water_src.texture_region_size = Vector2i(32, 32)
	water_src.create_tile(Vector2i(0, 0))
	var wd: TileData = water_src.get_tile_data(Vector2i(0, 0), 0)
	wd.terrain_set = 0
	wd.terrain = WATER
	wd.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER, WATER)
	wd.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER, WATER)
	wd.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER, WATER)
	wd.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER, WATER)
	ts.add_source(water_src, 2)

	# opaque base-fill water (no terrain) — for the bottom layer
	var base_src := TileSetAtlasSource.new()
	base_src.texture = coast_tex
	base_src.texture_region_size = Vector2i(32, 32)
	base_src.create_tile(Vector2i(1, 0))
	ts.add_source(base_src, 3)

	var err := ResourceSaver.save(ts, OUT)
	if err != OK:
		push_error("save failed: %d" % err)
		quit(1)
		return
	print("OK wrote %s  (%d coast tiles + 1 grass)" % [OUT, COAST_TILES.size()])
	quit(0)
