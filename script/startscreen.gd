extends Node2D

@export var StartButton: Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	StartButton.pressed.connect(on_button_pressed)


func on_button_pressed():
	var save = Savemanager.load_save()
	if save.cutscene_done:
		SceneManager.change_scene("res://scenes/Oasis.tscn")
	else:
		SceneManager.change_scene("res://scenes/cutscene.tscn")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
