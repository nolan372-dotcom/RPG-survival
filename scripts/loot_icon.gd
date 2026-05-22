class_name LootIcon
extends Node2D
##
## Small icon that pops up from a harvested node and fades out. One spawned
## per resource gained — three berry-bush units = three berry icons hopping
## above the bush. Spawn via LootIcon.setup(texture).
##

const TOTAL_LIFETIME: float = 1.0
const FADE_START_T: float = 0.5  # start fading after this fraction of lifetime
const RISE_SPEED: float = 45.0   # constant upward speed (px/s)
const ICON_SCALE: float = 0.3    # icons are 64px source cells; shrink for "loot" feel

@onready var sprite: Sprite2D = $Sprite
var _lifetime: float = 0.0


func setup(texture: Texture2D) -> void:
	# Called immediately after instantiate, may run before _ready — defer
	# a frame so $Sprite is valid.
	await get_tree().process_frame
	if not is_inside_tree():
		return
	if sprite == null:
		sprite = $Sprite
	sprite.texture = texture
	sprite.scale = Vector2(ICON_SCALE, ICON_SCALE)


func _process(delta: float) -> void:
	_lifetime += delta
	# Straight up, constant speed — no arc, no gravity.
	position.y -= RISE_SPEED * delta
	if _lifetime > FADE_START_T * TOTAL_LIFETIME:
		var fade_t: float = (_lifetime - FADE_START_T * TOTAL_LIFETIME) / ((1.0 - FADE_START_T) * TOTAL_LIFETIME)
		modulate.a = clamp(1.0 - fade_t, 0.0, 1.0)
	if _lifetime >= TOTAL_LIFETIME:
		queue_free()
