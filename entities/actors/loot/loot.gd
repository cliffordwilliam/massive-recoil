# These are things that bounce around in the world like coins and stuff that player collects
class_name Loot
extends RigidBody2D

const POP_SPREAD: float = PI / 4
const POP_SPEED_MIN: float = 100.0
const POP_SPEED_MAX: float = 150.0

var id: StringName = &""
var is_collected: bool = false

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	if id and not animated_sprite_2d.is_playing():
		animated_sprite_2d.play(id)


func initialize(given_id: StringName, pos: Vector2) -> void:
	# This can be called before or after my ready is called
	id = given_id
	global_position = pos
	linear_velocity = Vector2.UP.rotated(
		randf_range(-POP_SPREAD, POP_SPREAD),
	) * randf_range(POP_SPEED_MIN, POP_SPEED_MAX)

	if is_node_ready():
		animated_sprite_2d.play(id)


func _on_area_2d_body_entered(body: Node2D) -> void: # Connected via engine GUI (one shot)
	if is_collected:
		return

	if body is not Player:
		return

	is_collected = true
	if id == &"money":
		GameState.add_one_to_money()
	elif GameState.weapon_exists(id):
		GameState.pick_up_a_weapon_by_id(id)
	queue_free()
