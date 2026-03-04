# Runtime Structure

> This structure defines how the game is organized at runtime.
> It is expected to evolve as the project grows.

The system is designed specifically for an offline, single-player game.

The architecture is divided into two main layers:

1. **Global Layer (Autoload Singletons)**
2. **Current Scene Layer**

At any given time, exactly one main scene is active, while autoloads persist for the entire application lifetime.

---

# 1. Global Layer (Autoload Singletons)

Autoloads exist for the full duration of the application.
They are never replaced during scene transitions.

---

## PageRouter

**Purpose:**
Handles global UI navigation and overlays.

**Responsibilities:**

* Managing pause page
* Managing options page
* Managing other modal or overlay UI
* Displaying overlays on top of both gameplay and menu scenes

Important:

The Options page can overlay:

* `BaseRoom` (during gameplay)
* `Screen` (during menus)

**Does NOT:**

* Store gameplay state
* Handle combat or simulation logic

---

## GameState

**Purpose:**
Acts as the single source of truth for all persistent game data during a session.

**Responsibilities:**

* Player money
* Weapon instances (handgun, rifle, etc.)
* Ammo counts
* Owned weapons
* Other persistent gameplay state

**Key Principle:**
All mutable gameplay data lives here.

Scenes may read from `GameState`, but they do not own persistent data.

---

# 2. Current Scene Layer

At any moment, the active scene is one of two types:

* A gameplay scene (`BaseRoom`)
* A non-gameplay scene (`Screen`)

Scenes are replaceable.
Autoloads are permanent.

---

# A. BaseRoom (Gameplay Context)

Used during active gameplay.

**Contains:**

* Player
* Enemies
* Shop
* Doors (used to change scenes)
* Room-specific gameplay objects

**Responsibilities:**

* Gameplay simulation
* Combat logic
* Player interaction
* Emitting signals to request scene transitions

**Does NOT:**

* Store persistent player data
* Manage global UI routing
* Handle save/load logic

All persistent data must go through `GameState`.

---

# B. Screen (Non-Gameplay Context)

Used for menus and non-interactive states.

**Examples:**

* Title Screen
* Load Screen
* Main Menu

**Responsibilities:**

* Menu navigation
* Save slot selection
* Starting or loading sessions

**Does NOT:**

* Contain gameplay simulation
* Modify persistent state directly

---

# Architectural Principles

1. **Single Source of Truth**
   All persistent runtime data lives in `GameState`.

2. **Clear Separation of Concerns**

   * `GameState` → data
   * `PageRouter` → UI overlays
   * `BaseRoom` → gameplay
   * `Screen` → menus

3. **Replaceable Scenes**
   Rooms and screens can be swapped freely.
   Autoloads persist across the entire application lifetime.

4. **No State Ownership in Scenes**
   Scenes may consume state but do not own it.

---

# Summary

This structure ensures:

* Clean separation between gameplay, UI, and data
* Predictable scene transitions
* Centralized state management
* Scalable architecture for future expansion
