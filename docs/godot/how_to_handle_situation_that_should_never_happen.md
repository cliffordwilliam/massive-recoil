## Recommendation

- **In game scripts (GDScript)**:  
  - Use **`assert(condition, "explanation")`** when you hit a situation that “should never happen” (invalid state, invalid animation key, impossible branch). This both reports the error and **pauses execution in debug builds** so you can inspect the problem.  
  - If you want to **report an error but let the game keep running**, use **`push_error("description of invalid state")`**.
- **Do *not* crash the game** for these logic bugs:  
  - Avoid `OS.crash()` in gameplay code; it is reserved for **testing the crash handler** only.  
  - In C++/engine-side code, use **error macros** (`ERR_FAIL_COND_MSG`, `ERR_FAIL_INDEX_MSG`, etc.) to report invalid states/arguments and return a safe value instead of crashing.
- **Optional project settings for asserts**:  
  - Use `debug/gdscript/warnings/assert_always_false` and `debug/gdscript/warnings/assert_always_true` in `ProjectSettings` to get warnings/errors when an `assert` is trivially always false or always true (helps keep assertions meaningful).

## Why

- The docs explicitly state that **crashing is against Godot’s philosophy** and should only be used to test crash handling; instead, you should report the error and let the engine keep running when possible.  
- `assert` is documented as a **“stronger form of `push_error`”**: it generates an error and pauses the running project in the editor, making it ideal for catching “this must never happen” conditions during development.  
- `push_error` is documented as a way to **push an error to the debugger and terminal without pausing execution**, which is suitable when you want visibility into bad states but can safely continue.  
- The C++ error macros section emphasizes **printing clear error messages and returning processable data so the engine can keep running well**, again reinforcing that you should not crash on invalid states.

## Citation

- `classes/class_os.rst`

> “Crashes the engine (or the editor if called within a `@tool` script). …  
> **Note:** This method should *only* be used for testing the system's crash handler, not for any other purpose. For general error reporting, use (in order of preference) `@GDScript.assert()`, `@GlobalScope.push_error()`, or `alert()`.”

- `classes/class_@gdscript.rst`

> “`assert(condition: bool, message: String = "")` …  
> *Asserts that the `condition` is `true`. If the `condition` is `false`, an error is generated. When running from the editor, the running project will also be paused until you resume it. This can be used as a **stronger form of `@GlobalScope.push_error()` for reporting errors** to project developers or add-on users.*”

- `classes/class_@globalscope.rst`

> “`push_error(...)` …  
> *Pushes an error message to Godot's built-in debugger and to the OS terminal.* …  
> **Note:** *This function does not pause project execution. To print an error message and pause project execution in debug builds, use `assert(false, "test error")` instead.*”

- `engine_details/architecture/common_engine_methods_and_macros.rst`

> *“Godot features many error macros to make error reporting more convenient.”* …  
> *“Also, always try to return processable data so the engine can keep running well.”* …  
> *“Crashes the engine. This should generally never be used except for testing crash handling code. **Godot's philosophy is to never crash, both in the editor and in exported projects.** `CRASH_NOW_MSG("Can't predict the future! Aborting.");`”*

- `classes/class_projectsettings.rst`

> “`int debug/gdscript/warnings/assert_always_false = 1` …  
> *When set to **Warn** or **Error**, produces a warning or an error respectively when an `assert` call always evaluates to `false`.*  
>  
> “`int debug/gdscript/warnings/assert_always_true = 1` …  
> *When set to **Warn** or **Error**, produces a warning or an error respectively when an `assert` call always evaluates to `true`.*”