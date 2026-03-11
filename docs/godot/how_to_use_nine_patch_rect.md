## Recommendation

Use a `NinePatchRect` control with a 3×3-friendly texture and configure its margins and stretch modes so the corners stay crisp while the borders/center resize.

Workflow:

- **Prepare texture**: Author a panel texture designed for 9-slice use (corners and borders in a 3×3 grid). If using an atlas, specify the region on the node with:
  - `NinePatchRect.region_rect` (Rect2 defining the sub-rectangle of the texture).
- **Assign texture** on the node:
  - `NinePatchRect.texture` = your `Texture2D`.
- **Define the slice margins** in pixels (how much of each edge is “fixed border”):
  - `NinePatchRect.patch_margin_left`
  - `NinePatchRect.patch_margin_top`
  - `NinePatchRect.patch_margin_right`
  - `NinePatchRect.patch_margin_bottom`
- **Choose center behavior**:
  - `NinePatchRect.draw_center = true` to tile/stretch the center, or `false` for borders-only frames.
- **Set horizontal/vertical tiling vs stretching** using:
  - `NinePatchRect.axis_stretch_horizontal`
  - `NinePatchRect.axis_stretch_vertical`
  - Values:
	- `AXIS_STRETCH_MODE_STRETCH` (0): stretch center (may distort).
	- `AXIS_STRETCH_MODE_TILE` (1): tile center with no distortion (texture must be seamless).
	- `AXIS_STRETCH_MODE_TILE_FIT` (2): tile then minimally stretch so each tile is fully visible.

## Why

Nine-patch panels are designed so the **corners remain untouched**, borders are repeated or stretched only along one axis, and the center fills the remaining space; this allows making clean, scalable UI panels from a single small texture. `NinePatchRect` formalizes this by splitting the texture into a 3×3 grid and letting you explicitly control which pixels belong to the fixed corners/borders (`patch_margin_*`), which region of the texture to use (`region_rect`), and how the resizable parts behave (`axis_stretch_*`, `draw_center`).

## Citation

`classes/class_ninepatchrect.rst`

> “Also known as 9-slice panels, **NinePatchRect** produces clean panels of any size based on a small texture. To do so, it splits the texture in a 3×3 grid. When you scale the node, it tiles the texture's edges horizontally or vertically, tiles the center on both axes, and leaves the corners unchanged.”

> “Rectangular region of the texture to sample from. If you're working with an atlas, use this property to define the area the 9-slice should use. All other properties are relative to this one. If the rect is empty, NinePatchRect will use the whole texture.” (for `region_rect`)

> “The width of the 9-slice's left column. A margin of 16 means the 9-slice's left corners and side will have a width of 16 pixels. You can set all 4 margin values individually to create panels with non-uniform borders.” (for `patch_margin_left`, similarly for top/right/bottom)

> “Stretches the center texture across the NinePatchRect. This may cause the texture to be distorted.” / “Repeats the center texture across the NinePatchRect. This won't cause any visible distortion. The texture must be seamless for this to work without displaying artifacts between edges.” / “Repeats the center texture across the NinePatchRect, but will also stretch the texture to make sure each tile is visible in full.” (for `AxisStretchMode` and `axis_stretch_horizontal` / `axis_stretch_vertical`)