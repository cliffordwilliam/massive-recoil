# This is the skin that gets swapped when the equipped weapon changes (handgun, rifle, etc.).
# It has the exact same frames as the body, so it always follows the body sprite's frame state.
# It must have a reference to the player's body sprite master via Player reference.
# It also has a recoil animation that plays when the player shoots.
class_name Arms
extends AnimatedSprite2D

const RECOIL_DISTANCE: float = 2.5
const RECOIL_SMOOTH: float = 15.0

@export var player: Player

var tween: Tween

@onready var white_rim_flash_timer: Timer = $WhiteRimFlashTimer


func _ready() -> void:
	if not Utils.require(player is Player, "Arms: player must be a Player"):
		return
	GameState.new_weapon_equipped.connect(_hydrate_ui)
	white_rim_flash_timer.one_shot = true


func _exit_tree() -> void:
	# If the signal connection was never established
	# (e.g. _ready() returned early due to the player guard on line 18-19),
	# calling disconnect() on a non-existent connection generates an error.
	# In practice this is unlikely since the _ready() guard and _exit_tree() are closely coupled,
	# but the Godot docs explicitly recommend using is_connected() first.
	# Doc reference: docs/godot/classes/class_signal.rst — disconnect():
	# "If the connection does not exist, generates an error.
	# Use is_connected() to make sure that the connection exists."
	if GameState.new_weapon_equipped.is_connected(_hydrate_ui):
		GameState.new_weapon_equipped.disconnect(_hydrate_ui)
	tween = Utils.kill_tween(tween)


# Warning: Must be called by Player._ready().
func start() -> void:
	_hydrate_ui()


func _play_recoil_animation(angle: float) -> void:
	var direction: Vector2 = Vector2(-1, 0).rotated(angle)
	position = direction * RECOIL_DISTANCE

	tween = Utils.kill_tween(tween)

	# Node.create_tween() already binds to self — no need for bind_node(self).
	# Ref: docs/godot/classes/class_node.rst — create_tween():
	# "This is the equivalent of doing: get_tree().create_tween().bind_node(self)"
	tween = create_tween()
	tween.tween_property(self, "position", Vector2.ZERO, RECOIL_DISTANCE / RECOIL_SMOOTH)
	# Show rim light on body.
	_set_rim(true, angle)


func _set_rim(value: bool, angle: float = 0.0) -> void:
	if value:
		white_rim_flash_timer.start()

	var corrected_angle: float = angle

	# Fix vertical axis (screen space vs math space)
	corrected_angle = -corrected_angle

	# Mirror when sprite is flipped
	if not player.body.is_flipped_h():
		corrected_angle = PI - corrected_angle

	if player.body.material:
		player.body.material.set_shader_parameter("flash", value)
		player.body.material.set_shader_parameter("angle", corrected_angle)

	if material:
		material.set_shader_parameter("flash", value)
		material.set_shader_parameter("angle", corrected_angle)


func _hydrate_ui() -> void:
	# Swapping sprite_frames mid-animation could glitch if new sprite has a different frame count.
	# If it happens so be it, it must not happen since all of these came from 1 aseprite file.
	var equipped_weapon_arms_sprite: SpriteFrames = GameState.get_new_equipped_weapon_arms_sprite()

	if equipped_weapon_arms_sprite:
		sprite_frames = equipped_weapon_arms_sprite
	else:
		sprite_frames = preload("uid://bwtavvs3i1wy2")

	# This does not reset my frame progress when I change sprite frames.
	# Doc reference: docs/godot/classes/class_animatedsprite2d.rst — frame property:
	# "Setting this property also resets frame_progress. If this is not desired,
	# use set_frame_and_progress()."
	set_frame_and_progress(player.body.frame, player.body.frame_progress)


func _on_ray_shot(given_rotation: float) -> void: # Connected via engine GUI.
	_play_recoil_animation(given_rotation)


# Follow the body master at all costs.
func _on_body_animation_changed() -> void: # Connected via engine GUI.
	animation = player.body.animation


func _on_body_frame_changed() -> void: # Connected via engine GUI.
	set_frame_and_progress(player.body.frame, player.body.frame_progress)


func _on_body_flip_h_changed() -> void: # Connected via engine GUI.
	# Arms extends bare AnimatedSprite2D, not MyAnimatedSprite, so there is no flip_h_changed
	# signal to miss on this node. Setting flip_h directly is correct here.
	# If Arms is ever refactored to extend MyAnimatedSprite, use set_flip() instead.
	flip_h = player.body.is_flipped_h()


func _on_white_rim_flash_timer_timeout() -> void: # Connected via engine GUI.
	_set_rim(false)
