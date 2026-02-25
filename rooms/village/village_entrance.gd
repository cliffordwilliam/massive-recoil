class_name VillageEntrance
extends Room


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_left"):
		spawn_loot("money", Vector2(250.0, 120.0))


func spawn_loot(type: String, pos: Vector2) -> void:
	var loot: Loot = preload("res://entities/loot/loot.tscn").instantiate()
	loot.init(type, pos)
	add_child(loot)
