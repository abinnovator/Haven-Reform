extends Node2D

@export var textboxes: Array[Label] = []
var fade_duration: float = 0.5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for box in textboxes:
		box.modulate.a = 0.0
		box.show()
		await _fade(box, 1.0, fade_duration)
		await get_tree().create_timer(1.0).timeout
		await _fade(box, 0.0, fade_duration)
		box.hide()

	var save := Savemanager.load_save()
	save.cutscene_done = true
	Savemanager.update_save(save)
	SceneManager.change_scene("res://scenes/Oasis.tscn")


func _fade(label: Label, target: float, duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(label, "modulate:a", target, duration)
	await tween.finished
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
