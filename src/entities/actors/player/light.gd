class_name Light
extends Sprite2D

# This flash a light in a given position, has one API to set where to show up to flash
# Only player can use this, so its parent must be the player
const FLASH_DURATION: float = 0.083

var tween: Tween


func _exit_tree() -> void:
	_kill_tween_if_exists()


func flash(pos: Vector2) -> void:
	position = pos
	modulate.a = 1.0
	_kill_tween_if_exists()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, FLASH_DURATION)


func _kill_tween_if_exists() -> void:
	if tween:
		tween.kill()
		tween = null
