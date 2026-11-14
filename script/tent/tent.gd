@tool
class_name HavenTent
extends StaticBody2D

const HOUSE_WIDTH := 96
const HOUSE_HEIGHT := 96

@export_category("House")
## Which house off the Houses.png sheet this instance uses.
@export_enum("Teal", "Green", "Yellow", "Red", "Pink", "White", "Navy") var house_variant := 0:
	set(value):
		house_variant = value
		_apply_variant()

@export var interior_scene: PackedScene
@export var prompt_text := "E  Enter house"

@onready var prompt: Label = $EnterPrompt
@onready var entrance_area: Area2D = $EntranceArea

var _player_at_entrance := false


func _ready() -> void:
	_apply_variant()
	if Engine.is_editor_hint():
		return
	prompt.text = prompt_text
	prompt.hide()
	entrance_area.body_entered.connect(_on_entrance_area_body_entered)
	entrance_area.body_exited.connect(_on_entrance_area_body_exited)


func _apply_variant() -> void:
	var sprite := get_node_or_null("HouseSprite") as Sprite2D
	if sprite == null:
		return
	sprite.region_rect = Rect2(house_variant * HOUSE_WIDTH, 0, HOUSE_WIDTH, HOUSE_HEIGHT)


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if _player_at_entrance and Input.is_action_just_pressed("interact"):
		_enter_interior()


func _enter_interior() -> void:
	if interior_scene == null:
		push_warning("House '%s' has no Interior Scene assigned." % name)
		return
	get_tree().change_scene_to_packed(interior_scene)


func _on_entrance_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not (body is HavenNPC):
		_player_at_entrance = true
		prompt.show()


func _on_entrance_area_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and not (body is HavenNPC):
		_player_at_entrance = false
		prompt.hide()
