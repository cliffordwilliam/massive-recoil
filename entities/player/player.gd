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
			var current_frame: int = arms.frame
			arms.sprite_frames = GameState.weapons[GameState.equipped_weapon]["player_sprites"]
			arms.frame = current_frame
	)
	body.animation_changed.connect(func() -> void: arms.animation = body.animation)
	body.frame_changed.connect(func() -> void: arms.frame = body.frame)
	body.flip_h_changed.connect(func() -> void: arms.flip_h = body.flip_h)


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory"):
		owner.page_router.open_page(preload("uid://cenchx8ug57g2"))
