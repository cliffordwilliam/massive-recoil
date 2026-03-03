class_name BaseEnemy
extends Area2D

# Enemy base class, enemy refers to all things that the player can shoot at (wooden crates, etc)
# Enemies are all just Area2D, monitorable only, on enemy layer only
# All enemies must have "dead" animation
# All must use animated assets from res/assets/sprites/
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var queue_free_timer: Timer = $QueueFreeTimer
@onready var health_counter: HealthCounter = $HealthCounter


func on_died() -> void:
	pass # Children may override on_died logic here (e.g. drops, sounds)


func ouch(damage: int) -> void:
	health_counter.health -= damage


# Linger around a bit before disappearing after being destroyed by design
func _on_queue_free_timer_timeout() -> void: # Connected via engine GUI (one shot)
	queue_free()


func _on_health_counter_died() -> void: # Connected via engine GUI (one shot)
	collision_layer = 0
	collision_mask = 0
	queue_free_timer.start()
	animated_sprite_2d.play("dead")
	on_died()
