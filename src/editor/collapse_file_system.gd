@tool
class_name CollapseFileSystem
extends EditorScript
## Editor utility script that collapses all folders in the FileSystem dock.
##
## This script traverses the internal [Tree] nodes used by the editor's
## [FileSystemDock] and recursively collapses all nested folders while keeping
## the top-level directories expanded.
##
## It is designed to be executed as an [EditorScript], allowing developers to
## quickly reset the expanded state of the FileSystem panel when working with
## large projects.
##
## When executed, the script:
## 1. Locates the editor's FileSystem dock.
## 2. Finds all internal [Tree] nodes used to render the filesystem.
## 3. Recursively collapses all nested items.
## 4. Keeps only the top-level directories expanded for easy navigation.
##
## This is useful when the project tree becomes deeply expanded during
## development and needs to be quickly reset.


## Entry point executed when the [EditorScript] runs.
##
## Calls [_collapse_all] to collapse the project tree in the editor.
func _run() -> void:
	_collapse_all()


## Collapses all nested directories in the FileSystem dock.
##
## The function searches the FileSystem dock for internal [Tree] nodes,
## retrieves their root [TreeItem], and recursively collapses all child
## items beneath each top-level directory.
##
## Top-level directories remain expanded so the project structure
## remains visible at the first level.
func _collapse_all() -> void:
	var dock: FileSystemDock = EditorInterface.get_file_system_dock()
	var trees: Array[Node] = dock.find_children("*", "Tree", true, false)

	for tree: Node in trees:
		var root: TreeItem = tree.get_root()

		# The root item of the filesystem tree has an empty label.
		if root and root.get_text(0) == "":
			var top_item: TreeItem = root.get_first_child()

			# Iterate over each top-level directory.
			while top_item:
				var child: TreeItem = top_item.get_first_child()

				# Collapse all nested items recursively.
				while child:
					child.set_collapsed_recursive(true)
					child = child.get_next()

				# Keep the top-level directory expanded.
				top_item.collapsed = false
				top_item = top_item.get_next()
