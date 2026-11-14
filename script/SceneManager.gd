extends Node


static var instance: SceneManager

var _is_loading := false


func _enter_tree() -> void:
	instance = self


func change_scene(path: String) -> void:
	if _is_loading:
		return
	_is_loading = true

	var err := ResourceLoader.load_threaded_request(path)
	if err != OK:
		_is_loading = false
		return

	var progress := PackedInt32Array()
	while true:
		var status := ResourceLoader.load_threaded_get_status(path, progress)

		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if progress.size() > 0:
				pass
			await get_tree().process_frame
			continue

		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var scene: PackedScene = (ResourceLoader.load_threaded_get(path) as PackedScene)
			get_tree().change_scene_to_packed(scene)
		else:
			printerr("Failed to load %s: %s" % [path, status])
		break

	await get_tree().process_frame
	_is_loading = false
