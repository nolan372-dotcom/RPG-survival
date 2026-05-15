extends Node
##
## ContentRegistry — autoload that loads all data-driven content at startup.
##
## Scans the shipped /data tree, then user://mods/, indexes everything by `id`.
## Mod resources with the same id as a shipped resource override it (warning logged).
## Unknown ids return null with a warning rather than crashing.
##

# Each category maps a folder under res://data/ to the kind of Resource expected.
# Order matters only for log readability.
const CATEGORIES: Array = [
	{"folder": "heroes",            "key": "heroes",            "type_name": "HeroData"},
	{"folder": "hero_abilities",    "key": "hero_abilities",    "type_name": "HeroAbilityData"},
	{"folder": "buildings",         "key": "buildings",         "type_name": "BuildingData"},
	{"folder": "walls",             "key": "walls",             "type_name": "WallData"},
	{"folder": "towers",            "key": "towers",            "type_name": "TowerData"},
	{"folder": "units",             "key": "units",             "type_name": "UnitData"},
	{"folder": "enemies",           "key": "enemies",           "type_name": "EnemyData"},
	{"folder": "bosses",            "key": "bosses",            "type_name": "BossData"},
	{"folder": "mini_bosses",       "key": "mini_bosses",       "type_name": "MiniBossData"},
	{"folder": "biomes",            "key": "biomes",            "type_name": "BiomeData"},
	{"folder": "biome_tilesets",    "key": "biome_tilesets",    "type_name": "BiomeTilesetData"},
	{"folder": "waves",             "key": "waves",             "type_name": "WaveData"},
	{"folder": "sieges",            "key": "sieges",            "type_name": "SiegeData"},
	{"folder": "heirlooms",         "key": "heirlooms",         "type_name": "HeirloomData"},
	{"folder": "curses",            "key": "curses",            "type_name": "CurseData"},
	{"folder": "quests",            "key": "quests",            "type_name": "QuestData"},
	{"folder": "waypoint_shrines",  "key": "waypoint_shrines",  "type_name": "WaypointShrineData"},
	{"folder": "resource_nodes",    "key": "resource_nodes",    "type_name": "ResourceNodeData"},
	{"folder": "meta_upgrades",     "key": "meta_upgrades",     "type_name": "MetaUpgradeData"},
]

const SHIPPED_ROOT: String = "res://data"
const MOD_ROOT: String = "user://mods"

# key (e.g. "heroes") -> { StringName id -> Resource }
var _registry: Dictionary = {}


func _ready() -> void:
	_registry.clear()
	for cat in CATEGORIES:
		_registry[cat.key] = {}

	var shipped_counts: Dictionary = {}
	for cat in CATEGORIES:
		shipped_counts[cat.key] = _scan_dir(SHIPPED_ROOT.path_join(cat.folder), cat.key, cat.type_name, false)

	# Mod folder scan: ensure user://mods exists then load on top of shipped content.
	_ensure_mod_root()
	var mod_counts: Dictionary = {}
	for cat in CATEGORIES:
		mod_counts[cat.key] = _scan_dir(MOD_ROOT.path_join(cat.folder), cat.key, cat.type_name, true)

	_log_startup_summary(shipped_counts, mod_counts)


# --- Typed accessors -----------------------------------------------------------

func get_hero(id: StringName) -> HeroData:               return _lookup("heroes", id)
func get_hero_ability(id: StringName) -> HeroAbilityData: return _lookup("hero_abilities", id)
func get_building(id: StringName) -> BuildingData:       return _lookup("buildings", id)
func get_wall(id: StringName) -> WallData:               return _lookup("walls", id)
func get_tower(id: StringName) -> TowerData:             return _lookup("towers", id)
func get_unit(id: StringName) -> UnitData:               return _lookup("units", id)
func get_enemy(id: StringName) -> EnemyData:             return _lookup("enemies", id)
func get_boss(id: StringName) -> BossData:               return _lookup("bosses", id)
func get_mini_boss(id: StringName) -> MiniBossData:      return _lookup("mini_bosses", id)
func get_biome(id: StringName) -> BiomeData:             return _lookup("biomes", id)
func get_biome_tileset(id: StringName) -> BiomeTilesetData: return _lookup("biome_tilesets", id)
func get_wave(id: StringName) -> WaveData:               return _lookup("waves", id)
func get_siege(id: StringName) -> SiegeData:             return _lookup("sieges", id)
func get_heirloom(id: StringName) -> HeirloomData:       return _lookup("heirlooms", id)
func get_curse(id: StringName) -> CurseData:             return _lookup("curses", id)
func get_quest(id: StringName) -> QuestData:             return _lookup("quests", id)
func get_shrine(id: StringName) -> WaypointShrineData:   return _lookup("waypoint_shrines", id)
func get_resource_node(id: StringName) -> ResourceNodeData: return _lookup("resource_nodes", id)
func get_meta_upgrade(id: StringName) -> MetaUpgradeData: return _lookup("meta_upgrades", id)

