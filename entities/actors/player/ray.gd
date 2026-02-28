class_name Ray
extends RayCast2D

@onready var line: Line2D = $Line
@onready var dot: Sprite2D = $Dot


func _physics_process(_delta: float) -> void:
	force_raycast_update()
	var end: Vector2 = to_local(get_collision_point()) if is_colliding() else target_position
	line.set_point_position(1, end)
	dot.position = end


func set_active(value: bool) -> void:
	set_physics_process(value)
	enabled = value
	line.visible = value
	dot.visible = value


func shoot() -> void:
	if not GameState.consume_equipped_ammo():
		return
	get_tree().current_scene.add_child(
		preload("uid://brkax245qceky").instantiate().init(
			to_global(line.get_point_position(0)),
			owner.body.flip_h,
		),
	)
	if is_colliding():
		if get_collider() is TileMapLayer:
			return
		if get_collider().collision_layer & 8:
			get_collider().ouch()
