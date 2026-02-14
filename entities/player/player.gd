extends CharacterBody2D

const WALK_SPEED: float = 28.0
const RUN_SPEED: float = 90.0
const MAX_FALL_SPEED: float = 480.0
const JUMP_SPEED: float = 240.0
const NORMAL_GRAVITY: float = 600.0
const FALL_GRAVITY: float = 2400.0

@onready var animated_sprite: AnimatedSprite = $AnimatedSprite
