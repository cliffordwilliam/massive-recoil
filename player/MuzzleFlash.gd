extends AnimatedSprite


func _ready() -> void:
	play("default")


func _on_MuzzleFlash_animation_finished() -> void:
	queue_free()
