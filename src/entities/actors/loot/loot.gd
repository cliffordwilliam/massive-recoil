# Things that bounce around in the world like coins that the player can pick up.
class_name Loot
extends RigidBody2D

const POP_SPREAD: float = PI / 4
const POP_SPEED_MIN: float = 100.0
const POP_SPEED_MAX: float = 150.0

var id: StringName = &""
var is_collected: bool = false
var is_initialized: bool = false
var global_pos: Vector2 = Vector2.ZERO
var linear_vel: Vector2 = Vector2.ZERO

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	if not is_initialized:
		return

	_assign_children_properties()


func initialize(given_id: StringName, pos: Vector2) -> void:
	# This can be called before or after my _ready() is called.
	id = given_id
	is_initialized = true
	global_pos = pos
	linear_vel = Vector2.UP.rotated(
		randf_range(-POP_SPREAD, POP_SPREAD),
	) * randf_range(POP_SPEED_MIN, POP_SPEED_MAX)

	if is_node_ready():
		_assign_children_properties()


func _assign_children_properties() -> void:
	# sprite_frames has no default value and can be null if not assigned in the inspector.
	# Calling .has_animation() on a null reference crashes before Utils.require can catch it.
	# Guard null first, then check for the animation.
	# Doc ref: docs/godot/classes/class_animatedsprite2d.rst — sprite_frames property
	# (default value column is empty, meaning the property can be null).
	if not Utils.require(animated_sprite_2d.sprite_frames != null, "Loot: sprite_frames must be assigned"):
		return
	if not Utils.require(animated_sprite_2d.sprite_frames.has_animation(id), "Loot: No anim for: " + id):
		return

	animated_sprite_2d.play(id)
	global_position = global_pos
	# One-time init — sporadic assignment is explicitly permitted by the docs.
	# Doc ref: docs/godot/classes/class_rigidbody2d.rst — linear_velocity:
	# "Can be used sporadically, but don't set this every frame."
	linear_velocity = linear_vel


func _on_area_2d_body_entered(body: Node2D) -> void: # Connected via engine GUI (one shot).
	if is_collected:
		return

	if body is not Player:
		return

	is_collected = true

	if id == &"money":
		GameState.add_one_to_money()
	elif GameState.weapon_exists(id):
		GameState.pick_up_a_weapon_by_id(id)
	else:
		push_warning("Loot: unknown id on collection: " + id)

	queue_free()
