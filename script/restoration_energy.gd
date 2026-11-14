extends CanvasLayer


const HIDE_IN := ["startscreen.tscn", "cutscene.tscn"]

@export var label: Label

@onready var panel: Control = $Panel

var _last_scene_path := ""


func _ready() -> void:
	GameState.substance_changed.connect(_refresh)
	_refresh()


func _refresh() -> void:
	label.text = "%d REO" % (GameState.banked_substance + GameState.carried_substance)


func _process(_delta: float) -> void:
	var scene := get_tree().current_scene
	var path := scene.scene_file_path if scene != null else ""
	if path == _last_scene_path:
		return
	_last_scene_path = path
	panel.visible = not (path.get_file() in HIDE_IN)
