
extends CharacterBody2D

@export var speed: float = 180.0

@onready var sprite = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:

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
