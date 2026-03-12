## Recommendation

Export the enum-typed property directly so the Inspector shows a dropdown:

```gdscript
enum RenderMode {
	BUY,
	SELL,
	UPGRADE,
}

@export var render_mode: RenderMode = RenderMode.BUY:
	set(value):
		render_mode = value  # or _render_mode = value if you keep a backing field
		_update_page()
```

Key points:

- Use `@export var render_mode: RenderMode` so Godot knows the type and generates an enum dropdown in the Inspector.
- Put the `enum RenderMode { ... }` in the same script (as you already have).
- If you want to keep `_render_mode` as the internal field, expose a public exported property that forwards to it:
  ```gdscript
  var _render_mode: RenderMode = RenderMode.BUY

  @export var render_mode: RenderMode:
	  get: return _render_mode
	  set(value):
		  _render_mode = value
		  _update_page()
  ```

Then use `render_mode` in the Inspector to switch between BUY/SELL/UPGRADE.

## Why

The documentation shows that when you define a named GDScript enum and then export a variable typed with that enum, the Inspector presents it as an enum dropdown. It explicitly demonstrates defining `enum Direction { LEFT, RIGHT, UP, DOWN }` and then using `@export var direction: Direction`, and similarly exporting `Array[Direction]`. This is the pattern recommended for using named enums in the Inspector, instead of string-based `@export_enum`.

## Citation

`classes/class_@gdscript.rst`

> “Mark the following property as exported (editable in the Inspector dock and saved to disk). To control the type of the exported property, use the type hint notation.  
> :::  
> ```  
> extends Node  
>  
> enum Direction {LEFT, RIGHT, UP, DOWN}  
>  
> # Built-in types.  
> @export var string = ""  
> @export var int_number = 5  
> @export var float_number: float = 5  
>  
> # Enums.  
> @export var type: Variant.Type  
> @export var format: Image.Format  
> @export var direction: Direction  
>  
> # Typed arrays.  
> @export var int_array: Array[int]  
> @export var direction_array: Array[Direction]  
> ```”
