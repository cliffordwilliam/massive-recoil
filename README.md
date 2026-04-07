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
  autoload/      → global singletons registered in Project Settings
  custom_nodes/  → reusable Node subclasses (state machine infrastructure, etc.)
  editor/        → editor utility scripts (run once, never shipped)
  entities/      → scene objects (Node) and gameplay UI
  overlays/      → UI overlays shown above the current scene (shop, save, main menu, etc.)
  resources/     → static data definitions and validation (item data classes and definitions)
  state/         → runtime gameplay state (RefCounted objects)
  utils.gd       → shared helper functions
```

## ASE Watcher (Auto SpriteFrames Importer)

Requires the [Aseprite CLI](https://www.aseprite.org/) and [Go](https://go.dev/) (via [mise](https://mise.jdx.dev/) or any other method).

Build the watcher binary once:

```bash
cd addons/ase_watcher/ase_watch
go build -o ase_watch .
```

Cross-compile for macOS if needed:

```bash
GOOS=darwin GOARCH=arm64 go build -o ase_watch_mac .
```

The plugin lives in `res://addons/ase_watcher/` and auto-generates a `SpriteFrames` resource (`.tres`) per layer whenever an `.ase` file is saved. No manual steps needed — it behaves like nodemon.

**How it works:**

The Go watcher (`ase_watch/`) and the Godot plugin communicate over a local TCP socket (port 9876):

1. `fsnotify` detects a `.ase` save (works on Linux and macOS natively — no `inotify-tools` needed)
2. The watcher runs Aseprite CLI for each layer in parallel, writing PNG + JSON to `assets/images/dynamic/`
3. It parses the JSON and writes each `.tres` directly as a text file referencing the PNG
4. It signals Godot via the socket to scan the filesystem and hot-reload the resources
5. Godot imports the new PNGs then reloads the `SpriteFrames` — open scenes update live

Output per layer:
```
assets/images/dynamic/<name>_<layer>.png
assets/images/dynamic/<name>_<layer>.tres
```

The intermediate JSON Aseprite produces is deleted after each build — it is a transient artifact, not a project file. If a save produces no changes (identical `.ase` content), the `.tres` is not rewritten and Godot is not signalled.

Loop behavior is driven by the **Repeat** field on each Aseprite frame tag:
- Infinite (or not set) → animation loops
- 1 → plays once, no loop

**Layers = SpriteFrames resources:**

Each layer in an `.ase` file becomes its own `SpriteFrames` resource. This is intentional — layers here serve a functional runtime purpose, not just a visual one. For example, a `player.ase` with three layers:

```
player.ase
  ├── body      →  player_body.tres
  ├── arm       →  player_arm.tres
  └── handgun   →  player_handgun.tres
```

This lets you attach each part to a separate `AnimatedSprite2D` and swap them independently at runtime (e.g. switching the handgun sprite without touching the body). If a character only needs one sprite, it only needs one layer.

**Skipping layers:**

Prefix a layer name with `_` to exclude it from export. Useful for reference layers, guides, or anything that exists only to aid drawing and should never become a game asset.

```
player.ase
  ├── body
  ├── arm
  ├── handgun
  └── _reference   ← skipped, no .tres generated
```

Enable the plugin under **Project > Project Settings > Plugins**.

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
