## Recommendation

**Yes, it’s possible.** Make the script run in the editor and put your logic in an exported property’s setter:

- **Enable editor execution** by adding `@tool` at the very top of the script:
  - `@tool`
- **Export the number property and keep the setter that updates digits**, e.g.:

```gdscript
@tool
class_name SplitFlap
extends Node2D

@onready var _digits: Array = [$D1, $D2, $D3, $D4, $D5, $D6, $D7, $D8]
@onready var _size: int = _digits.size()
@onready var _max_number: int = int(pow(10, _size)) - 1

@export var is_right_aligned: bool = false
@export var pad_with_zeros: bool = false
@export var pad_length: int = 3 

@export var number: int = 0:
	set(value):
		_number = clampi(value, 0, _max_number)
		_update_digits()

var _number: int = 0
```

- With `@tool` set, changing `number` in the Inspector will call the setter, which calls `_update_digits()`, so your sprites will visually update in the **editor** as you tweak the export.

(Optionally, wrap heavy logic in `if Engine.is_editor_hint():` if you want different behavior between editor and game.)

## Why

- **Scripts don’t run in the editor by default**; only exported properties can be edited. Adding `@tool` makes the script execute while you are in the editor, so property setters and methods like `_ready()` can react to Inspector changes.
- **Exported properties with setters are called when edited in the Inspector**, allowing you to react immediately to value changes (here, clamping and calling `_update_digits()` to refresh the display).
- The docs explicitly show a `@tool` script with an exported property whose setter mutates other data and calls `notify_property_list_changed()`, demonstrating that editor-side changes to an exported property invoke its setter.

## Citation

`tutorials/scripting/gdscript/gdscript_basics.rst`

> “By default, scripts don't run inside the editor and only the exported properties can be changed. In some cases, it is desired that they do run inside the editor… For this, the `@tool` annotation exists and must be placed at the top of the file:”

`tutorials/plugins/running_code_in_the_editor.rst`

> “To turn a script into a tool, add the `@tool` annotation at the top of your code.… Pieces of code that do not have either of the 2 conditions above will run both in-editor and in-game.”

`classes/class_object.rst`

> “@tool  
> extends Node  
>  
> @export var number_count = 3:  
>     set(nc):  
>         number_count = nc  
>         numbers.resize(number_count)  
>         notify_property_list_changed()”