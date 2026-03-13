# Massive Recoil

Massive Recoil is a 2D pixel art offline single-player game built with Godot.

Engine-related notes are documented in `./docs/godot/`.
This directory acts as an iterative, ever-growing knowledge base covering topics such as tiles,
resources, workflows, and other Godot development patterns.

Design and architecture decisions are documented in `./docs/decisions/`.
This folder contains formal decisions made during development, such as UI policies,
rendering approaches, and other project-wide conventions. It helps maintain consistency
and provides context for why certain patterns are followed.

Reusable prompts used during development are stored in `./prompts/`.

The documentation evolves alongside the project. If something breaks or a better approach is
discovered, the knowledge base is updated accordingly.

## Project Structure

The project follows a simple separation between **assets**, **data definitions**,
**runtime state**, and **scene entities**.
This helps keep gameplay logic, data, and rendering concerns isolated.

```
assets/     → art assets such as images and fonts
docs/       → development notes and architectural decisions
prompts/    → reusable prompts used during development
src/        → game source code
```

Inside `src/` the codebase is organized into three main layers:

```
src/
  autoload/    → global singletons registered in Project Settings
  editor/      → editor utility scripts (run once, never shipped)
  entities/    → scene objects (Node / Node2D) and gameplay UI (Node Objects)
  overlays/    → UI overlays shown above the current scene (shop, save, etc.)
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
