extends Node2D

@export var ore_scene: PackedScene
@export var count := 5
@export_file("*.tscn") var return_scene := "res://scenes/Oasis.tscn"
@export var auto_return := true
@export var return_delay := 0.8

var _remaining := 0


func _ready() -> void:
	var spots: Array[Marker2D] = []
	for child in get_children():
		if child is Marker2D:
			spots.append(child)
	spots.shuffle()
	for i in mini(count, spots.size()):
		var ore := ore_scene.instantiate()
		ore.position = spots[i].position
		ore.collected.connect(_on_ore_collected)
		add_child(ore)
		_remaining += 1


func _on_ore_collected() -> void:
	_remaining -= 1
	if _remaining > 0 or not auto_return:
		return
	await get_tree().create_timer(return_delay).timeout
	GameState.bank_run()
	HavenPlayer.movement_locked = false
	SceneManager.change_scene(return_scene)
