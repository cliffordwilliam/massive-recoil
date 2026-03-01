# Spawner
extends Node

const BULLET_CASING = preload("uid://brkax245qceky")
const MUZZLE_FLASH = preload("uid://dhv0cshyajm8r")
const BULLET_TRAIL = preload("uid://bwhu4xdomjxnx")
const LOOT = preload("uid://cgcf4l0byw3ur")


func spawn_money(pos: Vector2) -> void:
	get_tree().current_scene.add_child(LOOT.instantiate().init("money", pos))


func spawn_shoot_effects(p1: Vector2, p2: Vector2, rot: float, flip_h: bool) -> void:
	var scene: Node = get_tree().current_scene
	scene.add_child(BULLET_CASING.instantiate().init(p1, flip_h))
	scene.add_child(MUZZLE_FLASH.instantiate().init(p1, rot))
	scene.add_child(BULLET_TRAIL.instantiate().init(p1, p2))
