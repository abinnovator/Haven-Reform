extends Node2D
## Put this on a portal. ENTER sends you to the cave, RETURN brings you
## home and banks everything you are carrying.

enum PortalMode {
	ENTER,  ## HAVEN -> cave
	RETURN, ## cave -> HAVEN, banks carried REO
}

@export var mode: PortalMode = PortalMode.ENTER
@export_file("*.tscn") var target_scene := ""
@export var prompt_text := "E  Step through"

var _area: Area2D
var _prompt: Label
var _player: HavenPlayer = null
var _player_near := false


func _ready() -> void:
	_area = get_node_or_null("Area2D") as Area2D
	if _area == null:
		push_warning("Portal '%s' has no Area2D child." % name)
		return
	# the player sits on layer 2; watch 1 and 2 so it works either way
	_area.collision_layer = 0
	_area.collision_mask = 3
	_area.body_entered.connect(_on_body_entered)
	_area.body_exited.connect(_on_body_exited)
	_build_prompt()


func _build_prompt() -> void:
	_prompt = Label.new()
	_prompt.name = "Prompt"
	_prompt.text = prompt_text
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_prompt.add_theme_color_override("font_outline_color", Color(0.08, 0.08, 0.1))
	_prompt.add_theme_constant_override("outline_size", 5)
	_prompt.add_theme_font_size_override("font_size", 15)
	add_child(_prompt)

	var centre := Vector2(18, 19)
	var top := -8.0
	var shape_node := _area.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node != null and shape_node.shape is RectangleShape2D:
		centre = shape_node.position
		top = centre.y - (shape_node.shape as RectangleShape2D).size.y * 0.5
	_prompt.size = Vector2(220.0, 24.0)
	_prompt.position = Vector2(centre.x - 110.0, top - 30.0)
	_prompt.hide()


func _physics_process(_delta: float) -> void:
	if _player_near and Input.is_action_just_pressed("interact"):
		_use()


func _use() -> void:
	if target_scene.is_empty():
		push_warning("Portal '%s' has no Target Scene set." % name)
		return
	if mode == PortalMode.RETURN:
		GameState.bank_run()
	else:
		_remember_hub_position()
	HavenPlayer.movement_locked = false
	SceneManager.change_scene(target_scene)


## Leaving HAVEN records where you stood, so the trip back drops you here.
func _remember_hub_position() -> void:
	if _player == null:
		return
	var save: SaveData = Savemanager.load_save()
	if save == null:
		return
	save.last_position = _player.global_position
	Savemanager.update_save(save)


func _on_body_entered(body: Node2D) -> void:
	if body is HavenPlayer:
		_player = body
		_player_near = true
		_prompt.show()


func _on_body_exited(body: Node2D) -> void:
	if body is HavenPlayer:
		_player_near = false
		_prompt.hide()
