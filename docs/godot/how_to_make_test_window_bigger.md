## Recommendation

- **Keep your game’s internal resolution at 320×180**, but make the game window bigger during development.
- In `project.godot`, add (or set) these project settings:

  - `display/window/size/viewport_width = 320`
  - `display/window/size/viewport_height = 180`  *(as you already have)*
  - `display/window/size/window_width_override = 1280`  *(example – pick a size comfortable on your monitor)*
  - `display/window/size/window_height_override = 720`   *(matching aspect ratio)*
  - Keep your existing stretch setup:
	- `display/window/stretch/mode = "viewport"`
	- `display/window/stretch/scale_mode = "integer"`

This keeps the game logic at 320×180 for pixel-perfect behavior but displays it in a larger window while testing.

## Why

- **`display/window/size/viewport_width` and `display/window/size/viewport_height`** define the game’s base viewport size and also the initial window size by default.
- **`display/window/size/window_width_override` and `display/window/size/window_height_override`** let you override that initial window size on desktop, so you can scale the view up for testing without changing the game’s designed resolution.
- With **stretch mode `"viewport"` and `scale_mode = "integer"`**, the engine renders at the base viewport resolution, then scales it up by an integer factor to fill the larger window, preserving crisp pixels.

## Citation

From `classes/class_projectsettings.rst`:

> `display/window/size/viewport_height`  
> “Sets the game's main viewport height. On desktop platforms, this is also the initial window height, represented by an indigo-colored rectangle in the 2D editor. Stretch mode settings also use this as a reference when using the `canvas_items` or `viewport` stretch modes.”

> `display/window/size/viewport_width`  
> “Sets the game's main viewport width. On desktop platforms, this is also the initial window width, represented by an indigo-colored rectangle in the 2D editor. Stretch mode settings also use this as a reference…”

> `display/window/size/window_height_override`  
> “On desktop platforms, overrides the game's initial window height. See also `display/window/size/window_width_override`, `display/window/size/viewport_width` and `display/window/size/viewport_height`.”

> `display/window/size/window_width_override`  
> “On desktop platforms, overrides the game's initial window width…  
> **Note:** By default, or when set to `0`, the initial window width is the `display/window/size/viewport_width`.”