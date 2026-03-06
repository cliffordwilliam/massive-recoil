# Enemy base class. “Enemy” refers to all things that the player can shoot at (wooden crates, etc.).
# Enemies are all just Area2D, monitorable only, on the enemy layer only.
# All enemies must have a "dead" animation.
# All must use animated assets from res/assets/sprites/.
class_name BaseEnemy
extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var queue_free_timer: Timer = $QueueFreeTimer
@onready var health_counter: HealthCounter = $HealthCounter
@onready var white_flash_timer: Timer = $WhiteFlashTimer


func on_died() -> void:
	pass # Children may override on_died logic here (e.g. drops, sounds).


func ouch(damage: float) -> void:
	health_counter.health -= damage
	animated_sprite_2d.material.set_shader_parameter("flash", true)
	white_flash_timer.start()


# Linger around a bit before disappearing after being destroyed, by design.
func _on_queue_free_timer_timeout() -> void: # Connected via engine GUI (one shot).
	queue_free()


func _on_health_counter_died() -> void: # Connected via engine GUI (one shot).
	if not Utils.require(
		animated_sprite_2d.sprite_frames.has_animation("dead"),
		"BaseEnemy: requires dead animation",
	):
		return

	collision_layer = 0
	queue_free_timer.start()
	animated_sprite_2d.play("dead")
	on_died()


func _on_white_flash_timer_timeout() -> void: # Connected via engine GUI.
	animated_sprite_2d.material.set_shader_parameter("flash", false)
