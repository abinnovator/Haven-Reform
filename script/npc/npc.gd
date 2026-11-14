class_name HavenNPC
extends CharacterBody2D


enum MovementState { IDLE, ROAM, PATROL }

const CHARACTER_TEXTURES: Array[String] = [
	"res://assets/CozyValley_Premium_1.3/Characters/-- Pre-assembled Characters/char1.png",
	"res://assets/CozyValley_Premium_1.3/Characters/-- Pre-assembled Characters/char3.png",
	"res://assets/CozyValley_Premium_1.3/Characters/-- Pre-assembled Characters/char4.png",
	"res://assets/CozyValley_Premium_1.3/Characters/-- Pre-assembled Characters/char5.png",
	"res://assets/CozyValley_Premium_1.3/Characters/-- Pre-assembled Characters/char6.png",
	"res://assets/CozyValley_Premium_1.3/Characters/-- Pre-assembled Characters/char7.png",
	"res://assets/CozyValley_Premium_1.3/Characters/-- Pre-assembled Characters/char8.png",
	"res://assets/CozyValley_Premium_1.3/Characters/-- Pre-assembled Characters/char9.png",
]

@export_category("Identity")
@export var character_name := "Mike"
@export_enum("Mike (char1)", "Jessie (char3)", "Riley (char4)", "Nora (char5)", "Theo (char6)", "Maya (char7)", "Finn (char8)", "Iris (char9)") var character_preset := 0:
	set(value):
		character_preset = value
		if is_node_ready():
			_apply_character_preset()

@export_multiline var dialogue_text := "Welcome to HAVEN-REFORM."

@export_category("Movement")
@export var movement_state: MovementState = MovementState.IDLE
@export_range(1.0, 400.0, 1.0, "suffix:px/s") var speed := 60.0
@export_range(0.0, 1000.0, 1.0, "suffix:px") var roam_radius := 96.0
@export_range(0.0, 10.0, 0.1, "suffix:s") var wait_time := 1.5
## Each point is an offset from where this NPC was placed in the map.
@export var patrol_points: Array[Vector2] = []

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dialogue_label: Label = $DialogueLabel
@onready var interaction_area: Area2D = $InteractionArea

var _home_position := Vector2.ZERO
var _target_position := Vector2.ZERO
var _has_roam_target := false
var _patrol_index := 0
var _wait_remaining := 0.0
var _player_in_range := false
var _dialogue_visible := false

func _ready() -> void:
	_home_position = global_position
	_apply_character_preset()
	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	dialogue_label.text = "%s: %s" % [character_name, dialogue_text]
	dialogue_label.hide()


func _physics_process(delta: float) -> void:
	if _player_in_range and Input.is_action_just_pressed("interact"):
		_dialogue_visible = not _dialogue_visible
		dialogue_label.visible = _dialogue_visible
		HavenPlayer.movement_locked = _dialogue_visible

	match movement_state:
		MovementState.IDLE:
			velocity = Vector2.ZERO
		MovementState.ROAM:
			_move_roam(delta)
		MovementState.PATROL:
			_move_patrol(delta)

	_update_animation()
	# only move when actually moving: a standing NPC that calls
	# move_and_slide() every frame gets shoved around by anything that
	# walks into it, whatever the collision layers say.
	if velocity != Vector2.ZERO:
		move_and_slide()


func _move_roam(delta: float) -> void:
	if _wait_remaining > 0.0:
		_wait_remaining -= delta
		velocity = Vector2.ZERO
		return
	if not _has_roam_target:
		_target_position = _home_position + Vector2.from_angle(randf() * TAU) * sqrt(randf()) * roam_radius
		_has_roam_target = true
	if global_position.distance_to(_target_position) < 3.0:
		_has_roam_target = false
		_wait_remaining = wait_time
		velocity = Vector2.ZERO
		return
	velocity = global_position.direction_to(_target_position) * speed


func _move_patrol(delta: float) -> void:
	if patrol_points.is_empty():
		velocity = Vector2.ZERO
		return
	if _wait_remaining > 0.0:
		_wait_remaining -= delta
		velocity = Vector2.ZERO
		return
	var target := _home_position + patrol_points[_patrol_index]
	if global_position.distance_to(target) < 3.0:
		global_position = target
		_patrol_index = (_patrol_index + 1) % patrol_points.size()
		_wait_remaining = wait_time
		velocity = Vector2.ZERO
		return
	velocity = global_position.direction_to(target) * speed


func _update_animation() -> void:
	if velocity.length_squared() < 1.0:
		sprite.play(&"idle")
		return
	if absf(velocity.x) > absf(velocity.y):
		sprite.play(&"move_right")
		sprite.flip_h = velocity.x < 0.0
	else:
		sprite.flip_h = false
		sprite.play(&"move_back" if velocity.y > 0.0 else &"move_front")


func _apply_character_preset() -> void:
	var texture := load(CHARACTER_TEXTURES[clampi(character_preset, 0, CHARACTER_TEXTURES.size() - 1)]) as Texture2D
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	_add_animation(frames, &"idle", [Vector2i(0, 2)])
	_add_animation(frames, &"move_back", [Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5), Vector2i(1, 2)])
	_add_animation(frames, &"move_front", [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(1, 0)])
	_add_animation(frames, &"move_right", [Vector2i(1, 4), Vector2i(2, 4), Vector2i(0, 4), Vector2i(1, 1)])
	sprite.sprite_frames = frames
	sprite.play(&"idle")
	# Keep the texture alive through the AtlasTextures made below.
	for animation_name in frames.get_animation_names():
		for frame in frames.get_frame_count(animation_name):
			(frames.get_frame_texture(animation_name, frame) as AtlasTexture).atlas = texture


func _add_animation(frames: SpriteFrames, animation_name: StringName, cells: Array[Vector2i]) -> void:
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, 5.0)
	frames.set_animation_loop(animation_name, animation_name != &"idle")
	for cell in cells:
		var atlas := AtlasTexture.new()
		atlas.region = Rect2(cell.x * 32, cell.y * 32, 32, 32)
		frames.add_frame(animation_name, atlas)


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not (body is HavenNPC):
		_player_in_range = true


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and not (body is HavenNPC):
		_player_in_range = false
		_dialogue_visible = false
		dialogue_label.hide()
		HavenPlayer.movement_locked = false
