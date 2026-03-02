# User moves player around to explore the world and shoot at enemies
class_name Player
extends CharacterBody2D

const WALK_SPEED: float = 28.0
const RUN_SPEED: float = 90.0
const AIM_SPEED: float = 1.0
const AIM_SMOOTH: float = 0.05
const RECOIL_DISTANCE: float = 2.5
const RECOIL_SMOOTH: float = 15.0

@onready var arms: Arms = $Body/Arms
@onready var body: CustomAnimatedSprite = $Body
@onready var ray: Ray = $Ray
@onready var state_machine: StateMachine = $StateMachine
@onready var aim_frames: int = body.sprite_frames.get_frame_count("aim")


func _on_page_router_page_closed() -> void: # Connected via engine GUI
	# To avoid edge cases like going to a shop while reloading and etc
	state_machine.reset()
