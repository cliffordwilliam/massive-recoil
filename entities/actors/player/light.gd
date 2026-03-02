class_name Light
extends Sprite2D

var tween: Tween


func flash(pos: Vector2) -> void:
	position = pos
	modulate.a = 1.0
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.083)
