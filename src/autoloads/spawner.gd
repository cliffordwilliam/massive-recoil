# Spawner Autoload. Centralises instantiation of effects and loot into the current scene.
# All spawned nodes go into the "Effects" child node of the current BaseRoom scene.
extends Node

const BULLET_CASING = preload("uid://brkax245qceky")
const MUZZLE_FLASH = preload("uid://cja3dkktxxtpw")
const BULLET_TRAIL = preload("uid://bwhu4xdomjxnx")
const LOOT = preload("uid://cgcf4l0byw3ur")
const BULLET_IMPACT_SOLID = preload("uid://csa5spk8g82e0")


func spawn_money(pos: Vector2) -> void:
	var container: Node = _get_effect_container()
	if not container:
		return

	var loot: Loot = LOOT.instantiate()
	container.add_child(loot)
	loot.initialize(&"money", pos)


func spawn_shoot_effects(p1: Vector2, p2: Vector2, rot: float, flip_h: bool) -> void:
	var container: Node = _get_effect_container()
	if not container:
		return

	var casing: BulletCasing = BULLET_CASING.instantiate()
	container.add_child(casing)
	casing.initialize(p1, flip_h)

	var flash: AutoFreeAnimatedEffect = MUZZLE_FLASH.instantiate()
	container.add_child(flash)
	flash.initialize(p1, rot)

	var trail: BulletTrail = BULLET_TRAIL.instantiate()
	container.add_child(trail)
	trail.initialize(p1, p2)


func spawn_bullet_impact(pos: Vector2, rot: float) -> void:
	var container: Node = _get_effect_container()
	if not container:
		return

	var impact: AutoFreeAnimatedEffect = BULLET_IMPACT_SOLID.instantiate()
	container.add_child(impact)
	impact.initialize(pos, rot)


func _get_effect_container() -> Node:
	var scene: Node = get_tree().current_scene
	if not Utils.require(scene != null, "Spawner: no current scene"):
		return null
	var container: Node = scene.get_node_or_null("Effects")
	if not Utils.require(container != null, "Spawner: current scene has no Effects node"):
		return null
	return container
