class_name ItemDefinitions
extends RefCounted
## Static item catalog. [method make_all] constructs and returns all [ItemData] instances.
##
## Add, remove, or edit entries in [method make_all].
## Field constraints are documented in [ItemData] and [ItemSchema].
##
## See: "res://docs/decisions/item_architecture.md"


## Constructs and returns all item definitions. Add, remove, or edit items here.
static func make_all() -> Array[ItemData]:
	return [
		(
			ItemData
			. new(
				#
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
				# slot texture
				"res://assets/images/static/ui/ui_field_medkit_slot.png",
			)
		),
		(
			ItemData
			. new(
				#
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
				Vector2i(1, 2),
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
				# slot texture
				"res://assets/images/static/ui/ui_sterile_band_slot.png",
			)
		),
		(
			ItemData
			. new(
				#
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
				Vector2i(1, 2),
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
				# slot texture
				"res://assets/images/static/ui/ui_antiseptic_slot.png",
			)
		),
		(
			ItemData
			. new(
				#
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
				Vector2i(1, 2),
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
				# slot texture
				"res://assets/images/static/ui/ui_treat_band_slot.png",
			)
		),
		(
			ItemData
			. new(
				#
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
				# slot texture
				"res://assets/images/static/ui/ui_handgun_ammo_slot.png",
			)
		),
		(
			ItemData
			. new(
				#
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
				99,
				#
				# availability
				ItemSchema.AVAILABILITY_NOT_FOR_SALE,
				#
				# slot texture
				"res://assets/images/static/ui/ui_smg_ammo_slot.png",
			)
		),
		(
			ItemData
			. new(
				#
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
				# slot texture
				"res://assets/images/static/ui/ui_pack_upgrade_slot.png",
			)
		),
		(
			ItemData
			. new(
				#
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
				# slot texture
				"res://assets/images/static/ui/ui_damage_upgrade_slot.png",
				#
				# weapon data
				null,
				#
				# upgrade stat
				ItemData.UpgradeStat.POWER,
			)
		),
		(
			ItemData
			. new(
				#
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
				Vector2i(3, 2),
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
				# slot texture
				"res://assets/images/static/ui/ui_handgun_slot.png",
				#
				# weapon data
				(
					WeaponData
					. new(
						#
						# ammo type
						WeaponData.AmmoType.HANDGUN_AMMO,
						#
						# power: min, max, upgrade step
						20,
						60,
						10,
						#
						# rate of fire: min, max, upgrade step
						30,
						60,
						10,
						#
						# reload speed: min, max, upgrade step
						50,
						80,
						10,
						#
						# ammo capacity: min, max, upgrade step
						10,
						20,
						2,
					)
				),
			)
		),
		(
			ItemData
			. new(
				#
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
				Vector2i(6, 3),
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
				# slot texture
				"res://assets/images/static/ui/ui_smg_slot.png",
				#
				# weapon data
				(
					WeaponData
					. new(
						#
						# ammo type
						WeaponData.AmmoType.SMG_AMMO,
						#
						# power: min, max, upgrade step
						10,
						40,
						5,
						#
						# rate of fire: min, max, upgrade step
						70,
						100,
						5,
						#
						# reload speed: min, max, upgrade step
						40,
						70,
						10,
						#
						# ammo capacity: min, max, upgrade step
						20,
						60,
						5,
					)
				),
			)
		),
		(
			ItemData
			. new(
				#
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
				# slot texture
				"res://assets/images/static/ui/ui_ornate_pendant_slot.png",
			)
		),
		(
			ItemData
			. new(
				#
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
				# slot texture
				"res://assets/images/static/ui/ui_ruby_gem_slot.png",
			)
		),
		(
			ItemData
			. new(
				#
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
				# slot texture
				"res://assets/images/static/ui/ui_jeweled_pendant_slot.png",
			)
		),
		(
			ItemData
			. new(
				#
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
				# slot texture
				"res://assets/images/static/ui/ui_maintenance_key_slot.png",
			)
		),
		(
			ItemData
			. new(
				#
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
				# slot texture
				"res://assets/images/static/ui/ui_sun_key_fragment_slot.png",
			)
		),
		(
			ItemData
			. new(
				#
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
				# slot texture
				"res://assets/images/static/ui/ui_moon_key_fragment_slot.png",
			)
		),
		(
			ItemData
			. new(
				#
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
				# slot texture
				"res://assets/images/static/ui/ui_sun_moon_key_slot.png",
			)
		),
	]
