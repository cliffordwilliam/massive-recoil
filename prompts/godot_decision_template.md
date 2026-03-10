# Godot Design Decision Prompt

This repository contains the official Godot documentation.

Do not search online.

Find the answer in the documentation files.

Be specific with project settings and class properties.  
For example, mention `display/window/size/viewport_width` instead of vaguely saying "base window size".

Keep answers concise and structured.

Question:
{INSERT QUESTION}

Output format:

## Recommendation

Explain the best practice and list the relevant settings or workflow steps.

## Why

Explain why this approach is recommended according to the documentation.

## Citation

Provide file path and quote from documentation.

---

Example:

Question:
How should a pixel-art game configure texture filtering in Godot?

Answer:

## Recommendation

For pixel-art projects, disable texture filtering so sprites remain sharp.

Set the project setting:

- `rendering/textures/canvas_textures/default_texture_filter = Nearest`

This ensures textures are sampled using nearest-neighbor filtering instead of bilinear filtering, preventing pixel art from appearing blurry.

## Why

Pixel-art graphics rely on crisp edges between pixels. Linear filtering blends neighboring pixels together, which causes visible blur and destroys the intended aesthetic.

Using nearest filtering ensures each pixel is rendered exactly as authored.

## Citation

`tutorials/ui/gui_using_fonts.rst`

> “Fonts that have a pixel art appearance should have bilinear filtering disabled by changing the `Rendering > Textures > Canvas Textures > Default Texture Filter` project setting to `Nearest`.”
