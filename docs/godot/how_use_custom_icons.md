## Recommendation

Attach a script to the scene’s root node and give that script a custom icon using the `@icon` annotation.

Workflow:

- **Prepare the icon resource**
  - Import an SVG icon into your project (e.g. `res://icons/my_scene_icon.svg`).
  - In the Import dock for that SVG, enable:
	- **Editor > Scale with Editor Scale**
	- **Editor > Convert Colors with Editor Theme**
  - Click **Reimport**.
  - New SVGs you add will use these options when they’re imported.

- **Set the script’s custom icon**
  - At the very top of the script attached to your scene’s root node, before the class definition, add:

	```gdscript
	@icon("res://icons/my_scene_icon.svg")
	class_name MyScene
	```

- **Use the script on the scene’s root**
  - Ensure this script is attached to the scene’s root node so that, in the Scene dock, that node (and any nodes of that script’s class) shows the custom icon.

## Why

The Godot docs specify that **custom icons are applied at the script level** via the `@icon` annotation. The icon defined there is what appears in the Scene dock for every node of that class. For project-level icons used in the editor, the docs recommend enabling **Scale with Editor Scale** and **Convert Colors with Editor Theme** on SVGs so they look correct on hiDPI displays and in different editor themes.

## Citation

`classes/class_@gdscript.rst`

> “Add a custom icon to the current script. The icon specified at `icon_path` is displayed in the Scene dock for every node of that class, as well as in various editor dialogs.”  
> “**Note:** Only the script can have a custom icon. Inner classes are not supported.”  
> “**Note:** As annotations describe their subject, the `@icon` annotation must be placed before the class definition and inheritance.”  
> “**Note:** Unlike most other annotations, the argument of the `@icon` annotation must be a string literal (constant expressions are not supported).”

`engine_details/editor/creating_icons.rst`

> “For custom icons that are present in projects (as opposed to the engine source code), there are two import options you should enable:”  
> “To ensure the icon is rendered at a correct scale on hiDPI displays, select the SVG file in the FileSystem dock, enable the **Editor > Scale with Editor Scale** option in the Import dock and click Reimport.”  
> “To ensure the icon has its colors converted when the user is using a light theme, select the SVG file in the FileSystem dock, enable the **Editor > Convert Colors with Editor Theme** option in the Import dock and click Reimport.”
