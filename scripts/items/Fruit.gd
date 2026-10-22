class_name Fruit
extends Area2D
## Fruta coleccionable. Reproduce "idle" en bucle y "collected" al recogerla.
## Para cambiar de fruta basta con asignar otro SpriteFrames (Items/*.tres).

signal collected

@export var frames: SpriteFrames

var _taken := false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	add_to_group("fruit")
	if frames:
		sprite.sprite_frames = frames
	sprite.play("idle")
	# Fase aleatoria para que las frutas no se muevan todas sincronizadas.
	sprite.frame = randi() % sprite.sprite_frames.get_frame_count("idle")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _taken or not body is MaskDude:
		return
	_taken = true
	$CollisionShape2D.set_deferred("disabled", true)
	collected.emit()
	sprite.play("collected")
	# Sin "await": si el nivel se reinicia a mitad de la animación no queda nada pendiente.
	sprite.animation_finished.connect(queue_free, CONNECT_ONE_SHOT)
