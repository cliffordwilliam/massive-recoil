class_name ItemValidator
extends RefCounted
## Validates [ItemData] field constraints. Called by [ItemDefinitions] during construction.
##
## [method validate] runs all checks in order, crashing on the first violation.
## Private methods are the individual checks.

static var _id_regex: RegEx = RegEx.create_from_string(ItemSchema.ID_PATTERN)


## Runs all field constraint checks on [param data].
## Crashes via [method Utils.require] on the first violation.
static func validate(data: ItemData) -> void:
	_validate_type(data)
	_validate_id(data)
	_validate_ui_name(data)
	_validate_description(data)
	_validate_buy_price(data)
	_validate_sell_price(data)
	_validate_price_relationship(data)
	_validate_stack_size(data)
	_validate_availability(data)
	_validate_inventory_size(data)
	_validate_weapon_data(data)
	_validate_upgrade_stat(data)


static func _validate_type(data: ItemData) -> void:
	Utils.require(
		data.type in ItemData.Type.values(),
		"ItemData '%s': type %d is not a valid Type enum value" % [data.id, data.type]
	)


static func _validate_id(data: ItemData) -> void:
	# id is StringName — convert to String for length checks and regex matching.
	var id_str: String = String(data.id)
	Utils.require(id_str.length() >= ItemSchema.MIN_ID_LENGTH, "ItemData: id must not be empty")
	Utils.require(
		id_str.length() <= ItemSchema.MAX_ID_LENGTH,
		(
			"ItemData '%s': id exceeds max %d chars (got %d)"
			% [data.id, ItemSchema.MAX_ID_LENGTH, id_str.length()]
		)
	)
	# Anchors ^...$ in ID_PATTERN make search() behave as a full-string match.
	# GDScript's RegEx API has no match() method — this is the correct approach.
	Utils.require(
		_id_regex.search(id_str) != null,
		(
			(
				"ItemData '%s': id must match ^[a-z]([a-z0-9_]*[a-z0-9])?$ "
				+ "(lowercase snake_case, must start and end with a letter or digit)"
			)
			% data.id
		)
	)


static func _validate_ui_name(data: ItemData) -> void:
	Utils.require(
		data.ui_name.length() >= ItemSchema.MIN_NAME_LENGTH,
		"ItemData '%s': ui_name must not be empty" % data.id
	)
	Utils.require(
		data.ui_name.length() <= ItemSchema.MAX_NAME_LENGTH,
		(
			"ItemData '%s': ui_name exceeds max %d chars (got %d)"
			% [data.id, ItemSchema.MAX_NAME_LENGTH, data.ui_name.length()]
		)
	)


static func _validate_description(data: ItemData) -> void:
	Utils.require(
		data.description.length() >= ItemSchema.MIN_DESCRIPTION_LENGTH,
		"ItemData '%s': description must not be empty" % data.id
	)
	Utils.require(
		data.description.length() <= ItemSchema.MAX_DESCRIPTION_LENGTH,
		(
			"ItemData '%s': description exceeds max %d chars (got %d)"
			% [data.id, ItemSchema.MAX_DESCRIPTION_LENGTH, data.description.length()]
		)
	)


static func _validate_buy_price(data: ItemData) -> void:
	Utils.require(
		data.buy_price >= ItemSchema.MIN_PRICE and data.buy_price <= ItemSchema.MAX_PRICE,
		(
			"ItemData '%s': buy_price %d must be in [%d, %d]"
			% [data.id, data.buy_price, ItemSchema.MIN_PRICE, ItemSchema.MAX_PRICE]
		)
	)


static func _validate_sell_price(data: ItemData) -> void:
	Utils.require(
		data.sell_price >= ItemSchema.MIN_PRICE and data.sell_price <= ItemSchema.MAX_PRICE,
		(
			"ItemData '%s': sell_price %d must be in [%d, %d]"
			% [data.id, data.sell_price, ItemSchema.MIN_PRICE, ItemSchema.MAX_PRICE]
		)
	)


static func _validate_price_relationship(data: ItemData) -> void:
	# No constraint on sell_price when item is not buyable.
	if data.buy_price == 0:
		return
	Utils.require(
		data.sell_price < data.buy_price,
		(
			"ItemData '%s': sell_price %d must be less than buy_price %d"
			% [data.id, data.sell_price, data.buy_price]
		)
	)


static func _validate_stack_size(data: ItemData) -> void:
	Utils.require(
		data.stack_size >= ItemSchema.MIN_STACK and data.stack_size <= ItemSchema.MAX_STACK,
		(
			"ItemData '%s': stack_size %d must be in [%d, %d]"
			% [data.id, data.stack_size, ItemSchema.MIN_STACK, ItemSchema.MAX_STACK]
		)
	)