func all_of(category_key: String) -> Array:
	if not _registry.has(category_key):
		push_warning("ContentRegistry.all_of: unknown category %s" % category_key)
		return []
	return _registry[category_key].values()

func dump_summary() -> String:
	var lines: PackedStringArray = ["=== ContentRegistry contents ==="]
	for cat in CATEGORIES:
		var bucket: Dictionary = _registry[cat.key]
		lines.append("  %-18s  %3d entries" % [cat.key, bucket.size()])
		var keys: Array = bucket.keys()
		keys.sort()
		for k in keys:
			lines.append("    - %s" % String(k))
	return "\n".join(lines)


# --- Internals ----------------------------------------------------------------

func _lookup(category_key: String, id: StringName) -> Resource:
	var bucket: Dictionary = _registry.get(category_key, {})
	if bucket.has(id):
		return bucket[id]
	push_warning("ContentRegistry: unknown %s id '%s'" % [category_key, String(id)])
	return null

func _scan_dir(path: String, category_key: String, expected_type_name: String, is_mod: bool) -> int:
	if not DirAccess.dir_exists_absolute(path):
		return 0
	var loaded: int = 0
	var loaded_paths: Dictionary = {}  # canonical path -> true (dedupe .tres and .tres.remap for same resource)
	for entry in _list_files_recursive(path):
		var load_path: String = _resolve_loadable_path(entry)
		if load_path == "" or loaded_paths.has(load_path):
			continue
		var res: Resource = load(load_path)
		if res == null:
			push_warning("ContentRegistry: failed to load %s" % load_path)
			continue
		if not "id" in res:
			push_warning("ContentRegistry: %s has no `id` property, skipping" % load_path)
			continue
		var rid: StringName = res.get("id")
		if rid == &"":
			push_warning("ContentRegistry: %s has empty id, skipping" % load_path)
			continue
		var bucket: Dictionary = _registry[category_key]
		if is_mod and bucket.has(rid):
			push_warning("ContentRegistry: mod resource %s overrides shipped %s/%s" % [load_path, category_key, String(rid)])
		bucket[rid] = res
		loaded_paths[load_path] = true
		loaded += 1
	return loaded

# In editor builds the directory scan returns .tres / .res files directly.
# In exported builds the same resources show up as .tres.remap / .res.remap pointing at binary blobs.
# Map both forms to a load() path that Godot understands; ignore unrelated files.
func _resolve_loadable_path(entry: String) -> String:
	if entry.ends_with(".tres") or entry.ends_with(".res"):
		return entry
	if entry.ends_with(".tres.remap"):
		return entry.substr(0, entry.length() - ".remap".length())
	if entry.ends_with(".res.remap"):
		return entry.substr(0, entry.length() - ".remap".length())
	return ""

func _list_files_recursive(path: String) -> PackedStringArray:
	var results: PackedStringArray = []
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		return results
	dir.list_dir_begin()
	var entry: String = dir.get_next()
	while entry != "":
		if entry.begins_with("."):
			entry = dir.get_next()
			continue
		var full: String = path.path_join(entry)
		if dir.current_is_dir():
			results.append_array(_list_files_recursive(full))
		else:
			results.append(full)
		entry = dir.get_next()
	dir.list_dir_end()
	return results

func _ensure_mod_root() -> void:
	if DirAccess.dir_exists_absolute(MOD_ROOT):
		return
	var err: int = DirAccess.make_dir_recursive_absolute(MOD_ROOT)
	if err != OK:
		push_warning("ContentRegistry: failed to create mod root at %s (err=%d)" % [MOD_ROOT, err])

func _log_startup_summary(shipped: Dictionary, mods: Dictionary) -> void:
	var total_shipped: int = 0
	var total_mod: int = 0
	for cat in CATEGORIES:
		total_shipped += int(shipped.get(cat.key, 0))
		total_mod += int(mods.get(cat.key, 0))
	print("[ContentRegistry] loaded %d shipped + %d mod resources across %d categories" % [total_shipped, total_mod, CATEGORIES.size()])
	for cat in CATEGORIES:
		var s: int = int(shipped.get(cat.key, 0))
		var m: int = int(mods.get(cat.key, 0))
		if s > 0 or m > 0:
			print("  %-18s  shipped=%d  mod=%d" % [cat.key, s, m])
