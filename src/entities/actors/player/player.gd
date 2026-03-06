# The user moves the player around to explore the world and shoot at enemies.
class_name Player
extends CharacterBody2D

const WALK_SPEED: float = 28.0
const RUN_SPEED: float = 90.0
const AIM_SPEED: float = 1.0
const AIM_SMOOTH: float = 0.05

var aim_frames: int = 0

@onready var arms: Arms = $Body/Arms
@onready var body: MyAnimatedSprite = $Body
@onready var ray: Ray = $Ray
@onready var state_machine: StateMachine = $StateMachine


# The state machine and arms are extensions of the player,
# so they have to start when the player starts.
func _ready() -> void:
	aim_frames = body.sprite_frames.get_frame_count("aim")
	state_machine.start()
	arms.start()
	PageRouter.page_closed.connect(_on_page_router_page_closed)


func _on_page_router_page_closed() -> void:
	# To avoid edge cases like going to a shop while the player is reloading, etc.
	state_machine.reset()
