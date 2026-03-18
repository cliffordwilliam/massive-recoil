# Keyboard-Only Input Policy

## Decision
This project is a **keyboard-only** game.

No UI or gameplay feature will rely on mouse, touch, or gamepad input. All navigation and actions must be driven by Godot **Input Map actions** that are mapped from keyboard keys.

## Rationale
- Keeping input handling deterministic avoids edge cases around hover/focus/click behavior.

## Consequences / Guidelines
- Override only `_unhandled_key_input(event: InputEvent)` for keyboard-driven UI/gameplay.
  - Godot only calls this for unhandled key events.
