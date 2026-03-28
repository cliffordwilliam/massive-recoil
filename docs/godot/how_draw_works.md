
Here is what the in-repo docs support and what they do **not** say.

---

## Recommendation

Treat **`CanvasItem._draw()`** as running only after something has called **`CanvasItem.queue_redraw()`** — either **your code** or **the engine**. Do **not** assume `_draw` is driven only by an internal “renderer” step, and do **not** rely on the docs for a guarantee that `_draw` always runs **after** **`_ready()`** (that ordering is not stated for `_draw`).

Workflow that matches the docs:

1. Override **`_draw()`** on a **`CanvasItem`** (e.g. **`Node2D`**, **`Control`**).
2. When content changes, call **`queue_redraw()`** on that node (from `_process`, setters, input, etc.).
3. Expect **`NOTIFICATION_DRAW`** and then **`_draw()`** **during idle time**, at most **once per frame** even if **`queue_redraw()`** was called multiple times (**`CanvasItem.queue_redraw()`**).

## Why

The docs explicitly separate **engine** and **manual** causes: **`_draw()`** is described as running after **`queue_redraw()`** is called **“either manually or by the engine.”** That contradicts any claim that **`_draw`** is **only** ever triggered by the renderer. **`queue_redraw()`** is what ties redraws to **idle** processing and **`NOTIFICATION_DRAW`**, not a vague “renderer after `_ready`” rule.

The tutorial also shows **manual** **`queue_redraw()`** (e.g. from a setter) as the way to get another **`_draw()`** call — again, not “renderer only.”

## Citation

`classes/class_canvasitem.rst`

> “Called when **CanvasItem** has been requested to redraw (after `queue_redraw()` is called, **either manually or by the engine**).”

`classes/class_canvasitem.rst` (**`queue_redraw()`**)

> “Queues the **CanvasItem** to redraw. During idle time, if **CanvasItem** is visible, `NOTIFICATION_DRAW` is sent and `_draw()` is called. This only occurs **once** per frame, even if this method has been called multiple times.”

`tutorials/2d/custom_drawing_in_2d.rst`

> “If re-drawing is required because a variable or something else changed, call `CanvasItem.queue_redraw` in that same node and a new `_draw()` call will happen.”

---

**Bottom line:** The truncated claim is **not** verified by the docs as written: **`_draw`** is tied to **`queue_redraw()`** (**manual or engine**), **idle** delivery, and **visibility** — not to “only the renderer” or to an explicit “always after **`_ready()`**” rule.
