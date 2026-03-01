# Spawner
extends Node

const BULLET_CASING = preload("uid://brkax245qceky")
const MUZZLE_FLASH = preload("uid://dhv0cshyajm8r")
const BULLET_TRAIL = preload("uid://bwhu4xdomjxnx")
const LOOT = preload("uid://cgcf4l0byw3ur")


func spawn(scene: PackedScene, args: Array) -> void:
	get_tree().current_scene.add_child(scene.instantiate().init.callv(args))


func spawn_money(pos: Vector2) -> void:
	spawn(LOOT, ["money", pos])


func spawn_shoot_effects(p1: Vector2, p2: Vector2, rotation: float, flip_h: bool) -> void:
	spawn(BULLET_CASING, [p1, flip_h])
	spawn(MUZZLE_FLASH, [p1, rotation])
	spawn(BULLET_TRAIL, [p1, p2])
