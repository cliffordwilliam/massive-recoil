extends Node

# Autoload. Centralises instantiation of effects and loot into the current scene.
const BULLET_CASING = preload("uid://brkax245qceky")
const MUZZLE_FLASH = preload("uid://dhv0cshyajm8r")
const BULLET_TRAIL = preload("uid://bwhu4xdomjxnx")
const LOOT = preload("uid://cgcf4l0byw3ur")


func spawn_money(pos: Vector2) -> void:
	if not get_tree().current_scene:
		return

	var loot: Loot = LOOT.instantiate()
	get_tree().current_scene.add_child(loot)
	loot.initialize(&"money", pos)


func spawn_shoot_effects(p1: Vector2, p2: Vector2, rot: float, flip_h: bool) -> void:
	if not get_tree().current_scene:
		return

	var scene: Node = get_tree().current_scene

	var casing: BulletCasing = BULLET_CASING.instantiate()
	scene.add_child(casing)
	casing.initialize(p1, flip_h)

	var flash: MuzzleFlash = MUZZLE_FLASH.instantiate()
	scene.add_child(flash)
	flash.initialize(p1, rot)

	var trail: BulletTrail = BULLET_TRAIL.instantiate()
	scene.add_child(trail)
	trail.initialize(p1, p2)
