class_name HavenTent
extends StaticBody2D

@export_category("Tent")
@export var tent_tilemap: TileMapLayer

@export var interior_scene: PackedScene
@export var prompt_text := "E  Enter tent"

@onready var prompt: Label = $EnterPrompt

var _player_at_entrance := false

func _ready() -> void:
	prompt.text = prompt_text
	prompt.hide()


func _physics_process(_delta: float) -> void:
	if _player_at_entrance and Input.is_action_just_pressed("interact"):
		_enter_interior()


func _enter_interior() -> void:
	if interior_scene == null:
		push_warning("Tent '%s' has no Interior Scene assigned." % name)
		return
	get_tree().change_scene_to_packed(interior_scene)


func _on_entrance_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_player_at_entrance = true
		prompt.show()


func _on_entrance_area_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		_player_at_entrance = false
		prompt.hide()
