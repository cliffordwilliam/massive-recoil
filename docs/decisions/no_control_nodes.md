# Godot UI Nodes: No Control Nodes Policy

## Decision
This project does not use `Control` nodes for any UI or in-game overlays. All UI and numbers will be rendered using `Sprite2D` nodes with custom logic.

## Context
- Control nodes provide layout and styling logic for UI elements, but they come with:
  - Automatic anchoring, scaling, and theming that can conflict with pixel-perfect art.
  - Potential performance overhead in 2D games with many dynamic elements.
  - Limited flexibility for fully custom visuals.
- For a project that is heavily pixel-art or custom-styled, fighting the built-in style system often slows development and complicates maintenance.

## Consequences
- All UI and overlays will require manual positioning and sizing logic.
- Style changes are fully under our control — no engine-imposed constraints.
- Project remains consistent in rendering style and visual fidelity.

## Alternatives Considered
- **Using Control nodes for UI:** Rejected due to the styling conflict and reduced visual control.
- **Hybrid approach (some Control, some Sprites):** Rejected to maintain consistency and simplicity.