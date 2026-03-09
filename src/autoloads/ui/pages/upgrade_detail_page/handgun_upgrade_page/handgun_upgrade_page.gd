# Shows all handgun upgrade options.
# Player can browse and pick "Damage", "FireRate", "ReloadSpeed" or "MagazineSize".
# TODO: If there are new option in here, then new tag shows up on the option.
class_name HandgunUpgradePage
extends BasePage

const UPGRADE_DETAIL_PAGE_DAMAGE_LIST_ITEM = preload("uid://b3ygoo0vm536r")
const UPGRADE_DETAIL_PAGE_FIRE_RATE_LIST_ITEM = preload("uid://bvd1yjlcufdtr")
const UPGRADE_DETAIL_PAGE_MAGAZINE_SIZE_LIST_ITEM = preload("uid://4h038w4e42fd")
const UPGRADE_DETAIL_PAGE_RELOAD_SPEED_LIST_ITEM = preload("uid://ba5kg1c1n162s")
const DAMAGE_ID: StringName = &"damage"
const FIRE_RATE_ID: StringName = &"fire_rate"
const MAGAZINE_SIZE_ID: StringName = &"magazine_size"
const RELOAD_SPEED_ID: StringName = &"reload_speed"

@onready var money: NumberDisplay = $Money
@onready var scroll_list: ScrollList = $ScrollList
@onready var damage: UpgradeTrackDisplay = $Damage
@onready var fire_rate: UpgradeTrackDisplay = $FireRate
@onready var reload_speed: UpgradeTrackDisplay = $ReloadSpeed
@onready var magazine_size: UpgradeTrackDisplay = $MagazineSize


func _hydrate_ui() -> void:
	# TODO: Need a feature to reveal new option item then toggle my option item tags.
	# This page will only ever have 4 items here so this approach is fine.
	var scroll_list_items: Array[ListItem] = []

	var damage_item: ListItem = UPGRADE_DETAIL_PAGE_DAMAGE_LIST_ITEM.instantiate()
	damage_item.set_id(DAMAGE_ID)
	scroll_list_items.append(damage_item)

	var fire_rate_item: ListItem = UPGRADE_DETAIL_PAGE_FIRE_RATE_LIST_ITEM.instantiate()
	fire_rate_item.set_id(FIRE_RATE_ID)
	scroll_list_items.append(fire_rate_item)

	var magazine_size_item: ListItem = UPGRADE_DETAIL_PAGE_MAGAZINE_SIZE_LIST_ITEM.instantiate()
	magazine_size_item.set_id(MAGAZINE_SIZE_ID)
	scroll_list_items.append(magazine_size_item)

	var reload_speed_item: ListItem = UPGRADE_DETAIL_PAGE_RELOAD_SPEED_LIST_ITEM.instantiate()
	reload_speed_item.set_id(RELOAD_SPEED_ID)
	scroll_list_items.append(reload_speed_item)

	scroll_list.set_items(scroll_list_items)

	money.display_number(GameState.get_money_count())

	var weapon: WeaponData = GameState.get_weapon_by_id(GameState.HANDGUN_ID)
	if weapon:
		damage.display_track(weapon.damage)
		damage_item.initialize(weapon.damage.get_next_index(), weapon.damage.get_next_cost())

		fire_rate.display_track(weapon.fire_rate)
		fire_rate_item.initialize(weapon.fire_rate.get_next_index(), weapon.fire_rate.get_next_cost())

		reload_speed.display_track(weapon.reload_speed)
		reload_speed_item.initialize(weapon.reload_speed.get_next_index(), weapon.reload_speed.get_next_cost())

		magazine_size.display_track(weapon.magazine_size)
		magazine_size_item.initialize(weapon.magazine_size.get_next_index(), weapon.magazine_size.get_next_cost())
	else:
		damage.clear_previous_slots()
		fire_rate.clear_previous_slots()
		reload_speed.clear_previous_slots()
		magazine_size.clear_previous_slots()


func _on_scroll_list_item_selected(id: StringName) -> void: # Connected via engine GUI.
	if id == DAMAGE_ID:
		if GameState.try_to_buy_a_weapon_damage_upgrade_by_id(GameState.HANDGUN_ID):
			_hydrate_ui()
		# TODO: Play a sound on success and fail later.
	elif id == FIRE_RATE_ID:
		if GameState.try_to_buy_a_weapon_fire_rate_upgrade_by_id(GameState.HANDGUN_ID):
			_hydrate_ui()
		# TODO: Play a sound on success and fail later.
	elif id == MAGAZINE_SIZE_ID:
		if GameState.try_to_buy_a_weapon_magazine_size_upgrade_by_id(GameState.HANDGUN_ID):
			_hydrate_ui()
		# TODO: Play a sound on success and fail later.
	elif id == RELOAD_SPEED_ID:
		if GameState.try_to_buy_a_weapon_reload_speed_upgrade_by_id(GameState.HANDGUN_ID):
			_hydrate_ui()
		# TODO: Play a sound on success and fail later.
