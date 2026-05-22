class_name HeroSpriteController
extends AnimatedSprite2D
##
## Drives the Knight's visual state. This Knight art ships left- AND
## right-facing versions of every animation, stacked as two rows in each
## sheet: row 0 faces right, row 1 faces left. Frames are 96x84.
##
## For each state we build "<state>_right" and "<state>_left" animations and
## play whichever matches the current facing — no horizontal flipping.
##
## States the Hero requests via play_state(): idle, walk, melee,
## block_start, block_mid, hurt, die. The three ATTACK sheets cycle
## 1 -> 2 -> 3 on each fresh melee swing.
##

const FRAME_W: int = 96
const FRAME_H: int = 84
const ROW_RIGHT: int = 0
const ROW_LEFT: int = 1

const SHEET_IDLE: Texture2D = preload("res://art/characters/knight/knight-idle.png")
const SHEET_RUN: Texture2D = preload("res://art/characters/knight/knight-run.png")
const SHEET_ATTACK_1: Texture2D = preload("res://art/characters/knight/knight-attack-1.png")
const SHEET_ATTACK_2: Texture2D = preload("res://art/characters/knight/knight-attack-2.png")
const SHEET_ATTACK_3: Texture2D = preload("res://art/characters/knight/knight-attack-3.png")
const SHEET_DEFEND: Texture2D = preload("res://art/characters/knight/knight-defend.png")
const SHEET_HURT: Texture2D = preload("res://art/characters/knight/knight-hurt.png")
const SHEET_DEATH: Texture2D = preload("res://art/characters/knight/knight-death.png")

signal animation_completed(state: StringName)

var _current_state: StringName = &"idle"
var _facing_left: bool = false
var _attack_cycle: int = -1  # advances to 0/1/2 on each fresh melee swing


func _ready() -> void:
	rebuild()
	if not animation_finished.is_connected(_on_animation_finished):
		animation_finished.connect(_on_animation_finished)
	play_state(&"idle")


## Build the SpriteFrames — a left and right variant of every state.
func rebuild() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	_add_state(frames, &"idle", SHEET_IDLE, 8.0, true)
	_add_state(frames, &"walk", SHEET_RUN, 12.0, true)
	_add_state(frames, &"melee1", SHEET_ATTACK_1, 13.0, false)
	_add_state(frames, &"melee2", SHEET_ATTACK_2, 13.0, false)
	_add_state(frames, &"melee3", SHEET_ATTACK_3, 13.0, false)
	_add_state(frames, &"block_start", SHEET_DEFEND, 30.0, false)
	_add_state(frames, &"hurt", SHEET_HURT, 20.0, false)
	_add_state(frames, &"die", SHEET_DEATH, 10.0, false)
	# block_mid: the held block pose — the last DEFEND frame, per direction.
	_add_held_state(frames, &"block_mid", SHEET_DEFEND)
	sprite_frames = frames


## Builds "<base>_right" from sheet row 0 and "<base>_left" from row 1.
func _add_state(frames: SpriteFrames, base: StringName, sheet: Texture2D, fps: float, loop: bool) -> void:
	if sheet == null:
		return
	var cols: int = int(sheet.get_width() / FRAME_W)
	_build_row(frames, StringName(String(base) + "_right"), sheet, ROW_RIGHT, cols, fps, loop)
	_build_row(frames, StringName(String(base) + "_left"), sheet, ROW_LEFT, cols, fps, loop)


func _build_row(frames: SpriteFrames, anim: StringName, sheet: Texture2D, row: int, cols: int, fps: float, loop: bool) -> void:
	frames.add_animation(anim)
	frames.set_animation_speed(anim, fps)
	frames.set_animation_loop(anim, loop)
	for col in range(cols):
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(col * FRAME_W, row * FRAME_H, FRAME_W, FRAME_H)
		frames.add_frame(anim, atlas)


func _add_held_state(frames: SpriteFrames, base: StringName, sheet: Texture2D) -> void:
	if sheet == null:
		return
	var cols: int = int(sheet.get_width() / FRAME_W)
	for row in [ROW_RIGHT, ROW_LEFT]:
		var anim := StringName(String(base) + ("_right" if row == ROW_RIGHT else "_left"))
		frames.add_animation(anim)
		frames.set_animation_speed(anim, 1.0)
		frames.set_animation_loop(anim, true)
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2((cols - 1) * FRAME_W, row * FRAME_H, FRAME_W, FRAME_H)
		frames.add_frame(anim, atlas)


# --- Public API (called by Hero) ----------------------------------------------

func play_state(state: StringName) -> void:
	if state == &"melee":
		# Each fresh swing advances the 1 -> 2 -> 3 attack cycle.
		if _current_state != &"melee" or not is_playing():
			_attack_cycle = (_attack_cycle + 1) % 3
		_current_state = &"melee"
		_refresh(false)
		return
	if state == _current_state and is_playing():
		return
	_current_state = state
	_refresh(false)


## Force the next swing of the 1->2->3 melee cycle to play. The Hero calls
## this to chain a held-attack combo — play_state's melee guard would skip
## the cycle advance while the previous swing is still animating.
func advance_attack() -> void:
	_attack_cycle = (_attack_cycle + 1) % 3
	_current_state = &"melee"
	_refresh(false)


func set_facing_from_aim(aim_dir: Vector2) -> void:
	# 2-directional: left or right. Near-vertical input keeps current facing.
	if absf(aim_dir.x) < 0.01:
		return
	var face_left: bool = aim_dir.x < 0.0
	if face_left == _facing_left:
		return
	_facing_left = face_left
	_refresh(true)  # keep the frame index so a run cycle doesn't hitch


func current_state() -> StringName:
	return _current_state


func direction_name() -> StringName:
	return &"left" if _facing_left else &"right"


func direction_index() -> int:
	return 1 if _facing_left else 0


## Which attack of the 1->2->3 cycle is currently showing: 0, 1, or 2
## (2 = the third/last attack). -1 before any swing.
func current_attack_index() -> int:
	return _attack_cycle


# --- Internals ----------------------------------------------------------------

func _refresh(preserve_frame: bool) -> void:
	if sprite_frames == null:
		return
	var base: String = String(_current_state)
	if _current_state == &"melee":
		base = "melee%d" % (_attack_cycle + 1)
	var anim := StringName(base + ("_left" if _facing_left else "_right"))
	if not sprite_frames.has_animation(anim):
		push_warning("HeroSpriteController: missing animation %s" % anim)
		return
	if animation == anim and is_playing():
		return
	var keep_frame: int = frame
	var was_playing: bool = is_playing()
	play(anim)
	if preserve_frame and was_playing and keep_frame < sprite_frames.get_frame_count(anim):
		frame = keep_frame


func _on_animation_finished() -> void:
	animation_completed.emit(_current_state)
