class_name Light
extends Sprite2D


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	modulate.a = move_toward(modulate.a, 0.0, 12.0 * delta)
	if is_zero_approx(modulate.a):
		set_physics_process(false)


func flash(pos: Vector2) -> void:
	position = pos
	modulate.a = 1.0
	set_physics_process(true)
