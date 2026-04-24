@tool
extends EditorPlugin

## Ubuntu-only .ase → per-layer SpriteFrames auto-importer.
## Requires: inotify-tools  (sudo apt install inotify-tools)
##
## Source:  ASE_DIR/*.ase
## Output:  OUTPUT_DIR/<name>_<layer>.png  +  OUTPUT_DIR/<name>_<layer>.tres
##
## ase_watch.py exports PNGs + writes .tres files, then signals this plugin over
## a local TCP socket. The plugin scans the filesystem (so Godot imports the new
## PNGs) and hot-reloads the updated SpriteFrames resources.

const ASE_DIR := "res://assets/aseprites/"
const OUTPUT_DIR := "res://assets/images/dynamic/"
const PORT := 9876

var _watcher_pid := -1
var _server := TCPServer.new()
var _peers: Array[StreamPeerTCP] = []
var _reload_queue: PackedStringArray = []
var _scan_pending := false


func _enter_tree() -> void:
	_make_dir(ASE_DIR)
	_make_dir(OUTPUT_DIR)

	var err := _server.listen(PORT, "127.0.0.1")
	if err != OK:
		printerr(
			"[ase] Port %d unavailable (error %d) — is another instance running?" % [PORT, err]
		)
		return
	print("[ase] Listening on 127.0.0.1:%d" % PORT)
	set_process(true)

	get_editor_interface().get_resource_filesystem().connect(
		"filesystem_changed", _on_filesystem_changed
	)

	var binary := ProjectSettings.globalize_path(
		get_script().resource_path.get_base_dir() + "/ase_watch/ase_watch"
	)
	var watch_abs := ProjectSettings.globalize_path(ASE_DIR)
	var output_abs := ProjectSettings.globalize_path(OUTPUT_DIR)

	_watcher_pid = OS.create_process(binary, [watch_abs, output_abs, str(PORT)])
	if _watcher_pid == -1:
		printerr("[ase] Failed to start watcher binary")
		return
	print("[ase] Watcher started (pid %d)" % _watcher_pid)


func _exit_tree() -> void:
	set_process(false)
	get_editor_interface().get_resource_filesystem().disconnect(
		"filesystem_changed", _on_filesystem_changed
	)
	_server.stop()
	if _watcher_pid != -1:
		OS.kill(_watcher_pid)
		_watcher_pid = -1


# ── Socket listener ───────────────────────────────────────────────────────────


func _process(_delta: float) -> void:
	while _server.is_connection_available():
		_peers.append(_server.take_connection())

	var done: Array[StreamPeerTCP] = []
	for peer in _peers:
		peer.poll()
		if peer.get_available_bytes() > 0:
			var msg := peer.get_utf8_string(peer.get_available_bytes())
			var parts := msg.strip_edges().split(":")
			match parts[0]:
				"new_uid":
					var new_id := ResourceUID.create_id()
					peer.put_utf8_string(ResourceUID.id_to_text(new_id) + "\n")
					# Don't close — Python closes after reading, status becomes NONE naturally
				"scan_and_reload":
					for key in parts.slice(1):
						if key not in _reload_queue:
							_reload_queue.append(key)
					if not _scan_pending:
						_scan_pending = true
						get_editor_interface().get_resource_filesystem().scan()
					done.append(peer)
				_:
					done.append(peer)
		elif peer.get_status() in [StreamPeerTCP.STATUS_NONE, StreamPeerTCP.STATUS_ERROR]:
			done.append(peer)
	for peer in done:
		_peers.erase(peer)


# ── Filesystem signal ─────────────────────────────────────────────────────────


func _on_filesystem_changed() -> void:
	if not _scan_pending:
		return
	_scan_pending = false
	if not _reload_queue.is_empty():
		_do_reload(_reload_queue)
		_reload_queue.clear()


# ── Reload ────────────────────────────────────────────────────────────────────


func _do_reload(keys: PackedStringArray) -> void:
	var prev_nodes := get_editor_interface().get_selection().get_selected_nodes()
	for key in keys:
		var tres_path := OUTPUT_DIR + key + ".tres"
		var res := ResourceLoader.load(tres_path, "", ResourceLoader.CACHE_MODE_REPLACE_DEEP)
		if not res:
			printerr("[ase] Failed to load: ", tres_path)
			continue
		res.emit_changed()
		get_editor_interface().edit_resource(res)
		print("[ase] Reloaded ", tres_path)
	if not prev_nodes.is_empty():
		_restore_selection.call_deferred(prev_nodes)


func _restore_selection(nodes: Array) -> void:
	var sel := get_editor_interface().get_selection()
	sel.clear()
	for n in nodes:
		if is_instance_valid(n):
			sel.add_node(n)


# ── Helpers ───────────────────────────────────────────────────────────────────


func _make_dir(res_path: String) -> void:
	var abs := ProjectSettings.globalize_path(res_path)
	if not DirAccess.dir_exists_absolute(abs):
		DirAccess.make_dir_recursive_absolute(abs)
