class_name ItemDefinitions
extends RefCounted
## Static item catalog. [method get_all] constructs and returns all [ItemData] instances.
##
## Add, remove, or edit entries via [method _make] calls in [method get_all].
## Field constraints are documented in [ItemData] and [ItemSchema].


## Constructs and returns all item definitions. Add, remove, or edit items here.
static func get_all() -> Array[ItemData]:
	return [
		_make(
			# id
			&"field_medkit",
			#
			# type
			ItemData.Type.MED,
			#
			# ui name
			"Field Kit",
			#
			# description
			"Restores full health. Rare emergency medkit.",
			#
			# inventory size
			Vector2i(2, 1),
			#
			# buy price
			5000,
			#
			# sell price
			2500,
			#
			# stack size
			ItemSchema.MIN_STACK,
			#
			# availability
			ItemSchema.MIN_CHAPTER,
			#
			# ammo type
			ItemData.AmmoType.NONE,
		),
		_make(
			# id
			&"sterile_band",
			#
			# type
			ItemData.Type.MED,
			#
			# ui name
			"Sterile Band",
			#
			# description
			"Clean bandage. Restores a small amount of health.",
			#
			# inventory size
			Vector2i(2, 1),
			#
			# buy price
			0,
			#
			# sell price
			300,
			#
			# stack size
			ItemSchema.MIN_STACK,
			#
			# availability
			ItemSchema.AVAILABILITY_NOT_FOR_SALE,
			#
			# ammo type
			ItemData.AmmoType.NONE,
		),
		_make(
			# id
			&"antiseptic",
			#
			# type
			ItemData.Type.MED,
			#
			# ui name
			"Antiseptic",
			#
			# description
			"Antiseptic vial used to disinfect wounds.",
			#
			# inventory size
			Vector2i(1, 1),
			#
			# buy price
			0,
			#
			# sell price
			400,
			#
			# stack size
			ItemSchema.MIN_STACK,
			#
			# availability
			ItemSchema.AVAILABILITY_NOT_FOR_SALE,
			#
			# ammo type
			ItemData.AmmoType.NONE,
		),
		_make(
			# id
			&"treat_band",
			#
			# type
			ItemData.Type.MED,
			#
			# ui name
			"Treat Band",
			#
			# description
			"Bandage treated with antiseptic. Restores health.",
			#
			# inventory size
			Vector2i(2, 1),
			#
			# buy price
			0,
			#
			# sell price
			900,
			#
			# stack size
			ItemSchema.MIN_STACK,
			#
			# availability
			ItemSchema.AVAILABILITY_NOT_FOR_SALE,
			#
			# ammo type
			ItemData.AmmoType.NONE,
		),
		_make(
			# id
			&"handgun_ammo",
			#
			# type
			ItemData.Type.AMMO,
			#
			# ui name
			"HG Ammo",
			#
			# description
			"Standard handgun cartridges.",
			#
			# inventory size
			Vector2i(2, 1),
			#
			# buy price
			0,
			#
			# sell price
			50,
			#
			# stack size
			50,
			#
			# availability
			ItemSchema.AVAILABILITY_NOT_FOR_SALE,
			#
			# ammo type
			ItemData.AmmoType.NONE,
		),
		_make(
			# id
			&"smg_ammo",
			#
			# type
			ItemData.Type.AMMO,
			#
			# ui name
			"SMG Ammo",
			#
			# description
			"Ammo for high-rate SMG weapons.",
			#
			# inventory size
			Vector2i(2, 1),
			#
			# buy price
			0,
			#
			# sell price
			20,
			#
			# stack size
			100,
			#
			# availability
			ItemSchema.AVAILABILITY_NOT_FOR_SALE,
			#
			# ammo type
			ItemData.AmmoType.NONE,
		),
		_make(
			# id
			&"pack_upgrade",
			#
			# type
			ItemData.Type.INVENTORY_UPGRADE,
			#
			# ui name
			"Pack Upgrade",
			#
			# description
			"Permanently increases inventory capacity.",
			#
			# inventory size
			Vector2i(2, 1),
			#
			# buy price
			30000,
			#
			# sell price
			0,
			#
			# stack size
			ItemSchema.MIN_STACK,
			#
			# availability
			ItemSchema.MIN_CHAPTER,
			#
			# ammo type
			ItemData.AmmoType.NONE,
		),
		_make(
			# id
			&"damage_upgrade",
			#
			# type
			ItemData.Type.WEAPON_UPGRADE,
			#
			# ui name
			"DMG Upgrade",
			#
			# description
			"Upgrade that increases weapon damage.",
			#
			# inventory size
			Vector2i(2, 2),
			#
			# buy price
			5000,
			#
			# sell price
			0,
			#
			# stack size
			ItemSchema.MIN_STACK,
			#
			# availability
			ItemSchema.MIN_CHAPTER,
			#
			# ammo type
			ItemData.AmmoType.NONE,
		),
		_make(
			# id
			&"handgun",
			#
			# type
			ItemData.Type.WEAPON,
			#
			# ui name
			"Handgun",
			#
			# description
			"Reliable semi-auto handgun.",
			#
			# inventory size
			Vector2i(2, 2),
			#
			# buy price
			8000,
			#
			# sell price
			4000,
			#
			# stack size
			ItemSchema.MIN_STACK,
			#
			# availability
			ItemSchema.MIN_CHAPTER,
			#
			# ammo type
			ItemData.AmmoType.HANDGUN_AMMO,
		),
		_make(
			# id
			&"smg",
			#
			# type
			ItemData.Type.WEAPON,
			#
			# ui name
			"SMG",
			#
			# description
			"Compact SMG with very high fire rate.",
			#
			# inventory size
			Vector2i(3, 2),
			#
			# buy price
			16000,
			#
			# sell price
			8000,
			#
			# stack size
			ItemSchema.MIN_STACK,
			#
			# availability
			ItemSchema.MIN_CHAPTER,
			#
			# ammo type
			ItemData.AmmoType.SMG_AMMO,
		),
		_make(
			# id
			&"ornate_pendant",
			#
			# type
			ItemData.Type.TREASURE,
			#
			# ui name
			"Ornate Pndnt",
			#
			# description
			"Pendant with an empty gem socket.",
			#
			# inventory size
			Vector2i(1, 1),
			#
			# buy price
			0,
			#
			# sell price
			4000,
			#
			# stack size
			ItemSchema.MIN_STACK,
			#
			# availability
			ItemSchema.AVAILABILITY_NOT_FOR_SALE,
			#
			# ammo type
			ItemData.AmmoType.NONE,
		),
		_make(
			# id
			&"ruby_gem",
			#
			# type
			ItemData.Type.TREASURE,
			#
			# ui name
			"Ruby Gem",
			#
			# description
			"A polished red gemstone.",
			#
			# inventory size
			Vector2i(1, 1),
			#
			# buy price
			0,
			#
			# sell price
			2500,
			#
			# stack size
			ItemSchema.MIN_STACK,
			#
			# availability
			ItemSchema.AVAILABILITY_NOT_FOR_SALE,
			#
			# ammo type
			ItemData.AmmoType.NONE,
		),
		_make(
			# id
			&"jeweled_pendant",
			#
			# type
			ItemData.Type.TREASURE,
			#
			# ui name
			"Jeweled Pndt",
			#
			# description
			"Pendant fitted with a brilliant ruby.",
			#
			# inventory size
			Vector2i(1, 1),
			#
			# buy price
			0,
			#
			# sell price
			9000,
			#
			# stack size
			ItemSchema.MIN_STACK,
			#
			# availability
			ItemSchema.AVAILABILITY_NOT_FOR_SALE,
			#
			# ammo type
			ItemData.AmmoType.NONE,
		),
		_make(
			# id
			&"maintenance_key",
			#
			# type
			ItemData.Type.KEY,
			#
			# ui name
			"Maint. Key",
			#
			# description
			"Maintenance key for service doors.",
			#
			# inventory size
			Vector2i(1, 1),
			#
			# buy price
			0,
			#
			# sell price
			0,
			#
			# stack size
			ItemSchema.MIN_STACK,
			#
			# availability
			ItemSchema.AVAILABILITY_NOT_FOR_SALE,
			#
			# ammo type
			ItemData.AmmoType.NONE,
		),
		_make(
			# id
			&"sun_key_fragment",
			#
			# type
			ItemData.Type.KEY,
			#
			# ui name
			"Sun Fragment",
			#
			# description
			"A fragment of a broken key.",
			#
			# inventory size
			Vector2i(1, 1),
			#
			# buy price
			0,
			#
			# sell price
			0,
			#
			# stack size
			ItemSchema.MIN_STACK,
			#
			# availability
			ItemSchema.AVAILABILITY_NOT_FOR_SALE,
			#
			# ammo type
			ItemData.AmmoType.NONE,
		),
		_make(
			# id
			&"moon_key_fragment",
			#
			# type
			ItemData.Type.KEY,
			#
			# ui name
			"Moon Shard",
			#
			# description
			"A curved fragment of a key.",
			#
			# inventory size
			Vector2i(1, 1),
			#
			# buy price
			0,
			#
			# sell price
			0,
			#
			# stack size
			ItemSchema.MIN_STACK,
			#
			# availability
			ItemSchema.AVAILABILITY_NOT_FOR_SALE,
			#
			# ammo type
			ItemData.AmmoType.NONE,
		),
		_make(
			# id
			&"sun_moon_key",
			#
			# type
			ItemData.Type.KEY,
			#
			# ui name
			"Sun/Moon Key",
			#
			# description
			"Two fragments forming a complete key.",
			#
			# inventory size
			Vector2i(1, 1),
			#
			# buy price
			0,
			#
			# sell price
			0,
			#
			# stack size
			ItemSchema.MIN_STACK,
			#
			# availability
			ItemSchema.AVAILABILITY_NOT_FOR_SALE,
			#
			# ammo type
			ItemData.AmmoType.NONE,
		),
	]


## Constructs and validates a single [ItemData] entry.
## Crashes via [method Utils.require] on the first constraint violation.
## See field invariants in "res://docs/decisions/item_architecture.md".
##
## [param availability] must be [constant ItemSchema.AVAILABILITY_NOT_FOR_SALE] when
## [param buy_price] is [code]0[/code], and a valid chapter value in
## [[constant ItemSchema.MIN_CHAPTER], [constant ItemSchema.MAX_CHAPTER]] when
## [param buy_price] is non-zero. Both directions are enforced by [ItemValidator] —
## no silent correction is applied.
static func _make(
	id: StringName,
	type: ItemData.Type,
	ui_name: String,
	description: String,
	inventory_size: Vector2i,
	buy_price: int,
	sell_price: int,
	stack_size: int,
	availability: int,
	ammo_type: ItemData.AmmoType,
) -> ItemData:
	var data: ItemData = ItemData.new()
	data.id = id
	data.type = type
	data.ui_name = ui_name
	data.description = description
	data.inventory_size = inventory_size
	data.buy_price = buy_price
	data.sell_price = sell_price
	data.stack_size = stack_size
	data.availability = availability
	data.ammo_type = ammo_type
	ItemValidator.validate(data)
	data._initialized = true
	return data
