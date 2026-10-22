class_name MaskDude
extends CharacterBody2D
## Jugador "Mask Dude" con máquina de estados explícita.
##
## Estados:  IDLE, RUN, JUMP, FALL, DOUBLE_JUMP, DASH, LOCKED
## Acciones del Input Map: move_left, move_right, jump, double_jump, dash
## (LOCKED se usa durante diálogos y cinemáticas: el jugador no recibe input).
## El diagrama completo está en docs/MaskDude_Estados.md.

signal state_changed(old_state: State, new_state: State)

enum State { IDLE, RUN, JUMP, FALL, DOUBLE_JUMP, DASH, LOCKED }

@export_group("Movimiento")
@export var max_speed := 140.0
@export var acceleration := 1100.0
@export var friction := 1400.0
@export var air_control := 0.8   ## 1.0 = mismo control que en el suelo

@export_group("Salto")
@export var jump_velocity := -330.0
@export var gravity := 950.0
@export var fall_gravity_multiplier := 1.4  ## cae más rápido de lo que sube
@export var jump_cut_multiplier := 0.45     ## soltar el botón corta el salto
@export var max_fall_speed := 420.0
@export var coyote_time := 0.1              ## margen para saltar justo al salir de una plataforma
@export var jump_buffer_time := 0.1         ## margen para pulsar salto justo antes de aterrizar

@export_group("Doble salto")
@export var max_air_jumps := 1              ## saltos extra en el aire (se recuperan al tocar suelo)
@export var double_jump_velocity := -300.0
@export var ground_near_distance := 8.0     ## cerca del suelo, el botón cuenta como salto normal "en cola"

@export_group("Dash")
@export var dash_speed := 320.0
@export var dash_duration := 0.15           ## segundos que dura el impulso
@export var dash_cooldown := 0.35           ## segundos hasta poder volver a usarlo
@export var max_air_dashes := 1             ## dashes en el aire (se recuperan al tocar suelo)
@export var ghost_interval := 0.035         ## separación de las imágenes residuales

var state: State = State.IDLE
var _air_jumps_left := 0
var _air_dashes_left := 0
var _coyote_timer := 0.0
var _jump_buffer_timer := 0.0
var _dash_time_left := 0.0
var _dash_cooldown_left := 0.0
var _ghost_timer := 0.0
var _dash_dir := 1.0
var _dash_on_floor := false
var _facing := 1.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D
@onready var jump_sound: AudioStreamPlayer = $JumpSound
@onready var dash_sound: AudioStreamPlayer = $DashSound
@onready var state_label: Label = $StateLabel


func _ready() -> void:
	_air_jumps_left = max_air_jumps
	_air_dashes_left = max_air_dashes
	_refresh_debug_label()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_state"):
		state_label.visible = not state_label.visible


func _physics_process(delta: float) -> void:
	_dash_cooldown_left -= delta
	match state:
		State.LOCKED:
			_process_locked(delta)
		State.DASH:
			_process_dash(delta)
		_:
			_process_free(delta)
	move_and_slide()
	_resolve_state()
	_update_animation()


# ------------------------------------------------------------ procesos por estado

func _process_free(delta: float) -> void:
	_apply_gravity(delta)
	_handle_jump(delta)
	_handle_dash_input()
	if state == State.DASH:
		return
	_handle_horizontal(delta)


func _process_locked(delta: float) -> void:
	_apply_gravity(delta)
	velocity.x = move_toward(velocity.x, 0.0, friction * delta)


func _process_dash(delta: float) -> void:
	_dash_time_left -= delta
	# Sin gravedad mientras dura; si empezó en el suelo, una pizca hacia abajo mantiene el contacto.
	velocity = Vector2(_dash_dir * dash_speed, 20.0 if _dash_on_floor else 0.0)
	_ghost_timer -= delta
	if _ghost_timer <= 0.0:
		_ghost_timer = ghost_interval
		_spawn_ghost()
	if _dash_time_left <= 0.0:
		_end_dash()


# ------------------------------------------------------------ movimiento

func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return
	var g := gravity
	if velocity.y > 0.0:
		g *= fall_gravity_multiplier
	velocity.y = minf(velocity.y + g * delta, max_fall_speed)


