# Massive Recoil — Claude Code Guidelines

## Project Type

Godot 4 game, GDScript, offline single-player only.

---

## Code Review

When reviewing code, follow the guidelines in `docs/engineering/code_review_guidelines.md`.
Every finding must cite a doc page from `docs/godot/`.

---

## Conventions

### MyAnimatedSprite — always use `set_flip()`, never `flip_h` directly

`MyAnimatedSprite` extends `AnimatedSprite2D` and emits a custom `flip_h_changed` signal.
GDScript cannot override built-in property setters, so the signal is wired through a wrapper method:

```gdscript
# CORRECT
player.body.set_flip(true)

# WRONG — silently skips the signal, breaks Arms and any other flip_h listener
player.body.flip_h = true
```

This is a strict convention. Any new code that sets `flip_h` on a `MyAnimatedSprite` instance
must go through `set_flip()`.

---

## Architecture

See `docs/decisions/` for authoritative design decisions:

- `docs/decisions/how_weapon_works.md` — weapon resource lifecycle, hydration, save/load
- `docs/decisions/runtime_structure.md` — autoloads, scene layers, GameState ownership
