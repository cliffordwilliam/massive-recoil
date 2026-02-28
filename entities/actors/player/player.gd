class_name Player
extends CharacterBody2D

const WALK_SPEED: float = 28.0
const RUN_SPEED: float = 90.0
const AIM_SPEED: float = 1.0
const AIM_SMOOTH: float = 0.05 # Lower = faster snap

@onready var body: AnimatedSprite = $Body
@onready var aim_frames: int = body.sprite_frames.get_frame_count("aim")
@onready var ray: Ray = $Ray
