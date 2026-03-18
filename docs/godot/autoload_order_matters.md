## Recommendation

Yes, autoload registration order **does matter**.

When configuring autoloads in **`Project > Project Settings > Globals > Autoload`**:

- **Arrange autoloads in the desired initialization and tree order** using the up/down arrows in the Autoload list.
- Assume that:
  - Autoloads are added to the root viewport **in top-to-bottom order**.
  - All autoloads appear **before** the currently loaded scene in the root.

If any of your code relies on child indices under `/root` or on certain autoloads being available before others, explicitly order them in the Autoload tab to match that dependency.

## Why

The documentation states that the list order “can be manipulated” and that the engine “will read these nodes in top-to-bottom order,” meaning the registration order defines how they are added to the global scene tree. It also explicitly notes that autoloaded nodes are always added **before** the currently loaded scene as children of the root, which can affect logic that inspects or indexes root children (for example, using `get_child()` or negative indices like `get_child(-1)`).

Therefore, to avoid subtle bugs and to make initialization deterministic, you should treat the autoload list order as a meaningful execution/scene-tree order and organize it accordingly.

## Citation

`tutorials/scripting/singletons_autoload.rst`

> “Here you can add any number of scenes or scripts. Each entry in the list requires a name, which is assigned as the node's `name` property. **The order of the entries as they are added to the global scene tree can be manipulated using the up/down arrow keys. Like regular scenes, the engine will read these nodes in top-to-bottom order.**”

> “Both the current scene (the one with the button) and `global.gd` are children of root, but **autoloaded nodes are always first.** This means that the last child of root is always the loaded scene.”
