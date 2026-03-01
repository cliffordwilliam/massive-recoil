class_name Player
extends CharacterBody2D

const WALK_SPEED: float = 28.0
const RUN_SPEED: float = 90.0
const AIM_SPEED: float = 1.0
const AIM_SMOOTH: float = 0.05 # Lower = faster snap
const RECOIL_DISTANCE: float = 2.5
const RECOIL_SMOOTH: float = 15.0 # Lower = slower snap

@onready var arms: Arms = $Body/Arms
@onready var body: AnimatedSprite = $Body
@onready var ray: Ray = $Ray
@onready var aim_frames: int = body.sprite_frames.get_frame_count("aim")
