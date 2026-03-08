# Massive Recoil — Game Design Document

> **Audience:** Solo developer re-entering this project after time away.
> **Purpose:** Single authoritative reference for what the game is, how it works, and what is left to build.
> **Last Updated:** 2026-03-08

---

## Table of Contents

1. [Concept](#1-concept)
2. [Design Pillars](#2-design-pillars)
3. [Player Experience Goals](#3-player-experience-goals)
4. [Game Loop](#4-game-loop)
5. [Player](#5-player)
6. [Weapons](#6-weapons)
7. [Enemies](#7-enemies)
8. [Economy and Shop](#8-economy-and-shop)
9. [Level Structure](#9-level-structure)
10. [UI and Menus](#10-ui-and-menus)
11. [Save System](#11-save-system)
12. [Audio](#12-audio)
13. [Art Direction](#13-art-direction)
14. [Scope and Completion Status](#14-scope-and-completion-status)

---

## 1. Concept

**Massive Recoil** is an offline, single-player, side-scrolling pixel-art action game built in Godot 4.

The player navigates interconnected rooms, kills enemies, earns money, and upgrades weapons at a shop. Combat is grounded and deliberate — aiming matters, ammo is a resource, and upgrades meaningfully change how each weapon feels.

The game is intentionally narrow in scope. It is one gun at a time, one path forward, and a small set of weapons tuned to feel distinct from each other.

**Genre:** Side-scrolling action / shooter
**Engine:** Godot 4
**Platform:** Desktop (offline, single-player only)
**Viewport:** 320×180 pixels, integer-scaled

---

## 2. Design Pillars

### Blueprint: Resident Evil 4 (2005)

RE4 is the mechanical blueprint for this game's combat feel. The specific mechanics to reference:

| RE4 Mechanic | How It Applies Here |
|---|---|
| You cannot move and aim simultaneously | Player enters a planted stance to aim; run and aim are mutually exclusive states |
| Laser sight telegraphs shots | A visible laser beam and dot show exactly where the next bullet lands |
| Ammo is scarce but sufficient | Player can always fight, but waste is punished |
| Enemies react to hit location | (TBD) — headshots, staggers |
| Upgrade economy with a merchant | Shop NPC sells and upgrades weapons between rooms |
| Weapons feel physically distinct | Each weapon has a different fire rate, reload, and recoil — not just stat differences |
| Reloading is a deliberate commitment | Player is locked into the reload animation for its full duration |

### Pillar 1 — Deliberate Aiming

Combat is not a reflex test. You plant your feet, line up the shot, and pull the trigger. The laser sight is honest — the bullet goes exactly where the dot sits. Missing is always a skill failure, never a system failure.

### Pillar 2 — Ammo as Pressure

You never run dry if you play well, but you feel every bullet spent. Reloading has a real cost — you are stationary and vulnerable for the full reload duration. Economy between the weapon's power and its ammo efficiency is a constant background consideration.

### Pillar 3 — Upgrades That Matter

Upgrading a weapon changes how it feels to use, not just how large a number reads. Fire rate changes cadence. Magazine size changes how often you reload. Damage changes whether a second shot is needed. Each upgrade track has a visible, tangible effect.

### Pillar 4 — Tight World, No Filler

Rooms are small. Encounters are hand-placed. There is no procedural content. Every enemy placement is a choice. The map is short enough to replay in a single sitting.

---

## 3. Player Experience Goals

By the end of a session the player should feel:

- **Competent.** The controls clicked. They understand the rhythm of aim → shoot → reposition → reload.
- **Rewarded.** The upgrade they bought made the weapon noticeably better.
- **Tense at zero ammo.** Running out should feel like a crisis, not a soft inconvenience.
- **Satisfied by destruction.** Enemy death reactions and loot drops should feel punchy and satisfying.

---

## 4. Game Loop

```
Enter Room
  → Kill Enemies
	→ Collect Loot (Money, [TBD: Ammo])
	  → Reach Shop
		→ Buy / Upgrade / Sell
		  → Enter Next Room
```

**Session arc (TBD):** A full run is a short sequence of rooms ending in a boss or climax encounter. The upgrade path means the player should be meaningfully stronger at the end than the start.

---

## 5. Player

### Movement States

The player operates as a strict state machine. Only one state is active at a time.

| State | Description | Speed |
|---|---|---|
| `IDLE` | Standing still | 0 |
| `WALK` | Moving forward | 28 px/s |
| `WALK_BACK` | Moving backward | 28 px/s |
| `RUN` | Sprinting (no aim available) | 90 px/s |
| `TURN` | Pivoting direction (committed animation) | 0 |
| `AIM` | Planted aiming stance, can fire and reload | 0 |
| `RELOAD` | Reloading (committed, cannot interrupt) | 0 |

**Priority order (highest to lowest):** AIM → WALK_BACK → IDLE → TURN → RUN → WALK

### Controls

| Input | Action |
|---|---|
| A / D | Move left / right |
| W / S | Aim up / aim down (while aiming) |
| Shift | Hold to run |
| K | Hold to aim |
| J | Shoot (while aiming) |
| R | Reload |
| I | Open inventory |
| Enter | Confirm menu selection |
| Escape | Cancel / close menu |

### Aiming

- Player enters `AIM` state while holding the aim key.
- Laser sight (line + dot) shows exact hit position.
- Aim angle adjusts up/down with W/S input.
- Recoil kicks the aim angle on each shot; the player must correct.
- Recoil magnitude is set per weapon via `WeaponData.recoil_kick`.

### Arms Visual

- A separate `Arms` sprite overlays the body and shows the current weapon.
- Arms stay locked to the body's animation frame and flip direction.
- On fire, arms kick back 2.5 px and smoothly return.
- A white rim-light flashes on the arm sprite on each shot.
- Arms swap sprite frames when the player equips a different weapon.

### Shooting (Raycast)

- Shooting uses a `RayCast2D` to detect hits.
- The ray collides with: solid geometry (layer 3) and enemies (layer 4, Area2D).
- On hit: spawns bullet trail, muzzle flash, bullet impact effect.
- On enemy hit: calls `enemy.ouch(damage)`.
- One-tick stale collision is accepted as a trade-off for clean input handling.

---

## 6. Weapons

### Current Weapons

| Weapon | Auto | Notes |
|---|---|---|
| Handgun | No | Starting weapon. Low damage, fast reload. |
| Rifle | No | Higher damage, slower fire rate. |

### Weapon Data (Per Weapon)

Each weapon is defined by a `.tres` resource (`WeaponData`) with:

**Static (configured in editor):**
- `id` — Unique string identifier
- `price` — Cost to purchase
- `magazine_size`, `reload_speed`, `damage`, `fire_rate` — Each is an `UpgradeListData` track
- `is_automatic` — Whether holding shoot fires continuously
- `recoil_kick` — Aim angle displacement per shot
- `arms_sprite`, `icon_sprite`, `description_sprite` — Art references

**Dynamic (mutated at runtime):**
- `magazine_current` — Rounds remaining in magazine
- `reserve_ammo` — Total reserve ammo
- `is_owned` — Player owns this weapon
- `was_bought` — Ever purchased (drives "new" tag in shop)

### Upgrade System

Each upgradeable stat has an `UpgradeListData` track, which is a list of `UpgradeItemData` entries. Each entry has:

- `value: float` — The stat value at this level
- `cost: int` — Cost to unlock this level

The track stores an `index` (current upgrade level). Upgrading increments the index and deducts cost from GameState money.

**Upgrade tracks per weapon:**
- Damage
- Fire Rate
- Reload Speed
- Magazine Size

**Upgrade resource path structure:**
```
src/resources/weapons/{weapon_name}/upgrades/{stat_type}/
```

### Weapon Lifecycle

See [docs/decisions/how_weapon_works.md](docs/decisions/how_weapon_works.md) for full detail.

Summary:
1. On game launch, `GameState` creates one instance per weapon from `.tres` templates.
2. On save slot load, instances are hydrated from plain-text save data.
3. During play, all mutations go through `GameState` API.
4. On save, only mutable data is written to disk. `.tres` files are never modified.

### Weapons Planned (TBD)

- Shotgun
- Submachine gun
- Any additional weapons to fill out the upgrade economy

---

## 7. Enemies

### BaseEnemy

All enemies extend `BaseEnemy` (Area2D). They are monitorable only, on the enemy physics layer (layer 4).

Required by base class:
- A `HealthCounter` component referencing an `EnemyData` resource
- A "dead" animation in their AnimatedSprite

On death:
- Play "dead" animation
- Subclass `on_died()` handles loot drops

### Current Enemies

| Enemy | Health | Loot | Notes |
|---|---|---|---|
| Wooden Crate | (from EnemyData) | Money | Destructible box. No movement or aggression. |

### Planned Enemies (TBD)

- Basic humanoid enemy with patrol or idle behavior
- Enemy with projectile attack
- Boss enemy
- Enemy with staggers / headshot zones (RE4 pillar)

### Damage and Death

- `ouch(damage)` reduces health via `HealthCounter`.
- `HealthCounter` emits `died` when health hits 0.
- After death, all further damage is ignored.
- No healing exists in the current system.

---

## 8. Economy and Shop

### Money

- Money is the only currency.
- Earned by destroying enemies (each unit drops one money loot item).
- Collected automatically on body overlap.
- Stored in `GameState` as an integer.
- Dev value currently set to 99,999,999 for testing.

### Loot

Loot items are physics-based nodes that pop outward on spawn, then stop. Collection is automatic (one-shot on player overlap).

| Loot Type | Effect |
|---|---|
| Money | `GameState.add_one_to_money()` |
| Weapon | `GameState.pick_up_a_weapon_by_id(id)` |

**TBD: Ammo drops.** Ammo pickups exist in the design but are not implemented.

### Shop NPC

The shop is a static area in the room. A pulsing overlay indicates the interaction zone. When the player overlaps and presses Accept, the `ShopPage` opens.

### Shop Page (Hub Menu)

Four options:

| Option | Status |
|---|---|
| Buy | Implemented — opens `BuyPage` |
| Sell | TBD |
| Upgrade | TBD |
| Cancel | Implemented — closes shop |

**TBD: "New" tags** on Buy and Upgrade buttons to indicate unreviewed items.

### Buy Page

- Shows all weapons in a scrollable list.
- Selected weapon shows icon, description, and all four upgrade tracks visualized.
- "New" tag shown if weapon was never purchased.
- "Sold out" shown if weapon already owned.
- Cannot repurchase owned weapons.
- Deducts price from GameState money on purchase.

### Sell Page (TBD)

- Sell back owned weapons for partial refund.
- Design not finalized.

### Upgrade Page (TBD)

- Upgrade individual weapon stat tracks.
- Interface exists at resource level (UpgradeListData/UpgradeItemData) but frontend not built.
- The UpgradeTrackDisplay widget exists and renders upgrade state — needs to be wired into an interactive upgrade flow.

### Reveal System (TBD)

- Mechanism to hide weapons and upgrades from the shop until certain in-game events occur.
- Planned as a flag on WeaponData or a separate reveal registry.

---

## 9. Level Structure

### Current Structure

- **BaseRoom** — Template gameplay scene. Contains player, enemies, shop, doors, effects container.
- **village_entrance.tscn** — The first (and currently only) playable room.

### Room Transition (TBD)

- Doors exist in the design (`Doors` node in `BaseRoom`) but room transitions are not implemented.
- The intended flow is: player walks through a door → current BaseRoom is replaced by the next.
- `GameState` persists across transitions; only the scene swaps.

See [docs/decisions/runtime_structure.md](docs/decisions/runtime_structure.md) for scene architecture.

### Room Design Philosophy

- Rooms are small and hand-authored. No procedural generation.
- Each room has a clear layout: enemies to clear, a path to the next door, possibly a shop.
- Enemy placement is deliberate — each group is a designed encounter.

### Full Level Map (TBD)

- Number of rooms: not finalized
- Boss room: not designed
- World theme: village (established by village_entrance)

---

## 10. UI and Menus

### Page System

All UI is managed by the `PageRouter` autoload. Pages are modal overlays that pause the game when active.

| Page | Status | Description |
|---|---|---|
| ShopPage | Implemented | Hub menu for shop interactions |
| BuyPage | Implemented | Weapon purchase list |
| InventoryPage | Implemented | Owned weapons; equip different weapon |
| SellPage | TBD | Sell back owned weapons |
| UpgradePage | TBD | Upgrade weapon stat tracks |
| PausePage | TBD | Pause menu with resume/options/quit |
| OptionsPage | TBD | Settings (audio, display, controls) |

### Inventory Page

- Shows all owned weapons in a scrollable list.
- Each list item shows: weapon name, current magazine ammo, "equipped" tag if active.
- Selecting a weapon equips it (calls `GameState.equip_a_new_weapon_by_id()`).
- Money displayed at top.
- Ammo display hardcoded for handgun and rifle — will need to be generalized as more weapons are added.

### HUD (TBD)

No in-room HUD is currently implemented. Planned elements:
- Current weapon name or icon
- Magazine current / reserve ammo
- Money counter

### Title Screen / Main Menu (TBD)

Not implemented. Game launches directly into the room for development purposes.

### Save Slot Selection Screen (TBD)

Not implemented. Required before shipping — game supports multiple save slots by design.

---

## 11. Save System

### Design (Partially Implemented)

The save system architecture is fully designed but not yet wired to UI or triggered by gameplay.

**Data saved per slot:**
- Money count
- For each weapon: `magazine_current`, `reserve_ammo`, `is_owned`, `was_bought`, upgrade indices

**Format:** Plain text (not `.tres` files — they are never mutated).

**Multiple save slots:** Supported. Each slot has its own file. Weapon templates remain shared and unchanged.

**Hydration:** On slot load, `GameState` weapon instances are updated from save data.

See [docs/decisions/how_weapon_works.md](docs/decisions/how_weapon_works.md) for the full lifecycle.

### Save Points (TBD)

- Mechanism for triggering a save during gameplay (e.g. interacting with a typewriter, reaching a checkpoint).
- Not implemented.

### Auto-Save (TBD)

- Not designed. Manual save at save points is the intended flow (RE4 precedent).

---

## 12. Audio

**All audio is TBD.** No audio system, sound effects, or music are implemented.

Planned:
- Gunshot SFX (distinct per weapon)
- Reload SFX
- Enemy hit / death SFX
- Money pickup SFX
- Shop UI SFX
- Background music per room or zone

---

## 13. Art Direction

### Style

- Pixel art, side-scrolling perspective
- 320×180 viewport, integer-scaled to display resolution
- Assets imported via Aseprite plugin

### Font

- See repo notes (mentioned in `ac0d601` commit: "docs: mention font used")

### Visual Effects

| Effect | Status |
|---|---|
| Bullet trail (line from muzzle to hit) | Implemented |
| Bullet casing (physics eject) | Implemented |
| Muzzle flash (auto-free animation) | Implemented |
| Bullet impact on enemy | Implemented |
| Bullet impact on solid | Implemented |
| Muzzle light flash | Implemented |
| Arms recoil animation | Implemented |
| Arms white rim flash | Implemented |
| Enemy hit flash (white) | Implemented |
| Enemy death animation | Implemented |

### Physics / Feel

- 2D snap enabled (pixel-perfect movement)
- Jolt Physics (3D engine, configured in project — carries no gameplay effect here)
- GL Compatibility renderer (performance target: low-end hardware)

---

## 14. Scope and Completion Status

### Implemented

- [x] Player movement state machine (walk, run, idle, turn, aim, reload)
- [x] Laser sight (ray + dot visualization)
- [x] Shooting (raycast, ammo consumption, fire rate timer)
- [x] Recoil on aim angle
- [x] Weapon resource system (WeaponData, UpgradeListData, UpgradeItemData)
- [x] Two weapons: handgun, rifle
- [x] Upgrade tracks (data layer only — no shop UI yet)
- [x] Enemy base class with health and death
- [x] Wooden crate enemy
- [x] Money loot drops
- [x] Physics-based loot collection
- [x] Shop NPC interaction area
- [x] ShopPage (hub menu)
- [x] BuyPage (weapon purchase)
- [x] InventoryPage (weapon equipping)
- [x] ScrollList UI component
- [x] NumberDisplay (sprite-based digits)
- [x] UpgradeTrackDisplay widget
- [x] Visual effects (trails, casings, flash, impacts)
- [x] PageRouter (modal UI manager with game pause)
- [x] GameState autoload (single source of truth)
- [x] Spawner autoload (effects/loot factory)
- [x] MyAnimatedSprite (custom flip signal)
- [x] State machine framework (generic, reusable)
- [x] Utils (require, kill_tween)

### In Progress / Partially Done

- [ ] Save system — architecture designed, UI/trigger not wired
- [ ] Upgrade shop flow — data layer ready, no interactive frontend

### Not Started (TBD)

- [ ] Ammo drops
- [ ] Sell page
- [ ] Upgrade page
- [ ] HUD (ammo, weapon, money display during gameplay)
- [ ] Room transitions (door mechanics)
- [ ] More than one room
- [ ] Boss encounter
- [ ] More enemy types (humanoid, ranged, boss)
- [ ] Hit reactions / staggers (RE4 pillar)
- [ ] Headshot zones (RE4 pillar)
- [ ] Shop reveal system (hide items until events unlock them)
- [ ] Save points
- [ ] Save slot selection screen
- [ ] Title screen / main menu
- [ ] Pause menu
- [ ] Options page (audio, display, controls)
- [ ] Audio (all of it)
- [ ] Additional weapons (shotgun, SMG, etc.)
- [ ] Full level design / room map
- [ ] New / Upgrade notification tags in shop hub

---

## Appendix A — Key Files Quick Reference

| What | Where |
|---|---|
| GameState (all persistent data) | `src/autoloads/game_state.gd` |
| PageRouter (UI overlay manager) | `src/autoloads/ui/page_router/page_router.gd` |
| Spawner (effects/loot factory) | `src/autoloads/spawner.gd` |
| Player | `src/entities/actors/player/player.gd` |
| Player states | `src/entities/actors/player/states/` |
| Arms (weapon overlay) | `src/entities/actors/player/arms.gd` |
| Shooting raycast | `src/entities/actors/player/ray.gd` |
| BaseEnemy | `src/entities/actors/enemies/base_enemy.gd` |
| WeaponData resource | `src/resources/weapons/weapon_data.gd` |
| Handgun .tres | `src/resources/weapons/handgun/` |
| Rifle .tres | `src/resources/weapons/rifle/` |
| Shop NPC | `src/entities/actors/shop/shop.gd` |
| Loot item | `src/entities/actors/loot/loot.gd` |
| MyAnimatedSprite | `src/entities/custom_nodes/my_animated_sprite/my_animated_sprite.gd` |
| StateMachine | `src/entities/custom_nodes/state/state_machine.gd` |
| First playable room | `src/rooms/village/village_entrance.tscn` |
| Utility functions | `src/utils/utils.gd` |

## Appendix B — Architecture Decisions

Full decision records live in `docs/decisions/`:

- [How weapons work](docs/decisions/how_weapon_works.md) — resource lifecycle, hydration, save/load
- [Runtime structure](docs/decisions/runtime_structure.md) — autoloads, scene layers, GameState ownership

## Appendix C — Critical Conventions

**MyAnimatedSprite: always use `set_flip()`, never `flip_h` directly.**

```gdscript
# CORRECT
player.body.set_flip(true)

# WRONG — silently skips the signal, breaks Arms
player.body.flip_h = true
```

GDScript cannot override built-in property setters. The signal is wired through a wrapper method. This is a strict convention — all new code must follow it.

**All GameState mutations go through the API, never direct property writes from scenes.**

**All weapon instances are owned by GameState. Never duplicate a weapon resource.**
