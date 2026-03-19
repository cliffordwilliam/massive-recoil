class_name ItemValidator
extends RefCounted
## Validates [ItemData] field constraints. Called by [ItemDefinitions] during construction.
##
## [method validate] runs all checks in order, crashing on the first violation.
## Private methods are the individual checks.


## Runs all field constraint checks on [param data].
## Crashes via [method Utils.require] on the first violation.
static func validate(data: ItemData) -> void:
	_validate_id(data)
	_validate_ui_name(data)
	_validate_description(data)
	_validate_buy_price(data)
	_validate_sell_price(data)
	_validate_stack_size(data)
	_validate_availability(data)
	_validate_inventory_size(data)
	_validate_ammo_type(data)


static func _validate_id(data: ItemData) -> void:
	var id_str: String = str(data.id)
	Utils.require(not id_str.is_empty(), "ItemData: id must not be empty")
	Utils.require(
		id_str.is_valid_ascii_identifier(),
		(
			"ItemData '%s': id must contain only letters, digits, and underscores, "
			+ "and must not start with a digit" % data.id
		)
	)
	Utils.require(
		id_str == id_str.to_lower(),
		"ItemData '%s': id must be all lowercase (snake_case convention)" % data.id
	)


static func _validate_ui_name(data: ItemData) -> void:
	Utils.require(not data.ui_name.is_empty(), "ItemData '%s': ui_name must not be empty" % data.id)
	Utils.require(
		data.ui_name.length() <= ItemSchema.MAX_NAME_LENGTH,
		(
			"ItemData '%s': ui_name exceeds max %d chars (got %d)"
			% [data.id, ItemSchema.MAX_NAME_LENGTH, data.ui_name.length()]
		)
	)


static func _validate_description(data: ItemData) -> void:
	Utils.require(
		not data.description.is_empty(), "ItemData '%s': description must not be empty" % data.id
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


static func _validate_ammo_type(data: ItemData) -> void:
	# A weapon with AmmoType.NONE is valid — infinite-ammo weapon.
	if data.type != ItemData.Type.WEAPON:
		Utils.require(
			data.ammo_type == ItemData.AmmoType.NONE,
			"ItemData '%s': ammo_type must be NONE for non-weapon type" % data.id
		)
