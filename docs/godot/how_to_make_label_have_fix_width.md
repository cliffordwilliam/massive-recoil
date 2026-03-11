## Recommendation

**There is no built‑in “max characters” property on `Label`.**  
To stop the text from “keeping going”, you must either:

- **Manually clamp the string before assigning it**, e.g. only keep the last `digits` characters for a right‑aligned numeric display:  
  - `label.text = raw.right(digits)` or a similar substring operation, or  
  - `label.text = str(number).lpad(digits, "0")` the way your `NumberDisplay` does.  
- Or, if this is user text input, use a `LineEdit` instead and set:  
  - `LineEdit.max_length` to the desired character limit, then mirror that text into a `Label` if needed.

`Label.visible_characters` only controls how many characters are drawn, not how many can be set on `text`, so it won’t prevent the text from growing, just from being fully rendered.

## Why

- The `Label` docs list properties like `text`, `clip_text`, `text_overrun_behavior`, `max_lines_visible`, and `visible_characters`, but **no `max_length` or equivalent input limit**; therefore, limiting the string length has to be done in your own code before assigning to `text`.  
- By contrast, `LineEdit` explicitly has a `max_length` property that truncates text when the user tries to exceed the limit, which is why for input fields the engine recommends using `LineEdit` instead of `Label` when you need a hard character cap.

## Citation

`classes/class_label.rst`

> “The text to display on screen.” (for `text`)  

> “The number of characters to display. If set to `-1`, all characters are displayed.” (for `visible_characters`)

`classes/class_lineedit.rst`

> “`int max_length = 0` … Maximum number of characters that can be entered inside the `LineEdit`. If `0`, there is no limit. When a limit is defined, characters that would exceed `max_length` are truncated. This happens both for existing `text` contents when setting the max length, or for new text inserted in the `LineEdit`, including pasting.”