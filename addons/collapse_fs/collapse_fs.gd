@tool
extends EditorPlugin

func _unhandled_key_input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_C and event.ctrl_pressed and event.shift_pressed:
			_collapse_all()
			get_viewport().set_input_as_handled()

func _collapse_all():
	var dock = EditorInterface.get_file_system_dock()
	var trees = dock.find_children("*", "Tree", true, false)
	for tree in trees:
		var root: TreeItem = tree.get_root()
		if root and root.get_text(0) == "":
			var top_item = root.get_first_child()
			while top_item:
				var child = top_item.get_first_child()
				while child:
					child.set_collapsed_recursive(true)
					child = child.get_next()
				top_item.collapsed = false
				top_item = top_item.get_next()
