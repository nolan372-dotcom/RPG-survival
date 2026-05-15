class_name CharacterAnimationSet
extends Resource
##
## Describes a top-down 8-direction sprite pack laid out as one PNG per animation,
## with directions on the Y axis and frames on the X axis.
##
## The `direction_row_order` array tells the controller which row of the sheet
## corresponds to each compass direction. Different asset packs use different
## orderings (CW from N, CCW from N, CW from S, etc.), so this is configurable.
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

## Maps row index (0..direction_count-1, top to bottom) to compass direction.
## Default assumes CW from N: row 0=N, 1=NE, 2=E, 3=SE, 4=S, 5=SW, 6=W, 7=NW.
## Override per-asset if the pack uses a different convention.
@export var direction_row_order: Array[StringName] = [
	&"n", &"ne", &"e", &"se", &"s", &"sw", &"w", &"nw"
]

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
