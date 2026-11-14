extends Camera2D

@export_category("Camera Bounds")
@export var left := -500
@export var top := 0
@export var right := 1280
@export var bottom := 1200

func _ready() -> void:
	limit_left = left
	limit_top = top
	limit_right = right
	limit_bottom = bottom
	zoom = Vector2(4,4);
	reset_smoothing()
