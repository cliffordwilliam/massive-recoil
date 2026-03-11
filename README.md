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

## Icons

Scenes use custom icons from [Material Design Icons](https://fonts.google.com/icons)
with the color `#8da5f3`.


## Fonts

Monogram by datagoblin
https://datagoblin.itch.io/monogram
License: CC0 1.0 Universal (Public Domain)