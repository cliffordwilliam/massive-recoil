# Spawner
extends Node


func spawn(uid: String, args: Array) -> void:
	get_tree().current_scene.add_child(load(uid).instantiate().init.callv(args))
