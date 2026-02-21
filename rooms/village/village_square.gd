extends Node


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_down"):
		spawn_loot("handgun", Vector2(102.0, 144.0))
	if Input.is_action_just_pressed("ui_up"):
		spawn_loot("rifle", Vector2(250.0, 144.0))


func spawn_loot(type: StringName, pos: Vector2) -> void:
	var loot: Loot = preload("res://entities/loot/loot.tscn").instantiate()
	loot.init(type, pos)
	add_child(loot)
