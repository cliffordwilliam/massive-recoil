## Recommendation

For stateless utility/helper functions in Godot, use a plain GDScript file with `class_name` and `static func`—optionally extending `RefCounted` to act as a lightweight namespace without tying it to the scene tree.

### Typical setup

* **Script file**: e.g. `res://util.gd`

* **Script header**:

  ```gdscript
  extends RefCounted   # optional, prevents showing in node creation dialog
  class_name Util      # globally registers the type
  ```

* **Functions**:

  ```gdscript
  static func lerp_angle(a: float, b: float, weight: float) -> float:
      ...
  ```

* **Usage anywhere**:

  ```gdscript
  Util.lerp_angle(...)
  ```

  No autoload, no `load()`/`preload()`, no node instance required.

* **Important**: Only extend `Node`/`Node2D` if your script needs to be in the scene tree (e.g., `_process()`, transforms, or children). Otherwise, `RefCounted` keeps it lightweight and scene-independent.

---

## Why

* **Stateless helpers**: Static functions + `class_name` allow global access without requiring instances or global state.
* **Lightweight namespace**: Extending `RefCounted` avoids cluttering the node creation dialog and signals that this script is a utility, not a scene object.
* **Avoids global nodes**: Autoloads are reserved for systems that need global state or scene-wide management. For pure helper functions, this pattern is simpler and safer.
* **Recommended in docs**: Godot explicitly shows this pattern for libraries of helper functions and namespaces, combining `class_name`, `static func`, and optionally `RefCounted`.

---

## Citation

* **Static functions & `class_name`**:
  `tutorials/scripting/gdscript/gdscript_basics.rst`

  > “GDScript supports the creation of `static` functions using `static func`. When combined with `class_name`, this makes it possible to create libraries of helper functions without having to create an instance to call them.”
  > “Named classes are globally registered, which means they become available to use in other scripts without the need to `load` or `preload` them.”

* **RefCounted as namespace**:
  `tutorials/best_practices/scenes_versus_scripts.rst`

  > “The script becomes, in effect, a namespace:
  > `class_name Game # extends RefCounted, so it won't show up in the node creation dialog.`
  > `extends RefCounted` … `const MyScene = preload("my_scene.tscn")`”

* **Autoload vs static helpers**:
  `tutorials/best_practices/autoloads_versus_internal_nodes.rst`

  > “In the case of functions, you can create a new type of `Node` that provides that feature for an individual scene using the `class_name` keyword in GDScript.”
  > “Static functions are useful to make libraries of helper functions. The limitation is that they can't reference member variables, non-static functions or `self`.”