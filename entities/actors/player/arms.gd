# This is the skin that gets switched when equipped weapon changes, handgun, rifle, etc
# This has the exact same frames as body, so it just follows body frame states
# So it always must be a child of the player
class_name Arms
extends AnimatedSprite2D

@export var player: Player

var recoil_tween: Tween


func _ready() -> void:
	assert(player is Player, "Arms: player must be a Player")


func _exit_tree() -> void:
	if recoil_tween:
		recoil_tween.kill()
		recoil_tween = null
	if GameState.new_weapon_equipped.is_connected(_hydrate_ui):
		GameState.new_weapon_equipped.disconnect(_hydrate_ui)


# Push skin back to simulate arm kicked back from recoil
func _recoil_arm_sprite_back(angle: float) -> void:
	var direction: Vector2 = Vector2(-1, 0).rotated(angle)
	position = direction * player.RECOIL_DISTANCE

	if recoil_tween:
		recoil_tween.kill()

	recoil_tween = create_tween()
	recoil_tween.tween_property(
		self,
		"position",
		Vector2.ZERO,
		player.RECOIL_DISTANCE / player.RECOIL_SMOOTH,
	)


func _hydrate_ui() -> void:
	sprite_frames = GameState.get_new_equipped_weapon_arms_sprite()
	frame = player.body.frame # Changing sprite frames set me to 0, must keep up with master


# Arm is an extension of the player so its ready must be when the player is ready
func _on_player_ready() -> void: # Connected via engine GUI
	GameState.new_weapon_equipped.connect(_hydrate_ui)
	# Need to wait for owner, because have to ref body to sync back after skin switch
	_hydrate_ui()


func _on_ray_shot(given_rotation: float) -> void:
	_recoil_arm_sprite_back(given_rotation)


# Follow body at all cost
func _on_body_animation_changed() -> void: # Connected via engine GUI
	animation = player.body.animation


func _on_body_frame_changed() -> void: # Connected via engine GUI
	frame = player.body.frame


func _on_body_flip_h_changed() -> void: # Connected via engine GUI
	flip_h = player.body.flip_h
