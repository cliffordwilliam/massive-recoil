## Recommendation

To force the SpriteFrames dock to visually refresh after programmatically saving a `.tres` from a plugin, call `EditorInterface.edit_resource(resource)` after `emit_changed()`, then restore the previous node selection on the next frame so the inspector doesn't get hijacked:

```gdscript
var refreshed := ResourceLoader.load(tres_path, "", ResourceLoader.CACHE_MODE_REPLACE_DEEP)
if refreshed:
    refreshed.emit_changed()
    var prev_nodes := get_editor_interface().get_selection().get_selected_nodes()
    get_editor_interface().edit_resource(refreshed)
    if not prev_nodes.is_empty():
        _restore_selection.call_deferred(prev_nodes)

func _restore_selection(nodes: Array) -> void:
    var sel := get_editor_interface().get_selection()
    sel.clear()
    for n in nodes:
        if is_instance_valid(n):
            sel.add_node(n)
```

## Why

The SpriteFrames dock connects its redraw signal to a specific resource object in memory. Calling `emit_changed()` alone is not enough — the dock only re-renders when it is programmatically "focused" via `edit_resource()`, which is the equivalent of the user clicking on the resource in the inspector.

Without the selection restore, `edit_resource()` steals inspector focus away from whatever node the user had selected. Saving the selection and restoring it with `call_deferred` fixes this: the dock gets its refresh trigger on the current frame, and the inspector snaps back to the previous node on the next frame.

`CACHE_MODE_REPLACE_DEEP` is required so the freshly saved `.tres` is loaded from disk rather than returning the stale in-memory version.

## Context

This is a known Godot limitation tracked in [godotengine/godot#24646](https://github.com/godotengine/godot/issues/24646). There is no first-class API to refresh the SpriteFrames dock directly. The `edit_resource` + deferred selection restore pattern was found to be the most reliable workaround without requiring a full project reload or manual user interaction.
