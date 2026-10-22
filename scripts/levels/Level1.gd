extends Node2D
## Gestiona reaparición, checkpoints, frutas, meta y límites de cámara de un nivel.

signal level_completed
signal player_fell
signal fruits_changed(collected: int, total: int)

const TILE := 16
const KILL_MARGIN := 48.0   ## píxeles por debajo del nivel antes de reaparecer

## Tamaño del nivel en tiles (se usa para los límites de cámara y la zona de caída).
@export var level_size_tiles := Vector2i(112, 18)

@onready var player: MaskDude = $MaskDude
@onready var spawn_point: Marker2D = $SpawnPoint
@onready var goal: Area2D = $Goal

var fruit_total := 0
var fruit_collected := 0
var _respawn_position: Vector2
var _finished := false


func _ready() -> void:
	_respawn_position = spawn_point.global_position
	player.set_camera_limits(Rect2i(Vector2i.ZERO, level_size_tiles * TILE))
	player.respawn_at(_respawn_position)
	goal.body_entered.connect(_on_goal_body_entered)
	for checkpoint in get_tree().get_nodes_in_group("checkpoint"):
		checkpoint.body_entered.connect(_on_checkpoint_body_entered.bind(checkpoint))
	for fruit in get_tree().get_nodes_in_group("fruit"):
		fruit_total += 1
		fruit.collected.connect(_on_fruit_collected)


func _physics_process(_delta: float) -> void:
	# Si el jugador cae fuera del escenario, vuelve al último punto seguro.
	if player.global_position.y > level_size_tiles.y * TILE + KILL_MARGIN:
		player.respawn_at(_respawn_position)
		player_fell.emit()


func _on_fruit_collected() -> void:
	fruit_collected += 1
	fruits_changed.emit(fruit_collected, fruit_total)


func _on_checkpoint_body_entered(body: Node2D, checkpoint: Node2D) -> void:
	if body == player:
		_respawn_position = checkpoint.global_position


func _on_goal_body_entered(body: Node2D) -> void:
	if body == player and not _finished:
		_finished = true
		level_completed.emit()
