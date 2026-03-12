## Recommendation

If you *want* integer division (page index rounding down), your expression is already correct:

- **Integer division**: Keep `(_current_index / _PAGE_SIZE) * _PAGE_SIZE` as-is; GDScript divides as integers when both operands are `int`, truncating the decimal.
- **Floating-point division**: If you actually need a fractional result, make **at least one operand a `float`**, for example:
  - `_current_index / float(_PAGE_SIZE)`
  - `_current_index / (_PAGE_SIZE * 1.0)`
  - `_current_index / 2.0` (using a float literal instead of `2`)

There are no project settings to change this; it’s controlled purely by operand types in the expression.

## Why

Godot’s docs state that when both operands to `/` are `int`, **integer division is performed and the decimal part is discarded**. To get a non-integer result, the docs recommend using a float literal, casting to `float`, or multiplying by `1.0` so the operation is promoted to floating-point.

## Citation

`tutorials/scripting/gdscript/gdscript_basics.rst`

> “1. If both operands of the ``/`` operator are :ref:`int <class_int>`, then integer division is performed instead of fractional. For example ``5 / 2 == 2``, not ``2.5``.  
> If this is not desired, use at least one :ref:`float <class_float>` literal (``x / 2.0``), cast (``float(x) / y``), or multiply by ``1.0`` (``x * 1.0 / y``).”

`tutorials/scripting/evaluating_expressions.rst`

> “Division (``/``) — Performs and integer division if both operands are integers. If at least one of them is a floating-point number, returns a floating-point value.”
