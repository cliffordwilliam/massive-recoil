class_name Arms
extends AnimatedSprite2D

var _recoil_tween: Tween

@onready var player: Player = owner


func _recoil_arm_sprite_back(angle: float) -> void:
	var direction: Vector2 = Vector2(-1, 0).rotated(angle)
	position = direction * player.RECOIL_DISTANCE

	if _recoil_tween:
		_recoil_tween.kill()

	_recoil_tween = create_tween()
	_recoil_tween.tween_property(self, "position", Vector2.ZERO, player.RECOIL_DISTANCE / player.RECOIL_SMOOTH)


func _hydrate_ui() -> void:
	sprite_frames = GameState.get_new_equipped_weapon_arms_sprite()
	frame = player.body.frame # Changing sprite frames set me to 0, must keep up with master


func _on_body_animation_changed() -> void: # Connected via engine GUI
	animation = player.body.animation


func _on_body_frame_changed() -> void: # Connected via engine GUI
	frame = player.body.frame


func _on_body_flip_h_changed() -> void: # Connected via engine GUI
	flip_h = player.body.flip_h


func _on_player_ready() -> void: # Connected via engine GUI
	GameState.new_weapon_equipped.connect(_hydrate_ui)
	_hydrate_ui()


func _on_ray_shot(given_rotation: float) -> void:
	_recoil_arm_sprite_back(given_rotation)
