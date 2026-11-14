
class_name HavenPlayer
extends CharacterBody2D

## Set by NPCs/dialogue to freeze the player in place.
static var movement_locked := false

@export var speed: float = 180.0

@onready var sprite = $AnimatedSprite2D

## Scene whose spawn comes from the save file instead of a SpawnPoint marker.
const HUB_SCENE_FILE := "Oasis.tscn"


func _ready() -> void:
	movement_locked = false
	_apply_spawn()


## Topmost ancestor below the SceneTree root. Safer than current_scene,
## which isn't set yet while a scene is still being added.
func _scene_root() -> Node:
	var node: Node = self
	while node.get_parent() != null and node.get_parent() != get_tree().root:
		node = node.get_parent()
	return node


func _apply_spawn() -> void:
	var root := _scene_root()
	if root == null:
		return

	if root.scene_file_path.get_file() == HUB_SCENE_FILE:
		var save: SaveData = Savemanager.load_save()
		if save != null:
			global_position = save.last_position
		return

	var spawn := root.find_child("SpawnPoint", true, false) as Marker2D
	if spawn != null:
		global_position = spawn.global_position
	else:
		push_warning("No SpawnPoint in '%s'; player stays where it was placed." % root.name)


func _physics_process(_delta: float) -> void:
	if movement_locked:
		velocity = Vector2.ZERO
		sprite.play("idle")
		move_and_slide()
		return


	var direction := Input.get_vector(
		"left",
		"right",
		"front",
		"back"
	)

	velocity = direction * speed

	if direction.length() > 0:
		if direction.x > 0:
			sprite.play("move_right")
			sprite.flip_h = false

		elif direction.x < 0:
			sprite.play("move_left")
			sprite.flip_h = true

		elif direction.y > 0:
			sprite.play("move_back")

		elif direction.y < 0:
			sprite.play("move_front")



	move_and_slide()
