extends GutTest
## Pruebas de la máquina de estados de MaskDude: doble salto, dash y bloqueo.

const PlayerScene := preload("res://scenes/player/MaskDude.tscn")
const S := MaskDude.State

var player: MaskDude


func before_each() -> void:
	var piso := StaticBody2D.new()
	var forma := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(4000, 20)
	forma.shape = rect
	piso.add_child(forma)
	piso.position = Vector2(0, 10)   # superficie en y = 0
	add_child_autoqfree(piso)
	player = PlayerScene.instantiate()
	add_child_autoqfree(player)
	player.global_position = Vector2.ZERO
	await wait_physics_frames(6)


func after_each() -> void:
	for accion in ["jump", "double_jump", "dash", "move_left", "move_right"]:
		Input.action_release(accion)


## Pulsa y suelta una acción (o varias) durante `frames` frames de física.
func _tap(acciones: Array, frames := 2) -> void:
	for a in acciones:
		Input.action_press(a)
	await wait_physics_frames(frames)
	for a in acciones:
		Input.action_release(a)


## Salto como lo hace el teclado: Espacio dispara `jump` y `double_jump` a la vez.
func _saltar(frames := 2) -> void:
	await _tap(["jump", "double_jump"], frames)


func _esperar_estado(estado: int, max_frames := 90) -> bool:
	for i in max_frames:
		if player.state == estado:
			return true
		await wait_physics_frames(1)
	return player.state == estado


# ---------------------------------------------------------------- base

func test_empieza_en_idle_sobre_el_suelo() -> void:
	assert_eq(player.state, S.IDLE)
	assert_true(player.is_on_floor())


func test_correr_cambia_a_run_y_vuelve_a_idle() -> void:
	Input.action_press("move_right")
	await wait_physics_frames(15)
	assert_eq(player.state, S.RUN)
	assert_gt(player.velocity.x, 50.0)
	Input.action_release("move_right")
	await wait_physics_frames(30)
	assert_eq(player.state, S.IDLE)


func test_salto_basico_pasa_por_jump_y_fall() -> void:
	var transiciones: Array = []
	player.state_changed.connect(func(viejo, nuevo): transiciones.append([viejo, nuevo]))
	await _saltar()
	assert_eq(player.state, S.JUMP)
	assert_true(await _esperar_estado(S.FALL), "Debe llegar a FALL tras el ápice")
	assert_true(await _esperar_estado(S.IDLE), "Debe volver a IDLE al aterrizar")
	assert_eq(transiciones, [[S.IDLE, S.JUMP], [S.JUMP, S.FALL], [S.FALL, S.IDLE]])


func test_pulsar_doble_salto_en_el_suelo_no_activa_doble_salto() -> void:
	await _tap(["double_jump"])
	assert_ne(player.state, S.DOUBLE_JUMP)
	assert_eq(player.state, S.IDLE)


# ---------------------------------------------------------------- doble salto

func test_doble_salto_en_el_aire() -> void:
	await _saltar()
	await _esperar_estado(S.FALL)
	await _tap(["double_jump"])
	assert_eq(player.state, S.DOUBLE_JUMP)
	assert_lt(player.velocity.y, 0.0, "Debe ir hacia arriba")
	assert_eq(player._air_jumps_left, 0)


func test_solo_un_doble_salto_por_salto() -> void:
	await _saltar()
	await _esperar_estado(S.FALL)
	await _tap(["double_jump"])
	await _esperar_estado(S.FALL)
	var vy_antes := player.velocity.y
	await _tap(["double_jump"], 1)
	assert_ne(player.state, S.DOUBLE_JUMP, "No debe haber un tercer salto")
	assert_gte(player.velocity.y, vy_antes, "No debe recibir otro impulso hacia arriba")


func test_aterrizar_recupera_el_doble_salto() -> void:
	await _saltar()
	await _esperar_estado(S.FALL)
	await _tap(["double_jump"])
	await _esperar_estado(S.IDLE)
	assert_eq(player._air_jumps_left, player.max_air_jumps)


func test_doble_salto_sube_mas_alto_que_el_salto_simple() -> void:
	var alto_simple := 0.0
	await _saltar(40)   # mantener el botón: salto completo
	for i in 60:
		alto_simple = minf(alto_simple, player.global_position.y)
		await wait_physics_frames(1)
	await _esperar_estado(S.IDLE)
	await _saltar(40)
	var alto_doble := 0.0
	await _esperar_estado(S.FALL)
	await _tap(["double_jump"], 25)
	for i in 60:
		alto_doble = minf(alto_doble, player.global_position.y)
		await wait_physics_frames(1)
	assert_lt(alto_doble, alto_simple, "Con doble salto se llega más arriba (y más negativa)")


