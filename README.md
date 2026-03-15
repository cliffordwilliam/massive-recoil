# Massive Recoil

Massive Recoil is a 2D pixel art offline single-player game built with Godot.

Godot notes are documented in `./docs/godot/`.
This directory is a knowledge base covering Godot development patterns.

Architecture decisions are documented in `./docs/decisions/`.
It contains decisions made during development.

Reusable prompts used during development are stored in `./prompts/`.

## Project Structure

The project follows a simple separation of concern.

```
assets/     → art assets such as images and fonts
docs/       → development notes
prompts/    → reusable development prompts
src/        → game source code
```

Inside `src/` the codebase is organized into three main layers.

```
src/
  autoload/    → global singletons registered in Project Settings
  editor/      → editor utility scripts (run once, never shipped)
  entities/    → scene objects (Node) and gameplay UI
  overlays/    → UI overlays shown above the current scene (shop, save, main menu, etc.)
  resources/   → static data definitions (Resource scripts and generated .tres files)
  state/       → runtime gameplay state (RefCounted objects)
  utils.gd     → shared helper functions
```

## Formatter / Linter Setup

This approach was chosen instead of using a Godot addon to avoid cluttering the project with extra
dependencies.

Install UV globally:

```bash
uv tool install "gdtoolkit==4.*"
```

Once installed, you can use it as follows. This setup has also been added to the Git hook:

```bash
gdformat file.gd
gdlint file.gd
```

## Fonts

Monogram by datagoblin
https://datagoblin.itch.io/monogram
License: CC0 1.0 Universal (Public Domain)

## NOTES

- [ ] Figure out a way to make upgrade resource management not painful,
and making UI pages not painful too (making a new upgrade page was super painful back then)
