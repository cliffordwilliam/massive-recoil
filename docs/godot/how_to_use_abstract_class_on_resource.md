## Recommendation

Yes. In Godot 4.5+ you can make this an abstract base resource and *require* children to override selected methods using the `@abstract` annotation.

For your example, you would do:

```gdscript
@icon("res://assets/images/static/icons/apparel_24dp_8DA5F3_FILL0_wght400_GRAD0_opsz24.svg")
@abstract
class_name ItemData
extends Resource

@export var id: StringName
@export var display_name: String
@export var size: Vector2i = Vector2i(1, 1)
@export var icon: Texture2D

@abstract func get_buy_price() -> int
@abstract func get_sell_price() -> int
@abstract func get_upgrade_price(_level: int) -> int
```

Then each concrete child (e.g. `ItemWeaponData`, `ItemConsumableData`) must implement all three methods, or itself be marked `@abstract` as well.

## Why

**Abstract classes** (`@abstract` on the class) cannot be instantiated directly and are meant only to be inherited.  
**Abstract methods** (`@abstract func ...` with no body) form a contract: inheriting classes must either implement all of them or also be marked `@abstract`. This is exactly how you enforce that your “kids” override the pricing functions, instead of relying on a dummy default implementation.

## Citation

`tutorials/scripting/gdscript/gdscript_basics.rst`

> “Since Godot 4.5, you can define abstract classes and methods using the `@abstract` annotation.  
> An abstract class is a class that cannot be instantiated directly. Instead, it is meant to be inherited by other classes. Attempting to instantiate an abstract class will result in an error.  
> … Inheriting classes must either provide implementations for all abstract methods, or the inheriting class must be marked as abstract. If a class has at least one abstract method (either its own or an unimplemented inherited one), then it must also be marked as abstract.”

`classes/class_@gdscript.rst`

> “**@abstract** … Marks a class or a method as abstract.  
> An abstract class is a class that cannot be instantiated directly. Instead, it is meant to be inherited by other classes. Attempting to instantiate an abstract class will result in an error.  
> … Inheriting classes must either provide implementations for all abstract methods, or the inheriting class must be marked as abstract.”
