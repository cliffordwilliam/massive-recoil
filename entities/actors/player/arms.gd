extends AnimatedSprite


func _ready() -> void:
	await owner.ready
	owner.body.animation_changed.connect(func() -> void: animation = owner.body.animation)
	owner.body.frame_changed.connect(func() -> void: frame = owner.body.frame)
	owner.body.flip_h_changed.connect(func() -> void: flip_h = owner.body.flip_h)
	GameState.weapon_equipped.connect(func(new_arm: Resource) -> void: sprite_frames = new_arm)
	sprite_frames_changed.connect(func() -> void: frame = owner.body.frame)
	sprite_frames = GameState.get_equipped_arm()
