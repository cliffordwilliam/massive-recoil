## Recommendation

- **Base resolution and stretch**  
  - Set your pixel-art design resolution in:  
    - `display/window/size/viewport_width`  
    - `display/window/size/viewport_height`  
  - Use a pixel-perfect stretch:  
    - `display/window/stretch/mode = "viewport"`  
    - `display/window/stretch/scale_mode = "integer"`  

- **Pixel snapping for 2D**  
  - Enable transform snapping (preferred first):  
    - `rendering/2d/snap/snap_2d_transforms_to_pixel = true`  
  - Optionally also enable vertex snapping if needed:  
    - `rendering/2d/snap/snap_2d_vertices_to_pixel = true`  

- **Texture filtering and fonts**  
  - Use nearest filtering for crisp pixels:  
    - `rendering/textures/canvas_textures/default_texture_filter = Nearest`  
  - For pixel-art fonts, also ensure integer scaling of font size and controls.  

- **Texture import for sprites**  
  - For 2D pixel-art sprites, set the import preset to:  
    - `Compress > Mode = Lossless`  
  - Avoid VRAM compression for pixel-art textures, even in 3D.  

- **Antialiasing**  
  - Leave `rendering/anti_aliasing/quality/msaa_2d` at `0` (disabled) or low, since MSAA does not fix aliasing in nearest-neighbor (pixel art) textures.  

- **Sprite placement**  
  - For `Sprite2D`/`AnimatedSprite2D`, either:  
    - Set `centered = false`, **or**  
    - Rely on the 2D snap settings above to avoid “between-pixel” positions that deform sprites.  

## Why

- **Base resolution and stretch**  
  - The docs recommend `display/window/stretch/mode = "viewport"` specifically “for games that use a pixel art aesthetic”, and explain that the base viewport width/height are the reference for stretch calculations. Integer `scale_mode` ensures the window is always an integer multiple of that base size, which “provides a crisp pixel art appearance.”

- **Pixel snapping**  
  - `rendering/2d/snap/snap_2d_transforms_to_pixel` and `rendering/2d/snap/snap_2d_vertices_to_pixel` are described as “useful for low-resolution pixel art games” because they snap `CanvasItem` positions/vertices to full pixels, trading some smoothness for a “crisper appearance.” The Sprite2D docs explicitly suggest using these settings to avoid deformed pixel-art textures.

- **Texture filtering and fonts**  
  - The default canvas texture filter notes that for “pixel art aesthetics” you should also consider the 2D snap settings. The font tutorial states that fonts with a “pixel art appearance” should disable bilinear filtering via `Rendering > Textures > Canvas Textures > Default Texture Filter = Nearest` and use integer multiples of the design size; this same nearest filtering is what you want for pixel-art sprites to avoid blur.

- **Texture import**  
  - In the image import tutorial, `Compress > Mode = Lossless` is “the recommended setting for pixel art” and a note stresses that even in 3D, “pixel art” textures should have VRAM compression disabled, as it harms appearance without meaningful performance benefit at low resolutions.

- **Antialiasing**  
  - The 2D antialiasing tutorial explains that MSAA does **not affect** aliasing within nearest-neighbor filtered (pixel art) textures, so enabling it doesn’t fix jagged pixels in pixel art; leaving MSAA 2D off keeps the look authentic and avoids unnecessary cost.

- **Sprite placement**  
  - The Sprite2D documentation warns that for “games with a pixel art aesthetic, textures may appear deformed when centered” due to their position being between pixels, and recommends disabling `centered` or enabling the 2D snap project settings to fix this, which is why those are part of the setup.

## Citation

- `classes/class_projectsettings.rst`  

  > “`"viewport"`: The size of the root `Viewport` is set precisely to the base size specified in the Project Settings' Display section… Recommended for games that use a pixel art aesthetic.”  

  > “`int` **display/window/size/viewport_width** … Sets the game's main viewport width… Stretch mode settings also use this as a reference when using the `"canvas_items"` or `"viewport"` stretch modes.”  

  > “`"integer"`: The scale factor will be floored to an integer value, which means that the screen size will always be an integer multiple of the base viewport size. **This provides a crisp pixel art appearance.**”  

  > “If `true`, `CanvasItem` nodes will internally snap to full pixels. **Useful for low-resolution pixel art games.** … This can lead to a crisper appearance…” (`rendering/2d/snap/snap_2d_transforms_to_pixel`)  

  > “If `true`, vertices of `CanvasItem` nodes will snap to full pixels. **Useful for low-resolution pixel art games.** … This can lead to a crisper appearance…” (`rendering/2d/snap/snap_2d_vertices_to_pixel`)  

  > “The default texture filtering mode to use for `CanvasItem`s built-in texture… **Note:** For pixel art aesthetics, see also `rendering/2d/snap/snap_2d_vertices_to_pixel` and `rendering/2d/snap/snap_2d_transforms_to_pixel`.” (`rendering/textures/canvas_textures/default_texture_filter`)  

- `classes/class_window.rst`  

  > “On the root `Window`, [content_scale_size] is set to match `ProjectSettings.display/window/size/viewport_width` and `ProjectSettings.display/window/size/viewport_height` by default.”  

- `tutorials/assets_pipeline/importing_images.rst`  

  > “**Lossless:** … This is also the **recommended setting for pixel art.**”  

  > “Even in 3D, ‘pixel art’ textures should have **VRAM compression disabled** as it will negatively affect their appearance…”  

- `tutorials/2d/2d_antialiasing.rst`  

  > “As a result, MSAA will **not affect** the following kinds of aliasing in any way:  
  > `-` Aliasing *within* nearest-neighbor filtered textures (**pixel art**).”  

- `tutorials/ui/gui_using_fonts.rst`  

  > “Fonts that have a pixel art appearance should have bilinear filtering disabled by changing the **Rendering > Textures > Canvas Textures > Default Texture Filter** project setting to **Nearest**.”  

- `classes/class_sprite2d.rst`  

  > “For games with a **pixel art aesthetic**, textures may appear deformed when centered. This is caused by their position being between pixels. To prevent this, set this property to `false`, or consider enabling `ProjectSettings.rendering/2d/snap/snap_2d_vertices_to_pixel` and `ProjectSettings.rendering/2d/snap/snap_2d_transforms_to_pixel`.”