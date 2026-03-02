class_name Ray
extends RayCast2D

signal shot(rotation: float)

@onready var player: Player = owner
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
		var muzzle_pos: Vector2 = to_global(line.get_point_position(0))
		var hit_pos: Vector2 = to_global(line.get_point_position(1))
		shot.emit(rotation)
		light.flash(line.get_point_position(0))
		Spawner.spawn_shoot_effects(muzzle_pos, hit_pos, rotation, player.body.flip_h)
		force_raycast_update()
		if is_colliding():
			var collider: Object = get_collider()
			if collider and collider.is_in_group("enemies") and collider.has_method("ouch"):
				collider.ouch()
