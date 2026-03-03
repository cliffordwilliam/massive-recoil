# Agent Code Review Prompt — Massive Recoil

## Context

This is a **Godot GDScript** project.

---

## Documentation Reference

The latest stable Godot documentation has been fetched locally and lives at:

```
docs/godot/
```

**This is your only permitted source for Godot API facts.**

- Do not rely on training data for anything Godot-API-specific
- Before making any finding related to a Godot method, signal, property, or pattern — look it up in `docs/godot/` first
- If you cannot find it in the docs, say so explicitly rather than guessing

---

## Scope

**Only review `.gd` files** found in these directories:

```
src/
```

Recursively include all `.gd` files within subdirectories.

**Explicitly exclude everything else:**

```
addons/           ← third-party plugins, not our code
assets/           ← art assets only
docs/             ← reference material
*.tscn            ← scene files
*.tres            ← resource files
*.import          ← import configs
scripts/          ← utility scripts, not game logic
```

---

## Review Focus Areas

Evaluate each `.gd` file across these dimensions, in order of priority:

1. **Architecture**
2. **API Correctness**
3. **Code Safety**
4. **Maintainability**
5. **Performance**

---

## Mandatory Citation Rule

**Every single finding must include a documentation citation.**

For each issue or suggestion you raise, you must:

1. State the finding
2. Reference the exact file and line (e.g. `entities/actors/player/player.gd:42`)
3. Cite the relevant doc page from `docs/godot/` that supports the finding

Use this format for each citation:

```
📄 Doc reference: docs/godot/<path-to-relevant-page>
```

If you cannot find a doc page that supports a finding, **do not include that finding.** A finding without a citation is not permitted.

---

## Output Format

Structure your response as follows:

### 🔴 Critical Issues
_Must fix — bugs, crashes, or serious misuse of the engine_

### 🟡 Recommended Improvements
_Not broken, but will cause problems at scale or hurt maintainability_

### ⚙ Suggested Refactors
_Larger structural changes with clear reasoning_

---

## Example Finding Format

```
**[🔴 Critical] Accessing node before it exists**
File: `entities/actors/player/player.gd:17`
The node is accessed in `_init()` before the scene tree is ready.
Use `_ready()` instead for node access.
📄 Doc reference: docs/godot/tutorials/scripting/gdscript/gdscript_basics.md#ready
```

---

## Hard Constraints

- **Do NOT modify any files.** Analysis and suggestions only.
- **Do NOT rewrite code** unless the user explicitly follows up with "rewrite X".
- **Do NOT make a finding you cannot back with a doc citation.**
- Keep findings actionable — reference the specific file, line, and pattern, not vague generalities.
