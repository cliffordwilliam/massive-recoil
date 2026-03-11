## Recommendation

To use a **pixel font (such as `monogram.ttf`) as the global UI font in Godot**, configure both the **font import settings** and the **project-wide theme settings** so the font renders with sharp pixel edges.

### 1. Import and configure the pixel font

Import the font (`*.ttf`, `*.otf`) so it becomes a `FontFile` resource, then configure the importer settings in the **Import dock**.

For pixel fonts, the recommended options from `ResourceImporterDynamicFont` are:

* **Disable antialiasing**

  * `.import` setting: `antialiasing=0`
* **Disable subpixel positioning**

  * `.import` setting: `subpixel_positioning=0`
* **Disable smoothing techniques meant for scalable fonts**

  * `multichannel_signed_distance_field=false`
  * `generate_mipmaps=false`

Example pixel-font-friendly snippet:

```ini
[params]
antialiasing=0
subpixel_positioning=0
multichannel_signed_distance_field=false
generate_mipmaps=false
```

These settings ensure glyphs remain **crisp and aligned to the pixel grid** rather than being smoothed like normal vector fonts.

### 2. Set the font as the project-wide default

To use the font across all UI elements:

1. Open **Project → Project Settings**.
2. Navigate to **GUI → Theme → Custom Font**.
3. Set:

```
gui/theme/custom_font = res://fonts/monogram.tres
```

Once set, all `Control` nodes will use this font by default unless overridden by a theme or per-node font.

### 3. Disable texture filtering for pixel fonts

Pixel fonts behave like pixel-art textures, so filtering should be disabled globally:

**Project Settings → Rendering → Textures → Canvas Textures → Default Texture Filter**

```
rendering/textures/canvas_textures/default_texture_filter = Nearest
```

This ensures glyph textures are sampled with **nearest-neighbor filtering**, keeping the pixel grid sharp.

---

## Why

Pixel fonts require different rendering settings than typical scalable fonts.

* **Antialiasing** smooths edges between pixels, which makes pixel fonts look blurry.
* **Subpixel positioning** can shift glyphs by fractional pixels, causing uneven pixel widths.
* **Bilinear filtering** blends texture samples, which softens the edges of glyph textures.
* **Project-wide custom font** ensures consistent typography without manually assigning the font to every UI node.

Applying these settings keeps the font **aligned to the pixel grid and visually consistent across the UI**.

---

## Citation

`tutorials/ui/gui_using_fonts.rst`

> “Fonts that have a pixel art appearance should have bilinear filtering disabled by changing the **Rendering > Textures > Canvas Textures > Default Texture Filter** project setting to **Nearest**.”
> “Fonts that have a pixel art appearance should have their subpixel positioning mode set to **Disabled**. Otherwise, the font may appear to have uneven pixel sizes.”

`classes/class_resourceimporterdynamicfont.rst`

> “**Disabled:** Most suited for pixel art fonts…”
> “This should be set to **Disabled** for fonts with a pixel art appearance.”

`tutorials/ui/gui_skinning.rst`

> “Custom themes can be applied in two ways: as a project setting, and as a node property throughout the tree of control nodes.”
> “GUI > Theme > Custom Font allows you to set a custom project-wide default fallback font.”

`classes/class_projectsettings.rst`

> “**gui/theme/custom_font** — Path to a custom `Font` resource to use as default for all GUI elements of the project.”
