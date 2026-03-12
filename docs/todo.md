# TODO
- [ ] Figure out a way to make upgrade resource management not painful,
and making UI pages not painful too (making a new upgrade page was super painful back then)
- [ ] ...

## Dummy Test Data

**Simple Treasure (Static Price)**

```json
{
  "id": "blue_gem",
  "name": "Blue Gem",
  "category": "treasure",
  "subcategory": "common",
  "location": "",
  "sell": [
	{ "price": 1500, "condition": null }
  ],
  "attachments": null,
  "note": null,
  "part_of": null
}
```

**Complex Treasure (Variable Prices & Attachments)**

```json
{
  "id": "mystic_mask",
  "name": "Mystic Mask",
  "category": "treasure",
  "subcategory": "village",
  "location": "Secret chamber near fountain",
  "sell": [
	{ "price": 2000, "condition": "(0 stones)" },
	{ "price": 8000, "condition": "(1 stone)" },
	{ "price": 12000, "condition": "(2 stones)" },
	{ "price": 18000, "condition": "(3 stones)" }
  ],
  "attachments": ["Magic Stones"],
  "note": null,
  "part_of": null
}
```

**Key (Combinable)**

```json
{
  "id": "emerald_key_half",
  "name": "Emerald Key (Left Half)",
  "category": "keys",
  "subcategory": "village",
  "location": "Hidden under tower stairs",
  "sell": null,
  "attachments": null,
  "note": null,
  "part_of": "Emerald Key"
}
```

---

### 2️⃣ Consumables, Ammo, & Attache Cases

**Healing Item (Grid Size & Description)**

```json
{
  "id": "herb_mix_red_blue",
  "name": "Herb Mix (R+B)",
  "category": "healing",
  "subcategory": "herb_mixed",
  "size": { "width": 2, "height": 1 },
  "sell_price": 7000,
  "sell_price_per_unit": null,
  "buy_price": null,
  "box_size": null,
  "ammo_for": null,
  "availability": null,
  "cost": null,
  "description": "Combines a Red herb and a Blue herb to restore moderate health."
}
```

**Ammunition (Unit Pricing & Weapon Linking)**

```json
{
  "id": "crossbow_bolts",
  "name": "Crossbow Bolts",
  "category": "ammo",
  "subcategory": null,
  "size": null,
  "sell_price": null,
  "sell_price_per_unit": 50,
  "buy_price": null,
  "box_size": 20,
  "ammo_for": ["Crossbow", "Heavy Crossbow"],
  "availability": null,
  "cost": null,
  "description": null
}
```

**Attache Case Upgrade (System Upgrade)**

```json
{
  "id": "attache_upgrade_l",
  "name": "Attache Upgrade L",
  "category": "attache_case",
  "subcategory": null,
  "size": { "width": 6, "height": 10 },
  "sell_price": null,
  "sell_price_per_unit": null,
  "buy_price": null,
  "box_size": null,
  "ammo_for": null,
  "availability": "chapter_2_1",
  "cost": 25000,
  "description": null
}
```

---

### 3️⃣ Weapons

**Upgradable Weapon**

```json
{
  "id": "blaster",
  "name": "Blaster",
  "upgrades": [
	{
	  "level": 1,
	  "firepower": { "value": 3.5, "cost": 0 },
	  "firing_speed": { "value": 1.5, "cost": 0 },
	  "reload_speed": { "value": 3.0, "cost": 0 },
	  "capacity": { "value": 6, "cost": 0 }
	},
	{
	  "level": 2,
	  "firepower": { "value": 4.0, "cost": 12000 },
	  "firing_speed": null,
	  "reload_speed": { "value": 2.5, "cost": 6000 },
	  "capacity": { "value": 8, "cost": 7000 }
	},
	{
	  "level": 5,
	  "firepower": { "value": 7.0, "cost": 40000 },
	  "firing_speed": null,
	  "reload_speed": null,
	  "capacity": { "value": 15, "cost": 18000 }
	}
  ]
}
```

**Static / Non-Upgradable Weapon**

```json
{
  "id": "mega_cannon",
  "name": "Mega Cannon",
  "upgrades": []
}
```

---

✅ These dummy items **preserve all the edge cases** you need:

* Static vs variable sell prices
* Combinable parts (`part_of`)
* Nullable fields (`attachments`, `description`, `upgrades`)
* Grid sizes, ammo box sizes, unit pricing
* Upgrade trees with partially null values
