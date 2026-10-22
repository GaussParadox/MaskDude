class_name StoryTrigger
extends Area2D
## Zona invisible que dispara un texto de la narrativa (clave en Story.gd) al entrar el jugador.

signal triggered(story_id: String)

@export var story_id := ""
@export var one_shot := true


func _ready() -> void:
	add_to_group("story_trigger")
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is MaskDude:
		triggered.emit(story_id)
		if one_shot:
			set_deferred("monitoring", false)
