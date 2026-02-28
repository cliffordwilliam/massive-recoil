class_name Ray
extends RayCast2D

@onready var line: Line2D = $Line
@onready var dot: Sprite2D = $Dot
@onready var light: Sprite2D = $Light


func _physics_process(delta: float) -> void:
	force_raycast_update()
	var end: Vector2 = to_local(get_collision_point()) if is_colliding() else target_position
	line.set_point_position(1, end)
	dot.position = end
	if not is_zero_approx(light.modulate.a):
		light.modulate.a = move_toward(light.modulate.a, 0.0, 12.0 * delta)


func set_active(value: bool) -> void:
	set_physics_process(value)
	enabled = value
	visible = value


func shoot() -> void:
	if not GameState.consume_equipped_ammo():
		return
	owner.arms.recoil(rotation)
	var p1: Vector2 = to_global(line.get_point_position(0))
	var p2: Vector2 = to_global(line.get_point_position(1))
	Spawner.spawn("uid://brkax245qceky", [p1, owner.body.flip_h])
	Spawner.spawn("uid://dhv0cshyajm8r", [p1, rotation])
	Spawner.spawn("uid://bwhu4xdomjxnx", [p1, p2])
	light.position = line.get_point_position(0)
	light.modulate.a = 1.0
	if is_colliding():
		if get_collider() is TileMapLayer:
			return
		if get_collider().collision_layer & 8:
			get_collider().ouch()
