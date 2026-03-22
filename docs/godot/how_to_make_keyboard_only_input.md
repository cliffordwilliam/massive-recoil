
Here is a concise answer drawn only from the docs in this repo.

## Recommendation

There is **no documented project setting** that turns the whole project into “keyboard only” or blocks mouse/touch globally. To **drive gameplay from the keyboard** while still letting the GUI behave normally, use the input pipeline as documented:

- Prefer **`_unhandled_key_input()`** for **key** gameplay: it runs **after** GUI/`_input()` handling and only for key events in that stage (see input flow below).
- Enable or disable it with **`Node.set_process_unhandled_key_input(true|false)`** (overriding `_unhandled_key_input` turns processing on automatically before `_ready()`).
- To stop propagation after handling, call **`Viewport.set_input_as_handled()`** (as noted on `Node`).

**Parameter type in the API reference:** the method is declared as taking **`event: InputEvent`**, not `InputEventKey`, even though the description says it is called for **`InputEventKey`**. In the **input flow** tutorial, this step is explicitly **only for `InputEventKey`**. In scripts you normally narrow with `is InputEventKey` / `as InputEventKey` if you need key-specific members.

## Why

- **`_unhandled_key_input()`** is described as a good fit for gameplay keys **after** the GUI can consume events, and as **more efficient than `_unhandled_input()`** because events such as **`InputEventMouseMotion`** are **not** delivered to this callback.
- The **tutorial’s ordered steps** state that `_unhandled_key_input` runs **only when the event is an `InputEventKey`**, which matches “keyboard-only” handling for that callback—without needing a project-wide “disable mouse” setting.

## Citation

`classes/class_node.rst`

> `|void| **_unhandled_key_input**\ (\ event\: :ref:`InputEvent<class_InputEvent>`\ )`

> Called when an :ref:`InputEventKey<class_InputEventKey>` hasn't been consumed by :ref:`_input()<class_Node_private_method__input>` or any GUI :ref:`Control<class_Control>` item.

> This method also performs better than :ref:`_unhandled_input()<class_Node_private_method__unhandled_input>`, since unrelated events such as :ref:`InputEventMouseMotion<class_InputEventMouseMotion>` are automatically filtered.

`tutorials/inputs/inputevent.rst`

> 6. If so far no one consumed the event, the :ref:`Node._unhandled_key_input() <class_Node_private_method__unhandled_key_input>` callback … This happens only if the event is an :ref:`InputEventKey <class_InputEventKey>`. … The unhandled key input callback is ideal for key events.
