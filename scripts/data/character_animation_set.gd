class_name CharacterAnimationSet
extends Resource
##
## Describes a top-down 8-direction sprite pack laid out as one PNG per animation,
## with directions on the Y axis and frames on the X axis.
##
## Row order (top to bottom): N, NE, E, SE, S, SW, W, NW.
## All animation sheets in a set must share the same frame size and direction count.
##

@export var frame_size: Vector2i = Vector2i(64, 64)
@export var direction_count: int = 8

## anim_name (StringName) -> Texture2D (spritesheet)
@export var sheets: Dictionary = {}

## anim_name (StringName) -> Dictionary with keys:
##   frame_count: int  (columns to play, <= sheet_width / frame_size.x)
##   fps: float        (playback speed)
##   loop: bool
@export var metadata: Dictionary = {}

func get_sheet(anim_name: StringName) -> Texture2D:
	return sheets.get(anim_name, null)

func get_frame_count(anim_name: StringName) -> int:
	var meta: Dictionary = metadata.get(anim_name, {})
	return int(meta.get("frame_count", 1))

func get_fps(anim_name: StringName) -> float:
	var meta: Dictionary = metadata.get(anim_name, {})
	return float(meta.get("fps", 10.0))

func is_looping(anim_name: StringName) -> bool:
	var meta: Dictionary = metadata.get(anim_name, {})
	return bool(meta.get("loop", true))

func has_animation(anim_name: StringName) -> bool:
	return sheets.has(anim_name)

func animation_names() -> Array:
	return sheets.keys()
