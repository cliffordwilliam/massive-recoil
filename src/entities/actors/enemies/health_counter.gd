# All enemy have this health counter, it just counts health and shouts when its zero
# It needs EnemyData resource for good DX
# (e.g. change red dino max health resource, all red dino gets updated)
class_name HealthCounter
extends Node

signal died

@export var enemy_data: EnemyData

var is_dead: bool = false
var health: int:
	get:
		return _health
	set(value):
		if is_dead:
			return

		# Health can only decrease
		if value > _health:
			return

		_health = max(value, 0)

		if _health == 0:
			is_dead = true
			died.emit()
var _health: int = 0


func _ready() -> void:
	assert(enemy_data != null, "HealthCounter: requires EnemyData assigned")
	_health = enemy_data.max_health
