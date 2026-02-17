class_name Player
extends CharacterBody2D

const ARMS = preload("uid://bwtavvs3i1wy2")
const HANDGUNS = preload("uid://c6ackeixi1emi")
const RIFLES = preload("uid://bd23x5s463v8v")
const WALK_SPEED: float = 28.0
const RUN_SPEED: float = 90.0
const MAX_FALL_SPEED: float = 480.0
const JUMP_SPEED: float = 240.0
const NORMAL_GRAVITY: float = 600.0
const FALL_GRAVITY: float = 2400.0

# TODO: Autoload stores all dynamic vars, everything here is FE that uses it, dump to disk later
var current_weapon_index: int = 0

@onready var body: AnimatedSprite = $Body
@onready var arms: AnimatedSprite = $Arms


func _ready() -> void:
	body.animation_changed.connect(func() -> void: arms.animation = body.animation)
	body.frame_changed.connect(func() -> void: arms.frame = body.frame)
	body.flip_h_changed.connect(func() -> void: arms.flip_h = body.flip_h)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		switch_weapon(0)
	elif event.is_action_pressed("ui_right"):
		switch_weapon(1)
	elif event.is_action_pressed("ui_up"):
		switch_weapon(2)


func switch_weapon(index: int) -> void:
	current_weapon_index = index
	arms.sprite_frames = [ARMS, HANDGUNS, RIFLES][index]
