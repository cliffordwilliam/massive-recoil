# Always owned by Player and used for shooting at enemies that handle their own collision logic.
# collide_with_areas = true is explicitly overridden in the scene file via the engine GUI.
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
	is_active = false
	assert(player is Player, "Ray: player must be a Player")
	if not player is Player:
		push_error("Ray: player must be a Player")

	# _physics_process relies on StateMachine running before Ray (sibling node order).
	# Validate that assumption so a scene-tree reorder is caught immediately.
	var sm: Node = player.state_machine if player else null
	if sm and sm.get_index() > get_index():
		push_warning("Ray: StateMachine must be ordered before Ray in the scene tree")


# Resolves the ray collision and decides where the end point is to draw the laser sight.
func _physics_process(_delta: float) -> void:
	# RayCast2D auto-updates once per physics frame before any _physics_process callbacks run,
	# so by this point its cached result reflects the player's pre-movement position.
	# Calling force_raycast_update() here re-queries AFTER StateMachine._physics_process has
	# already called move_and_slide(), keeping the laser sight accurate to the post-move position.
	# This relies on StateMachine being processed before Ray in the scene tree (node order).
	# If that order changes, the visual will be one frame stale — same as not calling this at all.
	# Ref: docs/godot/classes/class_raycast2d.rst:26 (auto-update per frame)
	# Ref: docs/godot/classes/class_raycast2d.rst:272 (force_raycast_update description)
	force_raycast_update()
	var end_global: Vector2 = get_collision_point() if is_colliding() else to_global(
		target_position,
	)
	line.set_point_position(1, line.to_local(end_global))
	dot.position = to_local(end_global)


func shoot() -> bool:
	if not is_active:
		return false

	if not GameState.try_consume_ammo():
		return false

	shot.emit(rotation)

	var muzzle_pos: Vector2 = line.to_global(line.get_point_position(0))
	var hit_pos: Vector2 = line.to_global(line.get_point_position(1))
	light.flash(to_local(muzzle_pos))
	Spawner.spawn_shoot_effects(muzzle_pos, hit_pos, rotation, player.body.flip_h)

	# _unhandled_input fires before _physics_process, so is_colliding() here
	# reflects the previous physics tick's world — collision is one tick stale.
	# This is an accepted trade‑off for normal gameplay speeds; fast‑moving targets
	# can be missed by one frame.
	if is_colliding():
		var collider: Object = get_collider()
		if collider:
			# Hit an enemy logic.
			if collider is BaseEnemy:
				var enemy: BaseEnemy = collider
				enemy.ouch(1) # TODO: Set this with weapon damage prop later

			# Hit a solid tile logic.
			else:
				var collision_point: Vector2 = get_collision_point()
				var normal: Vector2 = get_collision_normal()
				var impact_rot: float = normal.angle()
				Spawner.spawn_bullet_impact(collision_point, impact_rot)

	# Shot fired, may miss or hit something.
	return true
