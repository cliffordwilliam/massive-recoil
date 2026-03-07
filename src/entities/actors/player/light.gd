# Flashes a light at a given position. Exposes a single flash() method.
# Only the player can use this, so its parent must be the player.
class_name Light
extends Sprite2D

const FLASH_DURATION: float = 0.083

var tween: Tween


func _exit_tree() -> void:
	tween = Utils.kill_tween(tween)


func flash(pos: Vector2) -> void:
	position = pos
	modulate.a = 1.0
	tween = Utils.kill_tween(tween)
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, FLASH_DURATION)
