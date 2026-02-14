@tool
extends EditorScript

## Batch-converts spritesheets into Godot SpriteFrames resources.
##
## Usage: Open this script in the editor, press Ctrl+Shift+X (or File > Run).
##
## Expected setup:
##   Place each spritesheet export (JSON + PNG) in SPRITES_DIR below.
##   For every <n>.json, there must be a matching <n>.png.
##   Running this script generates/overwrites <n>.tres for each pair.
##
## Expected JSON shape:
##   {
##     "frames": [
##       {
##         "filename": "idle-0",
##         "frame": { "x": 0, "y": 0, "w": 64, "h": 64 },
##         "duration": 83
##       },
##       ...
##     ],
##     "meta": {
##       "frameTags": [
##         { "name": "idle", "from": 0, "to": 11, "direction": "forward" },
##         { "name": "stop", "from": 32, "to": 35, "direction": "forward", "repeat": "1" }
##       ]
##     }
##   }
##
## Filename parsing:
##   - Last dash splits name/index  ("idle-0" -> anim "idle", frame 0)
##
## Loop detection (from frameTags):
##   - No "repeat" field  -> loops (default)
##   - "repeat" present   -> does not loop
##
## Duration math:
##   base_fps   = 1000.0 / shortest_frame_duration_ms
##   multiplier = frame_duration_ms / shortest_frame_duration_ms
##
const SPRITES_DIR := "res://assets/sprites/"

func _run():
	var dir = DirAccess.open(SPRITES_DIR)
	if not dir:
		printerr("Could not open directory: ", SPRITES_DIR)
		return

	var json_files: Array[String] = []
	var err = dir.list_dir_begin()
	if err != OK:
		printerr("Could not list directory: ", SPRITES_DIR)
		return
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			json_files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()

	if json_files.is_empty():
		print("No .json files found in ", SPRITES_DIR)
		return

	var success_count := 0
	for json_file in json_files:
		var base_name = json_file.get_basename()
		var json_path = SPRITES_DIR + json_file
		var png_path = SPRITES_DIR + base_name + ".png"
		var tres_path = SPRITES_DIR + base_name + ".tres"

		if not FileAccess.file_exists(png_path):
			printerr("Skipping ", json_file, ": no matching ", base_name, ".png found")
			continue

		print("Processing: ", base_name)
		if _import_spritesheet(json_path, png_path, tres_path):
			success_count += 1

	print("Done. Generated ", success_count, "/", json_files.size(), " .tres files.")
	EditorInterface.get_resource_filesystem().scan()


func _import_spritesheet(json_path: String, png_path: String, tres_path: String) -> bool:
	# 1. Parse JSON
	var file = FileAccess.open(json_path, FileAccess.READ)
	if not file:
		printerr("  Could not open: ", json_path)
		return false
	var json_string = file.get_as_text()

	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		printerr("  JSON parse error: ", json.get_error_message(), " at line ", json.get_error_line())
		return false
	var data = json.data

	# 2. Load spritesheet
	var spritesheet: Texture2D = ResourceLoader.load(png_path, "", ResourceLoader.CACHE_MODE_REPLACE)
	if not spritesheet:
		printerr("  Could not load: ", png_path)
		return false

	# 3. Validate frames is an Array
	var frames_array = data["frames"]
	if not frames_array is Array:
		printerr("  Expected \"frames\" to be an Array in: ", json_path)
		return false

	# 4. Build loop lookup from frameTags
	#    No "repeat" field -> loops (default Aseprite behavior)
	#    "repeat" present  -> one-shot (no loop)
	var loop_lookup := {}
	if data.has("meta") and data["meta"].has("frameTags"):
		for tag in data["meta"]["frameTags"]:
			loop_lookup[tag["name"]] = not tag.has("repeat")

	# 5. Group frames by animation name
	var anims := {}
	for frame_data in frames_array:
		var filename: String = frame_data["filename"]

		var dash_pos := filename.rfind("-")
		if dash_pos == -1:
			printerr("  Skipping frame with unexpected name format: ", filename)
			continue
		var anim_name := filename.substr(0, dash_pos)
		var frame_index := filename.substr(dash_pos + 1).to_int()
		var rect = frame_data["frame"]

		if not anims.has(anim_name):
			anims[anim_name] = []

		anims[anim_name].append({
			"index": frame_index,
			"x": rect["x"],
			"y": rect["y"],
			"w": rect["w"],
			"h": rect["h"],
			"duration_ms": frame_data["duration"],
		})

	for anim_name in anims:
		anims[anim_name].sort_custom(func(a, b): return a["index"] < b["index"])

	# 6. Build SpriteFrames
	var sprite_frames = SpriteFrames.new()

	if sprite_frames.has_animation(&"default"):
		sprite_frames.remove_animation(&"default")

	for anim_name in anims:
		var frames: Array = anims[anim_name]

		var min_duration_ms := 999999.0
		for f in frames:
			if f["duration_ms"] < min_duration_ms:
				min_duration_ms = f["duration_ms"]

		var base_fps := 1000.0 / min_duration_ms
		var should_loop: bool = loop_lookup.get(anim_name, true)

		sprite_frames.add_animation(anim_name)
		sprite_frames.set_animation_speed(anim_name, base_fps)
		sprite_frames.set_animation_loop(anim_name, should_loop)

		for f in frames:
			var atlas := AtlasTexture.new()
			atlas.atlas = spritesheet
			atlas.region = Rect2(f["x"], f["y"], f["w"], f["h"])

			var multiplier := float(f["duration_ms"]) / min_duration_ms
			sprite_frames.add_frame(anim_name, atlas, multiplier)

		var loop_label := "loop" if should_loop else "once"
		print("  ", anim_name, ": ", frames.size(), " frames @ ", snapped(base_fps, 0.01), " fps [", loop_label, "]")

	# 7. Save
	var result = ResourceSaver.save(sprite_frames, tres_path, ResourceSaver.FLAG_REPLACE_SUBRESOURCE_PATHS)
	if result == OK:
		# Refresh any existing cached instance from disk
		var refreshed = ResourceLoader.load(tres_path, "", ResourceLoader.CACHE_MODE_REPLACE_DEEP)
		if refreshed:
			refreshed.emit_changed()
		print("  Saved: ", tres_path)
		return true
	else:
		printerr("  Failed to save, error code: ", result)
		return false
