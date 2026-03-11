# Godot UI Nodes: Minimal Control Node Policy

## Decision

This project **avoids using most `Control` nodes** for UI and in-game overlays.
All UI visuals and numbers are primarily rendered using `Sprite2D` nodes with custom logic.

The **only permitted exception is the `Label` node**.

`Label` may be used for simple text rendering because it does not introduce complex styling systems or interactive behavior.

## Context

* Most `Control` nodes provide layout, styling, and input logic intended for traditional UI workflows.
* These systems introduce behaviors that can conflict with pixel-perfect rendering, including:

  * Automatic anchoring and container layout.
  * Theme-driven styling.
  * Built-in mouse and focus behavior.
* Interactive controls such as `Button`, `CheckBox`, `OptionButton`, and similar nodes bring additional visual and behavioral assumptions that are undesirable for a custom-styled game UI.

However, the `Label` node is an acceptable exception because:

* It is **lightweight and focused solely on text rendering**.
* It **does not enforce interactive behavior** like buttons or selectors.
* It **does not impose significant theme or style constraints** when used with a custom font.
* It simplifies text rendering compared to building a full custom glyph system.

Because of this, `Label` provides a practical balance between **engine convenience and rendering control**.

## Consequences

* Most UI elements will require **manual positioning and sizing logic** using `Sprite2D` nodes.
* Interactive UI components must be implemented with **custom logic rather than built-in Control widgets**.
* Text rendering may use `Label` nodes where appropriate.
* Visual style and pixel fidelity remain fully under project control.

## Alternatives Considered

* **Using Control nodes for all UI:**
  Rejected due to styling conflicts, built-in interaction behavior, and reduced visual control.

* **Using only Sprite2D for everything (including text):**
  Considered but rejected due to increased complexity for text rendering.

* **Hybrid approach with many Control nodes:**
  Rejected to avoid mixing layout systems and to maintain visual consistency.

* **Allowing only `Label` from the Control system:**
  Accepted as a minimal and practical compromise.
