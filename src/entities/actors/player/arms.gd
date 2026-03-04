# This is the skin that gets swapped when the equipped weapon changes (handgun, rifle, etc.).
# It has the exact same frames as the body, so it always follows the body sprite's frame state.
# It must have Player as its direct parent and hold a reference to the player's body sprite master.
# It also has a recoil animation that plays when the player shoots.
class_name Arms
extends AnimatedSprite2D

const RECOIL_DISTANCE: float = 2.5
const RECOIL_SMOOTH: float = 15.0

@export var player: Player

var recoil_tween: Tween


func _ready() -> void:
	assert(player is Player, "Arms: player must be a Player")
	if not player is Player:
		push_error("Arms: player must be a Player")
		return
	GameState.new_weapon_equipped.connect(_hydrate_ui)


func _exit_tree() -> void:
	GameState.new_weapon_equipped.disconnect(_hydrate_ui)
	_kill_recoil_tween_if_exists()


# Warning: Must be called by Player._ready().
func start() -> void: # Connected via engine GUI
	_hydrate_ui()


func _play_recoil_animation(angle: float) -> void:
	var direction: Vector2 = Vector2(-1, 0).rotated(angle)
	position = direction * RECOIL_DISTANCE

	_kill_recoil_tween_if_exists()

	recoil_tween = create_tween()
	recoil_tween.tween_property(self, "position", Vector2.ZERO, RECOIL_DISTANCE / RECOIL_SMOOTH)


func _kill_recoil_tween_if_exists() -> void:
	if recoil_tween:
		recoil_tween.kill()
		recoil_tween = null


func _hydrate_ui() -> void:
	# Swapping sprite_frames mid-animation could glitch if new sprite has a different frame count
	# If it happens so be it, it must not happen since all of these came from 1 aseprite file
	var equipped_weapon_arms_sprite: SpriteFrames = GameState.get_new_equipped_weapon_arms_sprite()

	if equipped_weapon_arms_sprite:
		sprite_frames = equipped_weapon_arms_sprite
	else:
		sprite_frames = preload("uid://bwtavvs3i1wy2")

	# Changing sprite frames resets me to 0; I must keep up with the master.
	frame = player.body.frame


func _on_ray_shot(given_rotation: float) -> void: # Connected via engine GUI
	_play_recoil_animation(given_rotation)


# Follow the body master at all costs.
func _on_body_animation_changed() -> void: # Connected via engine GUI
	animation = player.body.animation


func _on_body_frame_changed() -> void: # Connected via engine GUI
	frame = player.body.frame


func _on_body_flip_h_changed() -> void: # Connected via engine GUI
	flip_h = player.body.flip_h
