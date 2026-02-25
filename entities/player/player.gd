class_name Player
extends CharacterBody2D

const WALK_SPEED: float = 28.0
const RUN_SPEED: float = 90.0
const AIM_SPEED: float = 2.0

@onready var body: AnimatedSprite = $Body
@onready var arms: AnimatedSprite = $Body/Arms
@onready var aim_pivot: Node2D = $AimPivot


func _ready() -> void:
	GameState.weapon_equipped.connect(
		func() -> void:
			arms.sprite_frames = GameState.weapons[GameState.equipped_weapon]["player_sprites"]
	)
	body.animation_changed.connect(func() -> void: arms.animation = body.animation)
	body.frame_changed.connect(func() -> void: arms.frame = body.frame)
	body.flip_h_changed.connect(func() -> void: arms.flip_h = body.flip_h)
