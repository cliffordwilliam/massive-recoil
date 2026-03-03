# User moves player around to explore the world and shoot at enemies
class_name Player
extends CharacterBody2D

const WALK_SPEED: float = 28.0
const RUN_SPEED: float = 90.0
const AIM_SPEED: float = 1.0
const AIM_SMOOTH: float = 0.05

@onready var arms: Arms = $Body/Arms
@onready var body: CustomAnimatedSprite = $Body
@onready var ray: Ray = $Ray
@onready var state_machine: StateMachine = $StateMachine
@onready var aim_frames: int = body.sprite_frames.get_frame_count("aim")


# State machine and arms are extension of the player so they have to start when player start
func _ready() -> void:
	state_machine.start()
	arms.start()


func _on_page_router_page_closed() -> void: # Connected via engine GUI
	# To avoid edge cases like going to a shop while player is reloading and etc
	state_machine.reset()
