@abstract
# Enemy base class, enemy refers to all things that the player can shoot at (wooden crates, etc)
# Enemies are all just Area2D, monitorable only, on enemy layer only
# All enemies must have "dead" animation
# All must use animated assets from res/assets/sprites/
class_name BaseEnemy
extends Area2D

# All enemy can die
var is_dead: bool = false:
	set(value):
		# This is one way, can only toggle to dead, once dead stays dead
		if value == false:
			return

		is_dead = true
		queue_free_timer.start()
		animated_sprite_2d.play("dead")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var queue_free_timer: Timer = $QueueFreeTimer


func ouch() -> void:
	pass # Children must override ouch logic here


# Linger around a bit before disappearing after being destroyed by design
func _on_queue_free_timer_timeout() -> void: # Connected via engine GUI
	queue_free()
