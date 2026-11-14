extends Node2D
## Attach to the root of a cave scene. Counts the ore in the level and
## sends you home the moment the last one is picked up.

@export_file("*.tscn") var return_scene := "res://scenes/Oasis.tscn"
@export var auto_return := true
@export var return_delay := 0.9

var _remaining := 0


func _ready() -> void:
	for ore in _find_ores(self):
		_remaining += 1
		ore.collected.connect(_on_ore_collected)


func _find_ores(node: Node) -> Array:
	var found: Array = []
	for child in node.get_children():
		if child is HavenOre:
			found.append(child)
		found.append_array(_find_ores(child))
	return found


func _on_ore_collected() -> void:
	_remaining -= 1
	if _remaining > 0 or not auto_return:
		return
	await get_tree().create_timer(return_delay).timeout
	GameState.bank_run()
	HavenPlayer.movement_locked = false
	SceneManager.change_scene(return_scene)
