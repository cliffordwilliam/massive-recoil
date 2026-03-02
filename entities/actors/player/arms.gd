class_name Arms
extends AnimatedSprite2D

var recoil_dist_to_cover: float = 0.0
var recoil_direction: Vector2 = Vector2.ZERO


func _process(delta: float) -> void:
	recoil_dist_to_cover = move_toward(recoil_dist_to_cover, 0.0, owner.RECOIL_SMOOTH * delta)
	position = recoil_direction * recoil_dist_to_cover
	if is_zero_approx(recoil_dist_to_cover):
		position = Vector2.ZERO
		set_process(false)


func recoil_arm_sprite_back(angle: float) -> void:
	recoil_direction = Vector2(-1, 0).rotated(angle)
	recoil_dist_to_cover = owner.RECOIL_DISTANCE
	set_process(true)


func _hydrate_ui() -> void:
	sprite_frames = GameState.get_new_equipped_weapon_arms_sprite()
	frame = owner.body.frame # Changing sprite frames set me to 0, must keep up with master


func _on_body_animation_changed() -> void: # Connected via engine GUI
	animation = owner.body.animation


func _on_body_frame_changed() -> void: # Connected via engine GUI
	frame = owner.body.frame


func _on_body_flip_h_changed() -> void: # Connected via engine GUI
	flip_h = owner.body.flip_h


func _on_player_ready() -> void: # Connected via engine GUI
	set_process(false)
	GameState.new_weapon_equipped.connect(_hydrate_ui)
	_hydrate_ui()
