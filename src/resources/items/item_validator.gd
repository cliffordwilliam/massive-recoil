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
	_validate_ammo_type(data)


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


static func _validate_ammo_type(data: ItemData) -> void:
	# A weapon with AmmoType.NONE is valid — infinite-ammo weapon. NONE is included
	# in AmmoType.values(), so the enum check below covers it intentionally.
	if data.type != ItemData.Type.WEAPON:
		Utils.require(
			data.ammo_type == ItemData.AmmoType.NONE,
			"ItemData '%s': ammo_type must be NONE for non-weapon type" % data.id
		)
		return
	Utils.require(
		data.ammo_type in ItemData.AmmoType.values(),
		"ItemData '%s': ammo_type %d is not a valid AmmoType enum value" % [data.id, data.ammo_type]
	)
