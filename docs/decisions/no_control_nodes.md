# Godot UI Nodes: Limited Control Node Policy

## Decision

This project **avoids using most `Control` nodes** for UI and in-game overlays.
UI visuals are primarily rendered using `Sprite2D` nodes with custom logic.

However, **non-interactive `Control` nodes that act purely as rendering utilities are allowed**.

Examples of acceptable `Control` nodes include:

* `Label`
* `NinePatchRect`
* Other **non-interactive display nodes**

Interactive UI widgets such as buttons, scroll containers, and similar controls **must not be used**.

## Context

Most `Control` nodes are designed for traditional application-style UI. They include built-in systems such as:

* Automatic anchoring and layout behavior
* Container-based layout systems
* Theme-driven styling
* Built-in mouse, focus, and navigation behavior

While these features are useful for general UI development, they can conflict with **pixel-perfect rendering** and **custom-styled game interfaces**.

Interactive controls such as:

* `Button`
* `CheckBox`
* `OptionButton`
* `ScrollContainer`
* `ItemList`
* Other complex widgets

introduce visual assumptions and interaction behaviors that are undesirable for this project.

However, some `Control` nodes function primarily as **simple rendering helpers** without significant behavioral overhead. Nodes like `Label` and `NinePatchRect` provide useful functionality while still allowing the project to maintain full visual control.

Allowing these limited cases provides practical engine conveniences without adopting the full Control UI system.

## Consequences

* Most UI elements will use **`Sprite2D` nodes with custom logic**.
* Interactive UI behavior must be implemented manually rather than using built-in widgets.
* Some **passive rendering `Control` nodes** may be used when they simplify implementation.
* Pixel-perfect rendering and stylistic consistency remain under project control.

## Alternatives Considered

**Using Control nodes for all UI**
Rejected due to styling conflicts, built-in behaviors, and reduced visual control.

**Using only `Sprite2D` nodes for everything**
Considered but rejected because some rendering utilities (such as text and nine-patch scaling) are unnecessarily complex to reimplement.

**Hybrid approach using many Control nodes**
Rejected to avoid reliance on container layout systems and complex UI behaviors.

**Allowing only `Label`**
Initially considered, but expanded to allow other **non-interactive rendering Controls** such as `NinePatchRect`.