static func _validate_availability(data: ItemData) -> void:
	if data.buy_price == 0:
		Utils.require(
			data.availability == ItemSchema.AVAILABILITY_NOT_FOR_SALE,
			(
				"ItemData '%s': buy_price is 0 — availability must be AVAILABILITY_NOT_FOR_SALE"
				% data.id
			)
		)
		return

	# buy_price != 0 — item is shop-available. Both directions of the contract are
	# enforced: AVAILABILITY_NOT_FOR_SALE equals MAX_CHAPTER + 1, which exceeds
	# MAX_CHAPTER, so passing the sentinel with a non-zero buy_price fails this check.
	Utils.require(
		data.availability >= ItemSchema.MIN_CHAPTER and data.availability <= ItemSchema.MAX_CHAPTER,
		(
			"ItemData '%s': availability %d must be in [%d, %d] for shop items"
			% [data.id, data.availability, ItemSchema.MIN_CHAPTER, ItemSchema.MAX_CHAPTER]
		)
	)


static func _validate_inventory_size(data: ItemData) -> void:
	Utils.require(
		(
			data.inventory_size.x >= ItemSchema.MIN_SIZE_DIM
			and data.inventory_size.x <= ItemSchema.MAX_SIZE_DIM
		),
		(
			"ItemData '%s': inventory_size.x %d must be in [%d, %d]"
			% [data.id, data.inventory_size.x, ItemSchema.MIN_SIZE_DIM, ItemSchema.MAX_SIZE_DIM]
		)
	)
	Utils.require(
		(
			data.inventory_size.y >= ItemSchema.MIN_SIZE_DIM
			and data.inventory_size.y <= ItemSchema.MAX_SIZE_DIM
		),
		(
			"ItemData '%s': inventory_size.y %d must be in [%d, %d]"
			% [data.id, data.inventory_size.y, ItemSchema.MIN_SIZE_DIM, ItemSchema.MAX_SIZE_DIM]
		)
	)


static func _validate_weapon_data(data: ItemData) -> void:
	if data.type != ItemData.Type.WEAPON:
		Utils.require(
			data.weapon_data == null,
			"ItemData '%s': weapon_data must be null for non-weapon type" % data.id
		)
		return

	Utils.require(
		data.weapon_data != null,
		"ItemData '%s': weapon_data must not be null for weapon type" % data.id
	)

	var wd: WeaponData = data.weapon_data

	Utils.require(
		wd.ammo_type in WeaponData.AmmoType.values(),
		(
			"ItemData '%s': weapon_data.ammo_type %d is not a valid AmmoType value"
			% [data.id, wd.ammo_type]
		)
	)

	_validate_weapon_stat(data, "power", wd.power_min, wd.power_max, wd.power_upgrade_step)
	_validate_weapon_stat(
		data,
		"rate_of_fire",
		wd.rate_of_fire_min,
		wd.rate_of_fire_max,
		wd.rate_of_fire_upgrade_step,
	)
	_validate_weapon_stat(
		data,
		"reload_speed",
		wd.reload_speed_min,
		wd.reload_speed_max,
		wd.reload_speed_upgrade_step,
	)
	_validate_weapon_stat(
		data,
		"ammo_capacity",
		wd.ammo_capacity_min,
		wd.ammo_capacity_max,
		wd.ammo_capacity_upgrade_step,
	)


static func _validate_weapon_stat(
	data: ItemData, stat_name: String, min_val: int, max_val: int, step: int
) -> void:
	Utils.require(
		min_val >= ItemSchema.WEAPON_STAT_MIN and min_val <= ItemSchema.WEAPON_STAT_MAX,
		(
			"ItemData '%s': weapon_data.%s_min %d must be in [%d, %d]"
			% [data.id, stat_name, min_val, ItemSchema.WEAPON_STAT_MIN, ItemSchema.WEAPON_STAT_MAX]
		)
	)
	Utils.require(
		max_val >= ItemSchema.WEAPON_STAT_MIN and max_val <= ItemSchema.WEAPON_STAT_MAX,
		(
			"ItemData '%s': weapon_data.%s_max %d must be in [%d, %d]"
			% [data.id, stat_name, max_val, ItemSchema.WEAPON_STAT_MIN, ItemSchema.WEAPON_STAT_MAX]
		)
	)
	Utils.require(
		min_val <= max_val,
		(
			"ItemData '%s': weapon_data.%s_min %d must be <= %s_max %d"
			% [data.id, stat_name, min_val, stat_name, max_val]
		)
	)
	Utils.require(
		step >= 0,
		"ItemData '%s': weapon_data.%s_upgrade_step %d must be >= 0" % [data.id, stat_name, step]
	)


static func _validate_upgrade_stat(data: ItemData) -> void:
	if data.type != ItemData.Type.WEAPON_UPGRADE:
		Utils.require(
			data.upgrade_stat == ItemData.UpgradeStat.NONE,
			"ItemData '%s': upgrade_stat must be NONE for non-weapon-upgrade type" % data.id
		)
		return

	Utils.require(
		data.upgrade_stat != ItemData.UpgradeStat.NONE,
		"ItemData '%s': upgrade_stat must not be NONE for weapon upgrade type" % data.id
	)
	Utils.require(
		data.upgrade_stat in ItemData.UpgradeStat.values(),
		(
			"ItemData '%s': upgrade_stat %d is not a valid UpgradeStat enum value"
			% [data.id, data.upgrade_stat]
		)
	)
