## Recommendation

The comment is **correct in practice**, but slightly imprecise about the mechanism. Using `assign()` is the right approach, but the reason is not that a bare `return` is "not guaranteed" — it is that a bare `return` of an untyped `Array` is **silently allowed** by GDScript due to a special compatibility exception, but produces an **untyped array at runtime** regardless of the function's return annotation.

The correct pattern is:

```gdscript
func get_items() -> Array[ItemData]:
    var result: Array[ItemData] = []
    result.assign(my_dict.values())
    return result
```

## Why

Two separate doc-confirmed facts combine to make the comment true:

1. **`Dictionary.values()` always returns a plain, untyped `Array`**, even if the dictionary is typed. The static typing guide explicitly states: *"Dictionary methods that return values and other operators (such as `==`) are still untyped."*

2. **GDScript has a special compatibility exception**: assigning an untyped `Array` to a typed `Array[T]` variable (or returning one from a typed function) is *allowed* by the `=` operator without a compile-time error — but it is **unsafe**. The underlying runtime value remains untyped. The documentation warns: *"The only exception was made for the `Array` (`Array[Variant]`) type, for user convenience and compatibility with old code. However, operations on untyped arrays are considered unsafe."*

   This exception is what makes the bare `return` silently pass. No warning is raised unless the opt-in `UNSAFE_CALL_ARGUMENT` project setting (under **Debug > GDScript**, default `= 0`) is enabled.

`assign()` avoids this because it **copies contents and performs type conversion**, not reference assignment, giving you a genuinely typed array at runtime.

## Citation

`tutorials/scripting/gdscript/gdscript_basics.rst`

> "If you want to *convert* a typed array, you can create a new array and use the `Array.assign()` method... The only exception was made for the `Array` (`Array[Variant]`) type, for user convenience and compatibility with old code. However, operations on untyped arrays are considered unsafe."

`tutorials/scripting/gdscript/static_typing.rst`

> "Dictionary methods that return values and other operators (such as `==`) are still untyped."

`classes/class_array.rst`

> "`void assign(array: Array)` — Assigns elements of another array into the array. Resizes the array to match array. **Performs type conversions if the array is typed.**"
