## Recommendation

Use **named GDScript enums with type hints and `@export`**:

- **Define the enum in your script**:
  ```gdscript
  enum Direction { LEFT, RIGHT, UP, DOWN }
  ```
- **Use it as a type in variables and exports** so the Inspector shows a dropdown:
  ```gdscript
  @export var direction: Direction
  @export var direction_array: Array[Direction]
  ```
- For simple, Inspector-only enums that don’t need a named type, use `@export_enum`:
  ```gdscript
  @export_enum("Warrior", "Magician", "Thief") var character_class: int
  ```

## Why

Named enums make your code **self-documenting and strongly typed**, and when combined with `@export`, they integrate cleanly with the Inspector (typed dropdowns, arrays of enums, etc.). The documentation explicitly shows using `enum` plus `@export` for named enums, and reserves `@export_enum` for simple value lists; it also states that if you want to use *named GDScript enums*, you should use `@export` instead of `@export_enum`.

## Citation

`classes/class_@gdscript.rst`

> “Mark the following property as exported (editable in the Inspector dock and saved to disk). To control the type of the exported property, use the type hint notation.  
> :::  
> ```  
> extends Node  
>  
> enum Direction {LEFT, RIGHT, UP, DOWN}  
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

`classes/class_@gdscript.rst`

> “**@export_enum** … Export an … property as an enumerated list of options…  
> :::  
> ```  
> @export_enum("Warrior", "Magician", "Thief") var character_class: int  
> …  
> ```  
> …  
> If you want to use named GDScript enums, then use :ref:`@export<class_@GDScript_annotation_@export>` instead:  
> :::  
> ```  
> enum CharacterName {REBECCA, MARY, LEAH}  
> @export var character_name: CharacterName  
>  
> enum CharacterItem {SWORD, SPEAR, MACE}  
> @export var character_items: Array[CharacterItem]  
> ```”

`tutorials/scripting/gdscript/gdscript_documentation_comments.rst`

> “Alternatively, you can use inline documentation comments:  
> :::  
> ```  
> enum MyEnum { ## My enum.  
>     VALUE_A = 0, ## Value A.  
>     VALUE_B = 1, ## Value B.  
> }  
> ```”
