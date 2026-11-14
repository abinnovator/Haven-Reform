class_name RestorationPatch
extends Area2D


@export_category("Patch")
@export var patch_id := "patch_small"
@export var cost := 20

@export_category("Visuals")
@export var dead_visual: Node2D
@export var alive_visual: Node2D

var prompt: Label

var _player_near := false


func _ready() -> void:
	# The player lives on layer 2; detect it whichever layer it ends up on.
	collision_layer = 0
	collision_mask = 3
	_ensure_prompt()
	prompt.hide()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_disable_layer_collision(dead_visual)
	_disable_layer_collision(alive_visual)
	_apply_state(GameState.is_restored(patch_id), false)


## Build the prompt label if the scene doesn't carry one, and centre it
## above whatever area this patch covers.
func _ensure_prompt() -> void:
	prompt = get_node_or_null("Prompt") as Label
	if prompt != null:
		return
	prompt = Label.new()
	prompt.name = "Prompt"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prompt.add_theme_color_override("font_outline_color", Color(0.08, 0.08, 0.1))
	prompt.add_theme_constant_override("outline_size", 5)
	prompt.add_theme_font_size_override("font_size", 15)
	add_child(prompt)

	var centre := Vector2.ZERO
	var shape_node := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node != null:
		centre = shape_node.position
	prompt.size = Vector2(240.0, 24.0)
	prompt.position = Vector2(centre.x - 120.0, centre.y - 12.0)


func _physics_process(_delta: float) -> void:
	if _player_near and Input.is_action_just_pressed("interact"):
		_try_restore()


func _try_restore() -> void:
	if GameState.is_restored(patch_id):
		return
	if not GameState.spend(cost):
		prompt.text = "Need %d REO" % cost
		prompt.add_theme_color_override("font_color", Color(1, 0.55, 0.45))
		return
	GameState.restore_patch(patch_id)
	_apply_state(true, true)
	prompt.hide()


## A hidden TileMapLayer still collides, so an invisible "alive" layer
## becomes a wall sitting on the patch. Patches are walkable either way.
func _disable_layer_collision(node: Node2D) -> void:
	if node is TileMapLayer:
		(node as TileMapLayer).collision_enabled = false


func _apply_state(restored: bool, animate: bool) -> void:
	if alive_visual != null:
		alive_visual.visible = restored
		if restored and animate:
			alive_visual.modulate.a = 0.0
			var fade_in := create_tween()
			fade_in.tween_property(alive_visual, "modulate:a", 1.0, 0.9)

	if dead_visual == null:
		return
	if not restored:
		dead_visual.visible = true
		dead_visual.modulate.a = 1.0
		return
	if not animate:
		dead_visual.visible = false
		return
	# Dissolve the dead tiles away so the green underneath comes through.
	var fade_out := create_tween()
	fade_out.tween_property(dead_visual, "modulate:a", 0.0, 0.9)
	fade_out.tween_callback(func() -> void: dead_visual.visible = false)


func _update_prompt() -> void:
	if GameState.banked_substance >= cost:
		prompt.text = "E  Restore  (%d REO)" % cost
		prompt.add_theme_color_override("font_color", Color(0.65, 1.0, 0.65))
	else:
		prompt.text = "Need %d REO" % cost
		prompt.add_theme_color_override("font_color", Color(1, 0.55, 0.45))


func _on_body_entered(body: Node2D) -> void:
	if not (body is HavenPlayer) or GameState.is_restored(patch_id):
		return
	_player_near = true
	_update_prompt()
	prompt.show()


func _on_body_exited(body: Node2D) -> void:
	if body is HavenPlayer:
		_player_near = false
		prompt.hide()
