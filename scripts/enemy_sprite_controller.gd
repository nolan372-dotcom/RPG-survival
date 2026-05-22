class_name EnemySpriteController
extends AnimatedSprite2D
##
## Drives the goblin enemy's visual state. The goblin is fully 2-directional:
## the imported sheets are one facing, the "-flip" sheets are per-frame
## mirrors of them. We build "<state>_left" / "<state>_right" animations and
## play whichever matches the current facing — no flip_h.
##
## Frames are 192x128. The goblin figure sits off-centre in the wide frame,
## so each facing gets its own recentre offset.
##
## States the Enemy requests via play_state(): idle, run, attack, hurt, die.
## attack and hurt are one-shots that take priority over idle/run.
##

const FRAME_W: int = 192
const FRAME_H: int = 128
## Figure recentre: in the imported sheet the goblin sits ~16px off frame
## centre, feet ~13px low. The x sign flips with facing.
const FIGURE_OFFSET_X: float = 16.0
const FIGURE_OFFSET_Y: float = -13.0
## The imported (non-flip) sheets face this way. Flip if the goblin runs
## backwards in-game.
const ORIGINAL_FACES_LEFT: bool = false

const IDLE_O: Texture2D = preload("res://art/characters/goblin/goblin-idle.png")
const RUN_O: Texture2D = preload("res://art/characters/goblin/goblin-run.png")
const ATTACK_O: Texture2D = preload("res://art/characters/goblin/goblin-attack-1.png")
const HURT_O: Texture2D = preload("res://art/characters/goblin/goblin-hurt.png")
const DEATH_O: Texture2D = preload("res://art/characters/goblin/goblin-death.png")
const IDLE_F: Texture2D = preload("res://art/characters/goblin/goblin-idle-flip.png")
const RUN_F: Texture2D = preload("res://art/characters/goblin/goblin-run-flip.png")
const ATTACK_F: Texture2D = preload("res://art/characters/goblin/goblin-attack-1-flip.png")
const HURT_F: Texture2D = preload("res://art/characters/goblin/goblin-hurt-flip.png")
const DEATH_F: Texture2D = preload("res://art/characters/goblin/goblin-death-flip.png")

var _current_state: StringName = &"idle"
var _facing_left: bool = false


func _ready() -> void:
	rebuild()
	_apply_offset()
	play_state(&"idle")


func rebuild() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	_add_state(frames, &"idle", IDLE_O, IDLE_F, 9.0, true)
	_add_state(frames, &"run", RUN_O, RUN_F, 13.0, true)
	_add_state(frames, &"attack", ATTACK_O, ATTACK_F, 24.0, false)
	_add_state(frames, &"hurt", HURT_O, HURT_F, 22.0, false)
	_add_state(frames, &"die", DEATH_O, DEATH_F, 13.0, false)
	sprite_frames = frames


## Builds "<base>_left" and "<base>_right" — the imported sheet maps to
## whichever direction ORIGINAL_FACES_LEFT says, the flip sheet to the other.
func _add_state(frames: SpriteFrames, base: StringName, original: Texture2D, flipped: Texture2D, fps: float, loop: bool) -> void:
	var left_sheet: Texture2D = original if ORIGINAL_FACES_LEFT else flipped
	var right_sheet: Texture2D = flipped if ORIGINAL_FACES_LEFT else original
	_build_anim(frames, StringName(String(base) + "_left"), left_sheet, fps, loop)
	_build_anim(frames, StringName(String(base) + "_right"), right_sheet, fps, loop)


func _build_anim(frames: SpriteFrames, anim: StringName, sheet: Texture2D, fps: float, loop: bool) -> void:
	if sheet == null:
		return
	frames.add_animation(anim)
	frames.set_animation_speed(anim, fps)
	frames.set_animation_loop(anim, loop)
	var cols: int = int(sheet.get_width() / FRAME_W)
	for col in range(cols):
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(col * FRAME_W, 0, FRAME_W, FRAME_H)
		frames.add_frame(anim, atlas)


# --- Public API (called by Enemy) ---------------------------------------------

func play_state(state: StringName) -> void:
	# attack / hurt / die always (re)play and take priority.
	if state == &"attack" or state == &"hurt" or state == &"die":
		_current_state = state
		_refresh(false)
		return
	# Looping states (idle, run) don't interrupt a one-shot mid-play.
	if (_current_state == &"attack" or _current_state == &"hurt") and is_playing():
		return
	if state == _current_state and is_playing():
		return
	_current_state = state
	_refresh(false)


func set_facing(face_left: bool) -> void:
	if face_left == _facing_left:
		return
	_facing_left = face_left
	_apply_offset()
	_refresh(true)  # keep the frame so a run cycle doesn't hitch on turn


# --- Internals ----------------------------------------------------------------

func _apply_offset() -> void:
	# The imported sheet's figure sits left-of-centre; its mirror sits
	# right-of-centre. Recentre per whichever sheet the current facing shows.
	var showing_original: bool = (_facing_left == ORIGINAL_FACES_LEFT)
	var ox: float = FIGURE_OFFSET_X if showing_original else -FIGURE_OFFSET_X
	offset = Vector2(ox, FIGURE_OFFSET_Y)


func _refresh(preserve_frame: bool) -> void:
	if sprite_frames == null:
		return
	var anim := StringName(String(_current_state) + ("_left" if _facing_left else "_right"))
	if not sprite_frames.has_animation(anim):
		return
	if animation == anim and is_playing():
		return
	var keep_frame: int = frame
	var was_playing: bool = is_playing()
	play(anim)
	if preserve_frame and was_playing and keep_frame < sprite_frames.get_frame_count(anim):
		frame = keep_frame
