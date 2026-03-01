# Spawner
extends Node

const MUZZLE_FLASH = preload("uid://brkax245qceky")
const SHELL = preload("uid://dhv0cshyajm8r")
const BULLET_TRAIL = preload("uid://bwhu4xdomjxnx")
const MONEY = preload("uid://cgcf4l0byw3ur")


func spawn(scene: PackedScene, args: Array) -> void:
	get_tree().current_scene.add_child(scene.instantiate().init.callv(args))


func spawn_money(pos: Vector2) -> void:
	spawn(MONEY, ["money", pos])


func spawn_shoot_effects(p1: Vector2, p2: Vector2, rotation: float, flip_h: bool) -> void:
	spawn(MUZZLE_FLASH, [p1, flip_h])
	spawn(SHELL, [p1, rotation])
	spawn(BULLET_TRAIL, [p1, p2])