func _handle_jump(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer -= delta

	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer -= delta

	if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
		# Salto normal (desde el suelo o dentro del margen "coyote").
		velocity.y = jump_velocity
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
		_play_jump_sound(1.0)
		_set_state(State.JUMP)
	elif Input.is_action_just_pressed("double_jump") and _can_double_jump():
		# Doble salto: un impulso extra en el aire.
		velocity.y = double_jump_velocity
		_air_jumps_left -= 1
		_jump_buffer_timer = 0.0
		_play_jump_sound(1.35)
		_set_state(State.DOUBLE_JUMP)

	# Salto variable: soltar el botón mientras sube reduce la altura.
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier


func _can_double_jump() -> bool:
	return not is_on_floor() and _coyote_timer <= 0.0 and _air_jumps_left > 0 \
		and not _ground_is_near()


## Si el suelo está a punto de tocarse, la pulsación se deja como salto normal en cola.
func _ground_is_near() -> bool:
	return velocity.y >= 0.0 and test_move(global_transform, Vector2(0.0, ground_near_distance))


func _handle_horizontal(delta: float) -> void:
	var dir := Input.get_axis("move_left", "move_right")
	var control := 1.0 if is_on_floor() else air_control
	if dir != 0.0:
		velocity.x = move_toward(velocity.x, dir * max_speed, acceleration * control * delta)
		_facing = signf(dir)
		sprite.flip_h = dir < 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * control * delta)


# ------------------------------------------------------------ dash

func _handle_dash_input() -> void:
	if not Input.is_action_just_pressed("dash") or _dash_cooldown_left > 0.0:
		return
	_dash_on_floor = is_on_floor()
	if not _dash_on_floor:
		if _air_dashes_left <= 0:
			return
		_air_dashes_left -= 1
	var dir := Input.get_axis("move_left", "move_right")
	_dash_dir = signf(dir) if dir != 0.0 else _facing
	_facing = _dash_dir
	sprite.flip_h = _dash_dir < 0.0
	_dash_time_left = dash_duration
	_ghost_timer = 0.0
	dash_sound.play()
	_set_state(State.DASH)


func _end_dash() -> void:
	velocity.x = _dash_dir * max_speed          # conserva algo de inercia
	_dash_cooldown_left = dash_cooldown
	_set_state(State.IDLE)                       # _resolve_state() lo corrige este mismo frame


func _spawn_ghost() -> void:
	var tex := sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	var ghost := Sprite2D.new()
	ghost.texture = tex
	ghost.flip_h = sprite.flip_h
	ghost.global_position = sprite.global_position
	ghost.modulate = Color(1.0, 1.0, 1.0, 0.55)
	get_parent().add_child(ghost)
	get_parent().move_child(ghost, get_index())   # detrás del jugador
	var tween := ghost.create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.25)
	tween.tween_callback(ghost.queue_free)


# ------------------------------------------------------------ estados

## Decide el estado después de mover (suelo / aire / caída).
func _resolve_state() -> void:
	if state == State.LOCKED:
		return
	if state == State.DASH:
		if is_on_wall():
			_end_dash()
		else:
			return
	if is_on_floor():
		_air_jumps_left = max_air_jumps
		_air_dashes_left = max_air_dashes
		_set_state(State.RUN if absf(velocity.x) > 10.0 else State.IDLE)
	elif velocity.y < 0.0:
		if state != State.DOUBLE_JUMP:
			_set_state(State.JUMP)
	else:
		_set_state(State.FALL)


func _set_state(new_state: State) -> void:
	if new_state == state:
		return
	var old := state
	state = new_state
	_refresh_debug_label()
	state_changed.emit(old, new_state)


func _refresh_debug_label() -> void:
	if state_label:
		state_label.text = State.keys()[state]


func _update_animation() -> void:
	sprite.speed_scale = 1.0
	match state:
		State.JUMP:
			sprite.play("jump")
		State.DOUBLE_JUMP:
			sprite.play("double_jump")
		State.FALL:
			sprite.play("fall")
		State.RUN:
			sprite.play("run")
		State.DASH:
			sprite.play("run")
			sprite.speed_scale = 2.0
		_:
			sprite.play("idle")


func _play_jump_sound(pitch: float) -> void:
	jump_sound.pitch_scale = pitch
	jump_sound.play()


# ------------------------------------------------------------ API pública

## Bloquea / desbloquea el control (diálogos y cinemáticas).
func set_locked(locked: bool) -> void:
	if locked:
		_set_state(State.LOCKED)
	elif state == State.LOCKED:
		_set_state(State.IDLE)


## Coloca al jugador en una posición y lo deja quieto (usado al reaparecer).
func respawn_at(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0
	_dash_time_left = 0.0
	if state == State.DASH:
		_set_state(State.IDLE)
	camera.reset_smoothing()


## Define los límites de la cámara en píxeles (izquierda, arriba, derecha, abajo).
func set_camera_limits(rect: Rect2i) -> void:
	camera.limit_left = rect.position.x
	camera.limit_top = rect.position.y
	camera.limit_right = rect.end.x
	camera.limit_bottom = rect.end.y
