# Always owned by Player only  for shooting at enemies that handle shooting collision logic
class_name Ray
extends RayCast2D

signal shot(rotation: float)

@export var player: Player

var is_active: bool = false:
	set(value):
		is_active = value
		set_physics_process(value)
		enabled = value
		visible = value

@onready var line: Line2D = $Line
@onready var dot: Sprite2D = $Dot
@onready var light: Light = $Light


func _ready() -> void:
	assert(player is Player, "Ray: player must be a Player")
	is_active = false


# To resolve ray collision, and decide where the end point is to draw laser sight (line and dot)
func _physics_process(_delta: float) -> void:
	force_raycast_update()
	var end: Vector2 = to_local(get_collision_point()) if is_colliding() else target_position
	line.set_point_position(1, end)
	dot.position = end


func shoot() -> bool:
	if not is_active:
		return false

	if not GameState.try_consume_ammo():
		return false

	shot.emit(rotation)

	light.flash(line.get_point_position(0))
	var muzzle_pos: Vector2 = to_global(line.get_point_position(0))
	var hit_pos: Vector2 = to_global(line.get_point_position(1))
	Spawner.spawn_shoot_effects(muzzle_pos, hit_pos, rotation, player.body.flip_h)

	# The order is: _unhandled_input (shoot) fires, then _physics_process runs.
	# So the force_raycast_update in shoot happens before the one in physics_process.
	# The one in shoot is needed to get collision data for the damage check.
	# The one in physics_process is needed to update the laser sight visual. Both are needed.
	force_raycast_update()
	if is_colliding():
		var collider: Object = get_collider()
		if collider and collider.is_in_group("enemies") and collider.has_method("ouch"):
			collider.ouch()

	# Shot fired, may miss or hit something
	return true
