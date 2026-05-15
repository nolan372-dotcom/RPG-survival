class_name HeroSpriteController
extends AnimatedSprite2D
##
## Drives a hero's visual state by:
##   1. Building a SpriteFrames from a CharacterAnimationSet at startup,
##      with animation names of the form "<state>_<direction>" (e.g. "idle_s").
##   2. Selecting one of N directions (default 8) from a facing Vector2.
##   3. Playing the right combined animation as state/direction change.
##
## Row order in each sheet (top to bottom): N, NE, E, SE, S, SW, W, NW.
##

const DIRECTION_SUFFIXES_8: PackedStringArray = ["n", "ne", "e", "se", "s", "sw", "w", "nw"]
const DIRECTION_SUFFIXES_4: PackedStringArray = ["n", "e", "s", "w"]

@export var animation_set: Resource  # CharacterAnimationSet

var _direction_suffixes: PackedStringArray
var _current_state: StringName = &"idle"
var _current_direction_index: int = 4  # S by default
var _frame_size: Vector2i = Vector2i(64, 64)

signal animation_completed(state: StringName)

func _ready() -> void:
	if animation_set != null:
		rebuild()

## Build SpriteFrames from animation_set. Safe to call multiple times — used
## when Hero late-binds the animation set from HeroData.
func rebuild() -> void:
	if animation_set == null:
		push_warning("HeroSpriteController: animation_set is null; cannot rebuild")
		return
	_frame_size = animation_set.frame_size
	_direction_suffixes = DIRECTION_SUFFIXES_8 if animation_set.direction_count == 8 else DIRECTION_SUFFIXES_4
	_build_sprite_frames()
	if not animation_finished.is_connected(_on_animation_finished):
		animation_finished.connect(_on_animation_finished)
	play_state(_current_state)

func _build_sprite_frames() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")  # SpriteFrames ships with a default we don't want

	for anim_name in animation_set.animation_names():
		var sheet: Texture2D = animation_set.get_sheet(anim_name)
		if sheet == null:
			continue
		var frame_count: int = animation_set.get_frame_count(anim_name)
		var fps: float = animation_set.get_fps(anim_name)
		var loop: bool = animation_set.is_looping(anim_name)
		var dir_count: int = _direction_suffixes.size()

		for dir_index in dir_count:
			var combined: StringName = "%s_%s" % [String(anim_name), _direction_suffixes[dir_index]]
			frames.add_animation(combined)
			frames.set_animation_speed(combined, fps)
			frames.set_animation_loop(combined, loop)

			for frame_index in frame_count:
				var atlas := AtlasTexture.new()
				atlas.atlas = sheet
				atlas.region = Rect2(frame_index * _frame_size.x, dir_index * _frame_size.y, _frame_size.x, _frame_size.y)
				frames.add_frame(combined, atlas)

	sprite_frames = frames

func set_facing_from_aim(aim_dir: Vector2) -> void:
	if aim_dir.length_squared() < 0.0001:
		return
	var dir_count: int = _direction_suffixes.size()
	# Angle 0 should be North. Godot Vector2 angle: 0 is +X (E), pi/2 is +Y (S).
	# Convert to "clockwise from N": 0=N, pi/2=E, pi=S, 3pi/2=W.
	var angle_from_n: float = fposmod(aim_dir.angle() + PI / 2.0, TAU)
	var index: int = int(round(angle_from_n / TAU * dir_count)) % dir_count
	if index != _current_direction_index:
		_current_direction_index = index
		_refresh_play()

func play_state(state: StringName) -> void:
	if state == _current_state and is_playing():
		return
	_current_state = state
	_refresh_play()

func current_state() -> StringName:
	return _current_state

func direction_index() -> int:
	return _current_direction_index

func _refresh_play() -> void:
	if sprite_frames == null:
		return
	var combined: StringName = "%s_%s" % [String(_current_state), _direction_suffixes[_current_direction_index]]
	if not sprite_frames.has_animation(combined):
		push_warning("HeroSpriteController: missing animation %s" % combined)
		return
	play(combined)

func _on_animation_finished() -> void:
	animation_completed.emit(_current_state)
