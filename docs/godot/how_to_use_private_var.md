## Recommendation

In GDScript, **“private variables” are a naming convention**, not a language-enforced access modifier. To treat a variable as private:

- **Prefix the variable name with a single underscore** and keep normal snake_case:
  - Example: `var _counter = 0`
- **Use the same underscore convention for private helper methods**:
  - Example: `func _recalculate_path():`
- **Order your members so public come first, then private**, and within properties put private variables after public ones.

This is the official style used across the engine and docs and is what other Godot users will expect when they see a “private” field.

## Why

The documentation recommends using a leading underscore for private variables and functions so that:

- **They are visually distinguished from public API**, making it clear which fields and methods are meant to be internal details.
- **Code stays consistent with Godot’s own style**, reducing confusion when reading engine code, tutorials, or other people’s projects.
- **Public-before-private ordering** makes it easier to scan a script from top to bottom: you see the class interface (public members) first, then its internal implementation details.

## Citation

`tutorials/scripting/gdscript/gdscript_styleguide.rst`

> “Use snake\_case to name functions and variables:  
>  
> :::  
>  
> &nbsp;&nbsp;&nbsp;&nbsp;var particle_effect  
> &nbsp;&nbsp;&nbsp;&nbsp;func load_level():  
>  
> **Prepend a single underscore (\_) to virtual methods functions the user must override, private functions, and private variables:**  
>  
> :::  
>  
> &nbsp;&nbsp;&nbsp;&nbsp;**var \_counter = 0**  
> &nbsp;&nbsp;&nbsp;&nbsp;**func \_recalculate_path():**”

> “And put the class methods and variables in the following order depending on their access modifiers:  
>  
> :::  
>  
> &nbsp;&nbsp;&nbsp;&nbsp;1. **public**  
> &nbsp;&nbsp;&nbsp;&nbsp;2. **private**”

> “Then, write constants, exported variables, public, private, and onready variables, in that order.”
