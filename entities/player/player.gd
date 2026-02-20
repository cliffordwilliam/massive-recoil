class_name Player
extends CharacterBody2D

const ARMS = preload("uid://bwtavvs3i1wy2")
const HANDGUNS = preload("uid://c6ackeixi1emi")
const RIFLES = preload("uid://bd23x5s463v8v")
const WALK_SPEED: float = 28.0
const RUN_SPEED: float = 90.0
const AIM_SPEED: float = 2.0

@onready var body: AnimatedSprite = $Body
@onready var arms: AnimatedSprite = $Body/Arms
@onready var aim_pivot: Node2D = $AimPivot


func _ready() -> void:
	body.animation_changed.connect(func() -> void: arms.animation = body.animation)
	body.frame_changed.connect(func() -> void: arms.frame = body.frame)
	body.flip_h_changed.connect(func() -> void: arms.flip_h = body.flip_h)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		arms.sprite_frames = ARMS
	elif event.is_action_pressed("ui_right"):
		arms.sprite_frames = HANDGUNS
	elif event.is_action_pressed("ui_down"):
		arms.sprite_frames = RIFLES
