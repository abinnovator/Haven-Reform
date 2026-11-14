class_name HavenOre
extends Area2D

signal collected
## A node of restoration substance. Walk into it to pick it up.

@export var substance_value := 10

var _collected := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _collected or not (body is HavenPlayer):
		return
	_collected = true
	GameState.add_carried(substance_value)
	collected.emit()
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.7, 1.7), 0.14)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.14)
	tween.tween_callback(queue_free)
