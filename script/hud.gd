extends CanvasLayer
## Always-on substance counter, top right. Autoloaded so every gameplay
## scene gets it without being instanced, and it survives scene changes.

const HIDE_IN := ["startscreen.tscn", "cutscene.tscn"]
const FONT_PATH := "res://assets/DarumadropOne-Regular.ttf"

var _box: VBoxContainer
var _banked: Label
var _carried: Label
var _last_scene_path := ""


func _ready() -> void:
	layer = 100
	_build()
	GameState.substance_changed.connect(_refresh)
	_refresh()


func _build() -> void:
	_box = VBoxContainer.new()
	_box.anchor_left = 1.0
	_box.anchor_right = 1.0
	_box.offset_left = -320.0
	_box.offset_right = -18.0
	_box.offset_top = 14.0
	_box.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_box)

	_banked = _make_label(Color(0.60, 0.95, 0.55), 22)
	_carried = _make_label(Color(0.45, 0.95, 0.90), 17)


func _make_label(color: Color, font_size: int) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.08))
	label.add_theme_constant_override("outline_size", 6)
	label.add_theme_font_size_override("font_size", font_size)
	var font := load(FONT_PATH)
	if font != null:
		label.add_theme_font_override("font", font)
	_box.add_child(label)
	return label


func _refresh() -> void:
	_banked.text = "RESTORATION  %d" % GameState.banked_substance
	_carried.text = "carrying  %d" % GameState.carried_substance
	_carried.visible = GameState.carried_substance > 0


## Keep the HUD off the title screen and the cutscene.
func _process(_delta: float) -> void:
	var scene := get_tree().current_scene
	var path := scene.scene_file_path if scene != null else ""
	if path == _last_scene_path:
		return
	_last_scene_path = path
	_box.visible = not (path.get_file() in HIDE_IN)
