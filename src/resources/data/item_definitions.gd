class_name ItemDefinitions
extends RefCounted
## Static item catalog. [method get_all] constructs and returns all [ItemData] instances.
##
## Add, remove, or edit entries via [method _make] calls in [method get_all].
## Field constraints are documented in [ItemData] and [ItemSchema].


static func get_all() -> Array[ItemData]:
	return [
		_make(
			&"field_medkit",
			ItemData.Type.MED,
			"Field Kit",
			"Restores full health. Rare emergency medkit.",
			Vector2i(2, 1),
			5000,
			2500,
			1,
			1
		),
		_make(
			&"sterile_band",
			ItemData.Type.COMBINABLE_MED,
			"Sterile Band",
			"Clean bandage. Restores a small amount of health.",
			Vector2i(2, 1),
			0,
			300,
			5
		),
		_make(
			&"antiseptic",
			ItemData.Type.COMBINABLE_MED,
			"Antiseptic",
			"Antiseptic vial used to disinfect wounds.",
			Vector2i(1, 1),
			0,
			400,
			5
		),
		_make(
			&"treat_band",
			ItemData.Type.MED,
			"Treat Band",
			"Bandage treated with antiseptic. Restores health.",
			Vector2i(2, 1),
			1800,
			900,
			1,
			1
		),
		_make(
			&"handgun_ammo",
			ItemData.Type.AMMO,
			"HG Ammo",
			"Standard handgun cartridges.",
			Vector2i(2, 1),
			0,
			50,
			50
		),
		_make(
			&"smg_ammo",
			ItemData.Type.AMMO,
			"SMG Ammo",
			"Ammo for high-rate SMG weapons.",
			Vector2i(2, 1),
			0,
			20,
			100
		),
		_make(
			&"pack_upgrade",
			ItemData.Type.INVENTORY_UPGRADE,
			"Pack Upgrade",
			"Permanently increases inventory capacity.",
			Vector2i(2, 1),
			30000,
			0,
			1,
			1
		),
		_make(
			&"damage_upgrade",
			ItemData.Type.WEAPON_UPGRADE,
			"DMG Upgrade",
			"Upgrade that increases weapon damage.",
			Vector2i(1, 1),
			5000,
			0,
			1,
			1
		),
		_make(
			&"handgun",
			ItemData.Type.WEAPON,
			"Handgun",
			"Reliable semi-auto handgun.",
			Vector2i(2, 2),
			8000,
			4000,
			1,
			1,
			ItemData.AmmoType.HANDGUN_AMMO
		),
		_make(
			&"smg",
			ItemData.Type.WEAPON,
			"SMG",
			"Compact SMG with very high fire rate.",
			Vector2i(3, 2),
			16000,
			8000,
			1,
			1,
			ItemData.AmmoType.SMG_AMMO
		),
		_make(
			&"ornate_pendant",
			ItemData.Type.TREASURE,
			"Ornate Pndnt",
			"Pendant with an empty gem socket.",
			Vector2i(1, 1),
			0,
			4000,
			1
		),
		_make(
			&"ruby_gem",
			ItemData.Type.TREASURE,
			"Ruby Gem",
			"A polished red gemstone.",
			Vector2i(1, 1),
			0,
			2500,
			1
		),
		_make(
			&"jeweled_pendant",
			ItemData.Type.TREASURE,
			"Jeweled Pndt",
			"Pendant fitted with a brilliant ruby.",
			Vector2i(1, 1),
			0,
			9000,
			1
		),
		_make(
			&"maintenance_key",
			ItemData.Type.KEY,
			"Maint. Key",
			"Maintenance key for service doors.",
			Vector2i(1, 1),
			0,
			0,
			1
		),
		_make(
			&"sun_key_fragment",
			ItemData.Type.KEY,
			"Sun Fragment",
			"A fragment of a broken key.",
			Vector2i(1, 1),
			0,
			0,
			1
		),
		_make(
			&"moon_key_fragment",
			ItemData.Type.KEY,
			"Moon Shard",
			"A curved fragment of a key.",
			Vector2i(1, 1),
			0,
			0,
			1
		),
		_make(
			&"sun_moon_key",
			ItemData.Type.KEY,
			"Sun/Moon Key",
			"Two fragments forming a complete key.",
			Vector2i(1, 1),
			0,
			0,
			1
		),
	]


## Constructs and validates a single [ItemData] entry.
## Crashes via [method Utils.require] on the first constraint violation.
## [param availability] is only meaningful when [param buy_price] is non-zero.
static func _make(
	id: StringName,
	type: ItemData.Type,
	ui_name: String,
	description: String,
	inventory_size: Vector2i,
	buy_price: int,
	sell_price: int,
	stack_size: int,
	availability: int = ItemSchema.AVAILABILITY_NOT_FOR_SALE,
	ammo_type: ItemData.AmmoType = ItemData.AmmoType.NONE,
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
	data.availability = ItemSchema.AVAILABILITY_NOT_FOR_SALE if buy_price == 0 else availability
	data.ammo_type = ammo_type
	ItemValidator.validate(data)
	return data
