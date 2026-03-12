## Recommendation

Use **resources as shared data containers**, saved as `.tres`/`.res` or embedded in scenes, and access them via `load()`/`preload()` and exported properties:

- **Model data as `Resource` types instead of ad‑hoc files**: create custom scripts that `extends Resource` (optionally with `class_name`) and expose fields with `@export` so they can be edited in the Inspector and saved as `.tres` files.
- **Prefer external resources for reusable data** (saved as separate `.tres`/`.res` files) and built‑in resources only when the data is tightly coupled to a single scene. Toggle between them by editing the resource’s `path` property in the Inspector and saving the scene.
- **Load resources in code with `load()` or `preload()`**:
  - Use `load("res://path.tres")` when you need to load at runtime (e.g. dynamic paths).
  - Use `preload("res://path.tres")` when the path is known at compile‑time and you want the resource loaded ahead of time.
- **Attach resources via exported properties** on Nodes:
  - In a `Resource` script: `@export var health: int`, etc.
  - In a Node script: `@export var stats: Resource` and assign a `.tres` instance from the Inspector.
- **Rely on Godot’s reference counting and auto‑freeing**: don’t manually manage memory for typical `Resource` use; freeing a Node usually frees its contained resources when nothing else references them.

## Why

Resources are designed as **data containers** that the engine **loads once and shares across all users**, avoiding duplication and keeping memory efficient. They support **auto‑serialization, reference counting, custom methods, signals, and nested sub‑resources**, giving much stronger structure and tooling than formats like JSON/CSV. The docs emphasize using the Inspector to create and edit custom `Resource` types, saving them as `.tres` (version‑control‑friendly) while Godot exports them as `.res` binaries for performance. They also highlight that scenes are just `PackedScene` resources, loaded via `load()`/`preload()` and instantiated with `PackedScene.instantiate()`, and that freeing Nodes typically frees unused Resources automatically.

## Citation

`tutorials/scripting/resources.rst`

> “There is another datatype that is just as important: :ref:`Resource <class_Resource>`.  
> *Nodes* give you functionality… **Resources are **data containers**. They don't do anything on their own: instead, nodes use the data contained in resources.”  

> “When the engine loads a resource from disk, **it only loads it once**. If a copy of that resource is already in memory, trying to load the resource again will return the same copy every time. As resources only contain data, there is no need to duplicate them.”  

> “There are two ways to save resources. They can be:  
> 1. **External** to a scene, saved on the disk as individual files.  
> 2. **Built-in**, saved inside the `.tscn` or the `.scn` file they're attached to. … If you erase the path `\"res://robi.png\"` and save, Godot will save the image inside the `.tscn` scene file.”  

> “There are two ways to load resources from code. First, you can use the `load()` function anytime:  
> … `var imported_resource = load("res://robi.png")` …  
> You can also `preload` resources. Unlike `load`, this function will read the file from disk and load it at compile-time.”  

> “When a :ref:`Resource <class_Resource>` is no longer in use, it will automatically free itself. Since, in most cases, Resources are contained in Nodes, when you free a node, the engine frees all the resources it owns as well if no other node uses them.”  

> “Resource scripts inherit the ability to freely translate between object properties and serialized text or binary data (\*.tres, \*.res). They also inherit the reference-counting memory management from the RefCounted type. … Resource auto-serialization and deserialization is a built-in Godot Engine feature. … Resources can even serialize sub-Resources recursively… Users can save Resources as version-control-friendly text files (\*.tres). Upon exporting a game, Godot serializes resource files as binary files (\*.res) for increased speed and compression. … Godot Engine's Inspector renders and edits Resource files out-of-the-box. … To do so, double-click the resource file in the FileSystem dock or click the folder icon in the Inspector and open the file in the dialog.”  

> “Godot makes it easy to create custom Resources in the Inspector.  
> 1. Create a new Resource object in the Inspector. …  
> 2. Set the `script` property in the Inspector to be your script.  
> …  
> ```  
> class_name BotStats  
> extends Resource  
>  
> @export var health: int  
> @export var sub_resource: Resource  
> @export var strings: PackedStringArray  
> …  
> ```  

> “Now, create a :ref:`CharacterBody3D <class_CharacterBody3D>`, name it `Bot`, and add the following script to it:  
> ```  
> extends CharacterBody3D  
>  
> @export var stats: Resource  
>  
> func _ready():  
>     # Uses an implicit, duck-typed interface for any 'health'-compatible resources.  
>     if stats:  
>         stats.health = 10  
>         print(stats.health)  
>         # Prints "10"  
> ```”
