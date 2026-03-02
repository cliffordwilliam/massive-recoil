class_name Ray
extends RayCast2D

@onready var line: Line2D = $Line
@onready var dot: Sprite2D = $Dot
@onready var light: Light = $Light


func _ready() -> void:
	set_active(false)


func _physics_process(_delta: float) -> void:
	force_raycast_update()
	var end: Vector2 = to_local(get_collision_point()) if is_colliding() else target_position
	line.set_point_position(1, end)
	dot.position = end


func set_active(value: bool) -> void:
	set_physics_process(value)
	enabled = value
	visible = value


func shoot() -> void:
	if GameState.try_consume_ammo():
		owner.arms.recoil_arm_sprite_back(rotation)
		light.flash(line.get_point_position(0))
		Spawner.spawn_shoot_effects(
			to_global(line.get_point_position(0)),
			to_global(line.get_point_position(1)),
			rotation,
			owner.body.flip_h,
		)
		if is_colliding():
			var collider: Object = get_collider()
			if collider and collider.has_method("ouch"):
				collider.ouch()
