class_name HavenMonster
extends CharacterBody2D

const SHEETS: Array[String] = [
	"res://assets/CozyValley_Premium_1.3/Monsters/Slime.png",
	"res://assets/CozyValley_Premium_1.3/Monsters/Slime_blue.png",
	"res://assets/CozyValley_Premium_1.3/Monsters/Skeleton.png",
	"res://assets/CozyValley_Premium_1.3/Monsters/Skeleton_withered.png",
	"res://assets/CozyValley_Premium_1.3/Monsters/Rat.png",
	"res://assets/CozyValley_Premium_1.3/Monsters/Rat_king.png",
]

@export_category("Identity")
@export_enum("Slime", "Slime blue", "Skeleton", "Skeleton withered", "Rat", "Rat king") var monster_kind := 0:
	set(value):
		monster_kind = value
		if is_node_ready():
			_apply_kind()

@export_category("Movement")
@export_range(10.0, 200.0, 1.0, "suffix:px/s") var speed := 42.0
@export_range(0.0, 600.0, 4.0, "suffix:px") var roam_radius := 120.0
@export_range(0.0, 6.0, 0.1, "suffix:s") var wait_time := 1.0

@export_category("Hazard")
@export_range(0.0, 1.0, 0.01) var steal_fraction := 0.34
@export_range(0.2, 6.0, 0.1, "suffix:s") var hit_cooldown := 1.6

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _home := Vector2.ZERO
var _target := Vector2.ZERO
var _has_target := false
var _wait_remaining := 0.0
var _cooldown := 0.0

func _ready() -> void:
	_home = global_position
	_apply_kind()
	collision_layer = 4
	collision_mask = 1
	var hurtbox := get_node_or_null("Hurtbox") as Area2D
	if hurtbox != null:
		hurtbox.collision_layer = 0
		hurtbox.collision_mask = 3
		hurtbox.body_entered.connect(_on_hurtbox_body_entered)

func _physics_process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)
	_roam(delta)
	_animate()
	if velocity != Vector2.ZERO:
		move_and_slide()

func _roam(delta: float) -> void:
	if _wait_remaining > 0.0:
		_wait_remaining -= delta
		velocity = Vector2.ZERO
		return
	if not _has_target:
		_target = _home + Vector2.from_angle(randf() * TAU) * sqrt(randf()) * roam_radius
		_has_target = true
	if global_position.distance_to(_target) < 4.0:
		_has_target = false
		_wait_remaining = wait_time
		velocity = Vector2.ZERO
		return
	velocity = global_position.direction_to(_target) * speed

func _animate() -> void:
	if velocity.length_squared() < 1.0:
		sprite.play(&"idle")
		return
	if absf(velocity.x) > absf(velocity.y):
		sprite.flip_h = velocity.x < 0.0
		sprite.play(&"move_side")
	else:
		sprite.flip_h = false
		sprite.play(&"move_front" if velocity.y > 0.0 else &"move_back")

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if _cooldown > 0.0 or not (body is HavenPlayer):
		return
	_cooldown = hit_cooldown
	var lost := GameState.drop_carried(steal_fraction)
	_flash()
	if lost > 0:
		_show_loss(lost, body as Node2D)

func _flash() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1.0, 0.5, 0.5), 0.08)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.25)

func _show_loss(amount: int, who: Node2D) -> void:
	var label := Label.new()
	label.text = "-%d REO" % amount
	label.z_index = 50
	label.add_theme_color_override("font_color", Color(1.0, 0.55, 0.5))
	label.add_theme_color_override("font_outline_color", Color(0.1, 0.05, 0.05))
	label.add_theme_constant_override("outline_size", 5)
	label.add_theme_font_size_override("font_size", 14)
	var font := load("res://assets/DarumadropOne-Regular.ttf")
	if font != null:
		label.add_theme_font_override("font", font)
	who.add_child(label)
	label.position = Vector2(-10, -18)
	var tween := label.create_tween()
	tween.tween_property(label, "position:y", -46.0, 0.9)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.9)
	tween.tween_callback(label.queue_free)

func _apply_kind() -> void:
	var texture := load(SHEETS[clampi(monster_kind, 0, SHEETS.size() - 1)]) as Texture2D
	if texture == null:
		return
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	_add(frames, &"idle", [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)], false)
	_add(frames, &"move_back", [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3)], true)
	_add(frames, &"move_front", [Vector2i(0, 4), Vector2i(1, 4), Vector2i(2, 4)], true)
	_add(frames, &"move_side", [Vector2i(0, 5), Vector2i(1, 5), Vector2i(2, 5)], true)
	sprite.sprite_frames = frames
	for anim in frames.get_animation_names():
		for i in frames.get_frame_count(anim):
			(frames.get_frame_texture(anim, i) as AtlasTexture).atlas = texture
	sprite.play(&"idle")

func _add(frames: SpriteFrames, anim: StringName, cells: Array, loops: bool) -> void:
	frames.add_animation(anim)
	frames.set_animation_speed(anim, 6.0)
	frames.set_animation_loop(anim, true)
	for cell in cells:
		var atlas := AtlasTexture.new()
		atlas.region = Rect2(cell.x * 32, cell.y * 32, 32, 32)
		frames.add_frame(anim, atlas)
