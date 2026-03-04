# How Weapons Work

> **Scope:** This game is offline and single-player only.
> The system is intentionally designed around a single runtime session.

---

## Core Principle

Weapons are **unique runtime entities**.

During a single gameplay session:

* Each weapon exists exactly once.
* There are no duplicate instances of the same weapon.
* If the game contains 3 weapons, then the runtime contains exactly 3 weapon resource instances.

Think of each weapon like a person in the world.
You cannot have two identical copies of the same individual standing side by side.
There is only one instance per session.

---

## Ownership and Lifetime

All weapon instances are owned by the `GameState` autoload.

Why?

* `GameState` lives for the entire lifetime of the application.
* Resources in Godot are reference-counted — if nothing references them, they are freed.
* By storing weapons inside `GameState`, their lifetime is tied to the game session.

This makes `GameState` the single source of truth for all weapon state.

---

## Runtime Lifecycle

### 1. Game Launch

When the player opens the game:

* `GameState` creates all weapon resource instances.
* Example:

  * Handgun instance
  * Rifle instance
  * Shotgun instance

At this point, they contain default values defined by their base `.tres` files.

---

### 2. Save Slot Selection (Hydration Phase)

When the player selects a save slot:

* The save file (plain text data) is loaded.
* Each weapon instance is hydrated using the saved state.

Example:

* Handgun → 3 ammo
* Rifle → 1 ammo
* Shotgun → 0 ammo

The resource instances already exist — we simply update their properties.

---

### 3. Gameplay Mutation

During gameplay:

* Weapon state changes (ammo consumption, upgrades, etc.).
* All mutations happen through the `GameState` API.
* The resource instances inside `GameState` are updated directly.

Example during play:

* Handgun → 99 ammo
* Rifle → 0 ammo

---

### 4. Saving the Game

When the player saves:

* We take a snapshot of each weapon’s current state.
* We serialize only the mutable data (e.g., ammo).
* This data is written to the selected save slot file.

Important:

We do **not** overwrite the `.tres` files.
We only store plain text state data.

---

### 5. Closing and Reopening

When the game closes:

* All runtime instances are destroyed.

When the game launches again:

* `GameState` recreates fresh weapon instances.
* The selected save slot hydrates them again.
* State is restored.

The cycle repeats.

---

# Understanding Resources (Mental Model)

Think of a Resource like an image template.

### Example: Image Analogy

1. Create a base tree image.
2. Create instances:

   * Red
   * Green
   * Blue
3. Assign Red to two nodes:

   * Node A → Red
   * Node B → Red
4. Change Red to Blue during gameplay:

   * Node A → Blue
   * Node B → Blue
5. Close and reopen the game:

   * Node A → Red
   * Node B → Red

Runtime changes do not persist unless explicitly written to disk.

---

## Persistence Rule

If you want mutations to persist, you must write data to disk.

There are two theoretical options:

1. Modify and save the resource file itself (`.tres`)
2. Save plain text state separately

In this project, we use **plain text save files**.

Why?

Because the game supports multiple save slots.

If we modified the `.tres` directly:

* All save slots would share the same modified data.
* Slot separation would break.

By saving plain text data per slot:

* Each slot stores its own weapon state.
* Weapon templates remain unchanged.
* Runtime instances are hydrated per slot.

---

# Concrete Weapon Example

## Setup

1. Create base weapon resources:

   * `Handgun.tres`
   * `Rifle.tres`

2. Assign them to `GameState`:

   * `GameState.handgun`
   * `GameState.rifle`

---

## Slot A Hydration

After loading Slot A:

* Handgun → 10 ammo
* Rifle → 0 ammo

---

## Gameplay Mutation

During play:

* Handgun → 99 ammo
* Rifle → 0 ammo

---

## Saving Slot A

Slot A file stores:

* Handgun → 99 ammo
* Rifle → 0 ammo

Slot B remains untouched.

---

## Reloading Slot A

On next launch:

* Weapon instances are recreated.
* Slot A data hydrates them.
* Handgun correctly restores to 99 ammo.

---

# Architectural Summary

* `.tres` files define default configuration.
* `GameState` owns runtime instances.
* Save files store mutable state.
* Hydration restores runtime state.
* No resource files are modified during gameplay.

This ensures:

* Clean separation between template and state
* Proper save slot isolation
* Predictable runtime behavior
* Single source of truth for weapon data
