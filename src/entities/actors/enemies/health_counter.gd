# All enemies have this health counter.
# it just tracks health and emits a signal when it reaches zero.
# It needs an EnemyData resource for good DX.
# (e.g. change the red dino max health resource and all red dinos get updated)
class_name HealthCounter
extends Node

signal died

@export var enemy_data: EnemyData

var is_dead: bool = false
# Intentional: Once dead, the setter silently ignores all future sets. There is no healing feature.
var health: int:
	get:
		return _health
	set(value):
		if is_dead:
			return

		# Health can only decrease.
		if value > _health:
			return

		_health = max(value, 0)

		if _health == 0:
			is_dead = true
			died.emit()
var _health: int = 0


func _ready() -> void:
	if not Utils.require(enemy_data != null, "HealthCounter: requires EnemyData assigned"):
		return

	_health = enemy_data.max_health
