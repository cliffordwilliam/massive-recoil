## Recommendation

Use **`StringName`** for identifiers and other **static strings that are reused and compared frequently**, such as:

- **Node, property, method, signal, animation, and input action names** (e.g. in APIs that already take `StringName`, or in GDScript via the literal syntax `&"my_name"`).
- **Engine-side “keys”** that appear in multiple places and are **not user-facing text**, especially when they are often compared or used as map/set keys.

In GDScript, prefer:

- Passing regular `String` values to APIs that expect `StringName` (the engine will convert them efficiently), and  
- Using the `&"example"` literal or explicitly constructing `StringName("example")` **only when you want to control when the conversion happens or avoid repeated conversions**.

Keep using `String` as the **default** type for general text, UI labels, and other user-visible content.

## Why

`StringName` implements **string interning**: two `StringName`s with the same value are the *same object*, so comparisons are much faster than with normal `String`s. The docs recommend it specifically **“for static strings that are referenced frequently and used in multiple locations in the engine”**, which matches identifiers and engine keys rather than arbitrary text. The engine also notes that while `StringName` exposes all of `String`’s methods, they first convert the `StringName` back to a `String`, which is “highly inefficient” and should be avoided—hence using `String` for normal text and `StringName` only where its fast-compare and interned behavior matters.

## Citation

`engine_details/architecture/core_types.rst`

> “`StringName` … Uses string interning for fast comparisons. **Use this for static strings that are referenced frequently and used in multiple locations in the engine.**”

`classes/class_stringname.rst`

> “**StringName**s are immutable strings designed for general-purpose representation of unique names (also called *‘string interning’*). Two **StringName**s with the same value are the same object. Comparing them is extremely fast compared to regular `String`s.”  

> “You will usually pass a `String` to methods expecting a **StringName** and it will be automatically converted (often at compile time), but **in rare cases you can construct a `StringName` ahead of time … Manually constructing a `StringName` allows you to control when the conversion from `String` occurs or to use the literal and prevent conversions entirely.**”  

> “All of `String`’s methods are available in this class too. They convert the **StringName** into a string, and they also return a string. **This is highly inefficient and should only be used if the string is desired.**”
