# This is the skin that gets swapped around when equipped weapon changes, handgun, rifle, etc
# This has the exact same frames as body, so it always follows body sprite frame states
# So it must have Player as direct parent and a reference player's body sprite master
# This also has a recoil animation that plays when player shoots
class_name Arms
extends AnimatedSprite2D

const RECOIL_DISTANCE: float = 2.5
const RECOIL_SMOOTH: float = 15.0

@export var player: Player

var recoil_tween: Tween


func _ready() -> void:
	assert(player is Player, "Arms: player must be a Player")


func _exit_tree() -> void:
	_kill_recoil_tween_if_exists()
	if GameState.new_weapon_equipped.is_connected(_hydrate_ui):
		GameState.new_weapon_equipped.disconnect(_hydrate_ui)


# WARNING: Must be called by Player ready!
func start() -> void: # Connected via engine GUI
	if not GameState.new_weapon_equipped.is_connected(_hydrate_ui):
		GameState.new_weapon_equipped.connect(_hydrate_ui)
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
	sprite_frames = GameState.get_new_equipped_weapon_arms_sprite()
	frame = player.body.frame # Changing sprite frames set me to 0, must keep up with master


func _on_ray_shot(given_rotation: float) -> void: # Connected via engine GUI
	_play_recoil_animation(given_rotation)


# Follow body master at all cost
func _on_body_animation_changed() -> void: # Connected via engine GUI
	animation = player.body.animation


func _on_body_frame_changed() -> void: # Connected via engine GUI
	frame = player.body.frame


func _on_body_flip_h_changed() -> void: # Connected via engine GUI
	flip_h = player.body.flip_h
