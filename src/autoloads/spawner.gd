# Spawner Autoload. Centralises instantiation of effects and loot into the current scene.
# TODO: Dedicate its own node to add stuff in the world, add pooling too, acceptable for now in dev.
extends Node

const BULLET_CASING = preload("uid://brkax245qceky")
const MUZZLE_FLASH = preload("uid://cja3dkktxxtpw")
const BULLET_TRAIL = preload("uid://bwhu4xdomjxnx")
const LOOT = preload("uid://cgcf4l0byw3ur")
const BULLET_IMPACT_SOLID = preload("uid://csa5spk8g82e0")


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

	var flash: AutoFreeAnimatedEffect = MUZZLE_FLASH.instantiate()
	scene.add_child(flash)
	flash.initialize(p1, rot)

	var trail: BulletTrail = BULLET_TRAIL.instantiate()
	scene.add_child(trail)
	trail.initialize(p1, p2)


func spawn_bullet_impact(pos: Vector2, rot: float) -> void:
	if not get_tree().current_scene:
		return

	var impact: AutoFreeAnimatedEffect = BULLET_IMPACT_SOLID.instantiate()
	get_tree().current_scene.add_child(impact)
	impact.initialize(pos, rot)
