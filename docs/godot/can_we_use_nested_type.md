## Recommendation

You cannot use `Dictionary[String, Array[String]]` in GDScript typed annotations today.

Use one of these documented patterns instead:

- `Dictionary[String, Array]` (typed key, untyped nested collection)
- `Dictionary[String, Variant]` (typed key, fully untyped value)

Example workflow:

1. Declare the dictionary with a typed key and untyped value:
   - `var data: Dictionary[String, Array] = {}`
2. When reading values, validate/cast elements to `String` in code where needed.
3. Keep top-level typing (`String` keys) for analyzer support, since nested typed collections are disallowed.

## Why

Godot’s docs explicitly state that nested typed collections are not supported, including nested typed dictionaries/arrays.  
So while typed dictionaries are recommended for safer top-level key/value typing, inner collection typing like `Array[String]` inside `Dictionary[...]` cannot be expressed in the type annotation.

## Citation

`tutorials/scripting/gdscript/static_typing.rst`

> “Nested typed collections (like ``Dictionary[String, Dictionary[String, int]]``) are not supported.”

`tutorials/scripting/gdscript/gdscript_basics.rst`

> “Typed dictionaries have the syntax ``Dictionary[KeyType, ValueType]``…  
> Nested typed collections (like ``Dictionary[String, Dictionary[String, int]]``) are not supported.”

`classes/class_dictionary.rst`

> “Typed dictionaries can only contain keys and values of the given types, or that inherit from the given classes…”
