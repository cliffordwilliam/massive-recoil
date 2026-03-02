class_name Light
extends Sprite2D

const FLASH_DURATION: float = 0.083

var tween: Tween


func flash(pos: Vector2) -> void:
	position = pos
	modulate.a = 1.0
	if tween:
		tween.kill()
		tween = null
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, FLASH_DURATION)