# ---------------------------------------------------------------- dash

func test_dash_en_el_suelo() -> void:
	Input.action_press("move_right")
	await wait_physics_frames(3)
	await _tap(["dash"], 1)
	assert_eq(player.state, S.DASH)
	await wait_physics_frames(1)   # la velocidad del dash se aplica en el frame siguiente
	assert_almost_eq(player.velocity.x, player.dash_speed, 1.0)


func test_dash_recorre_la_distancia_esperada_y_termina() -> void:
	var x0 := player.global_position.x
	player._facing = 1.0
	await _tap(["dash"], 1)
	await wait_physics_frames(int(player.dash_duration * 60.0) + 4)
	assert_ne(player.state, S.DASH, "El dash debe terminar")
	var recorrido := player.global_position.x - x0
	var esperado := player.dash_speed * player.dash_duration
	assert_between(recorrido, esperado * 0.7, esperado * 1.5, "Distancia del dash (px)")


func test_dash_hacia_la_izquierda() -> void:
	Input.action_press("move_left")
	await wait_physics_frames(2)
	await _tap(["dash"], 1)
	assert_eq(player.state, S.DASH)
	assert_lt(player.velocity.x, 0.0)


func test_dash_tiene_cooldown() -> void:
	await _tap(["dash"], 1)
	await _esperar_estado(S.IDLE)
	await _tap(["dash"], 1)
	assert_ne(player.state, S.DASH, "Dentro del cooldown no se puede repetir")
	await wait_physics_frames(int(player.dash_cooldown * 60.0) + 6)
	await _tap(["dash"], 1)
	assert_eq(player.state, S.DASH, "Pasado el cooldown vuelve a funcionar")


func test_dash_en_el_aire_no_tiene_gravedad() -> void:
	await _saltar()
	await _esperar_estado(S.FALL)
	await _tap(["dash"], 2)
	assert_eq(player.state, S.DASH)
	assert_eq(player.velocity.y, 0.0)


func test_dash_aereo_consume_la_carga_y_se_recupera_al_aterrizar() -> void:
	await _saltar()
	await _esperar_estado(S.FALL)
	await _tap(["dash"], 2)
	assert_eq(player._air_dashes_left, 0)
	await _esperar_estado(S.IDLE, 150)
	assert_eq(player._air_dashes_left, player.max_air_dashes)


func test_sin_cargas_no_hay_dash_en_el_aire() -> void:
	await _saltar()
	await _esperar_estado(S.FALL)
	player._air_dashes_left = 0
	await _tap(["dash"], 2)
	assert_ne(player.state, S.DASH)


func test_dash_termina_en_fall_si_esta_en_el_aire() -> void:
	await _saltar()
	await _esperar_estado(S.FALL)
	await _tap(["dash"], 1)
	await wait_physics_frames(int(player.dash_duration * 60.0) + 2)
	assert_eq(player.state, S.FALL)


# ---------------------------------------------------------------- bloqueo y utilidades

func test_locked_ignora_el_input() -> void:
	player.set_locked(true)
	assert_eq(player.state, S.LOCKED)
	Input.action_press("move_right")
	await _saltar(3)
	await wait_physics_frames(10)
	assert_eq(player.state, S.LOCKED)
	assert_almost_eq(player.velocity.x, 0.0, 1.0)
	assert_true(player.is_on_floor(), "No debe haber saltado")


func test_desbloquear_vuelve_a_idle() -> void:
	player.set_locked(true)
	player.set_locked(false)
	assert_eq(player.state, S.IDLE)


func test_respawn_deja_al_jugador_quieto() -> void:
	player.velocity = Vector2(200, -100)
	player.respawn_at(Vector2(50, -5))
	assert_eq(player.velocity, Vector2.ZERO)
	assert_eq(player.global_position, Vector2(50, -5))


func test_la_etiqueta_de_depuracion_muestra_el_estado() -> void:
	assert_eq(player.state_label.text, "IDLE")
	player.set_locked(true)
	assert_eq(player.state_label.text, "LOCKED")


func test_parametros_por_defecto_son_los_documentados() -> void:
	assert_eq(player.max_air_jumps, 1)
	assert_eq(player.double_jump_velocity, -300.0)
	assert_eq(player.dash_speed, 320.0)
	assert_eq(player.dash_duration, 0.15)
	assert_eq(player.dash_cooldown, 0.35)
	assert_eq(player.max_air_dashes, 1)
