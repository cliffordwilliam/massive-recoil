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


func _ready() -> void:
	if not Utils.require(player is Player, "Arms: player must be a Player"):
		return
	GameState.new_weapon_equipped.connect(_hydrate_ui)


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
	_kill_tween_if_exists()


# Warning: Must be called by Player._ready().
func start() -> void:
	_hydrate_ui()


func _play_recoil_animation(angle: float) -> void:
	var direction: Vector2 = Vector2(-1, 0).rotated(angle)
	position = direction * RECOIL_DISTANCE

	_kill_tween_if_exists()

	# Node.create_tween() already binds to self — no need for bind_node(self).
	# Ref: docs/godot/classes/class_node.rst — create_tween():
	# "This is the equivalent of doing: get_tree().create_tween().bind_node(self)"
	tween = create_tween()
	tween.tween_property(self, "position", Vector2.ZERO, RECOIL_DISTANCE / RECOIL_SMOOTH)


func _kill_tween_if_exists() -> void:
	if tween:
		tween.kill()
		tween = null


func _hydrate_ui() -> void:
	# Swapping sprite_frames mid-animation could glitch if new sprite has a different frame count.
	# If it happens so be it, it must not happen since all of these came from 1 aseprite file.
	var equipped_weapon_arms_sprite: SpriteFrames = GameState.get_new_equipped_weapon_arms_sprite()

	if equipped_weapon_arms_sprite:
		sprite_frames = equipped_weapon_arms_sprite
	else:
		sprite_frames = preload("uid://bwtavvs3i1wy2")

	# Changing sprite frames resets me to 0; I must keep up with the master.
	frame = player.body.frame


func _on_ray_shot(given_rotation: float) -> void: # Connected via engine GUI.
	_play_recoil_animation(given_rotation)


# Follow the body master at all costs.
func _on_body_animation_changed() -> void: # Connected via engine GUI.
	animation = player.body.animation


func _on_body_frame_changed() -> void: # Connected via engine GUI.
	frame = player.body.frame


func _on_body_flip_h_changed() -> void: # Connected via engine GUI.
	flip_h = player.body.flip_h
