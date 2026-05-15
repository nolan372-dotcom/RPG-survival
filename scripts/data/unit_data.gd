class_name UnitData
extends Resource

enum UnitKind { RECRUIT, MERCENARY }
enum RecruitTier { SPEARMAN, SWORDSMAN, CROSSBOWMAN }
enum MercenaryType { KNIGHT, ARCHER, CLERIC }

@export var id: StringName
@export var display_name: String
@export var kind: UnitKind = UnitKind.RECRUIT
@export var recruit_tier: RecruitTier = RecruitTier.SPEARMAN
@export var mercenary_type: MercenaryType = MercenaryType.KNIGHT
@export var hp: int = 50
@export var damage: int = 10
@export var move_speed: float = 80.0
@export var attack_range: float = 32.0
@export var attack_rate: float = 1.0
@export var train_food_cost: int = 10
@export var hire_gold_cost: int = 50
@export var sprite_frames: SpriteFrames
