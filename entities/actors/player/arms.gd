class_name Arms
extends AnimatedSprite

var recoil_dist_to_cover: float = 0.0
var recoil_direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	set_physics_process(false)
	await owner.ready
	owner.body.animation_changed.connect(func() -> void: animation = owner.body.animation)
	owner.body.frame_changed.connect(func() -> void: frame = owner.body.frame)
	owner.body.flip_h_changed.connect(func() -> void: flip_h = owner.body.flip_h)
	GameState.new_weapon_equipped.connect(func() -> void: _hydrate_fe())
	_hydrate_fe()


func _physics_process(delta: float) -> void:
	recoil_dist_to_cover = move_toward(recoil_dist_to_cover, 0.0, owner.RECOIL_SMOOTH * delta)
	position = recoil_direction * recoil_dist_to_cover
	if is_zero_approx(recoil_dist_to_cover):
		position = Vector2.ZERO
		set_physics_process(false)


func recoil_arm_sprite_back(angle: float) -> void:
	recoil_direction = Vector2(-1, 0).rotated(angle)
	recoil_dist_to_cover = owner.RECOIL_DISTANCE
	set_physics_process(true)


func _hydrate_fe() -> void:
	sprite_frames = GameState.get_new_equipped_weapon_arms_sprite()
	frame = owner.body.frame # Changing sprite frames set me to 0, must keep up with master
