extends GutTest
## (El nombre empieza por "test_zz_" para que GUT lo ejecute AL FINAL: en Godot 4.5 headless liberar
## el nivel dentro de GUT cierra el proceso si aún quedan pruebas por correr.)
## Nivel 1: frutas, meta, caída, límites de cámara y zonas de narrativa.
##
## Se usa UNA sola instancia del nivel para todo el archivo (before_all): crear y liberar
## varias copias seguidas del nivel dentro de GUT cierra Godot 4.5 en modo headless.
## Por eso cada prueba es independiente del orden y no depende del estado de las demás.

const LevelScene := preload("res://scenes/levels/Level1.tscn")

var level


func before_all() -> void:
	level = LevelScene.instantiate()
	add_child(level)


func after_all() -> void:
	# Se saca del árbol antes de liberarlo (liberarlo dentro del árbol cierra Godot en headless).
	remove_child(level)
	level.queue_free()


func before_each() -> void:
	await wait_physics_frames(3)


func test_tiene_13_frutas() -> void:
	assert_eq(level.fruit_total, 13)
	assert_eq(get_tree().get_nodes_in_group("fruit").size() + level.fruit_collected, 13)


func test_hay_punto_de_inicio_y_meta() -> void:
	assert_true(level.get_node_or_null("SpawnPoint") != null, "Falta SpawnPoint")
	assert_true(level.get_node_or_null("Goal") != null, "Falta Goal")
	assert_eq(level.spawn_point.global_position, Vector2(64, 155))


func test_limites_de_camara_son_el_tamano_del_nivel() -> void:
	var cam: Camera2D = level.player.camera
	assert_eq(cam.limit_left, 0)
	assert_eq(cam.limit_top, 0)
	assert_eq(cam.limit_right, 512)
	assert_eq(cam.limit_bottom, 288)


func test_zonas_de_narrativa_apuntan_a_textos_existentes() -> void:
	var zonas := get_tree().get_nodes_in_group("story_trigger")
	assert_eq(zonas.size(), 3)
	for z in zonas:
		var id: String = z.story_id
		assert_true(Story.HINTS.has(id) or Story.DIALOGUES.has(id), "Zona sin texto: '%s'" % id)


func test_recoger_una_fruta_actualiza_el_contador() -> void:
	watch_signals(level)
	var antes: int = level.fruit_collected
	var fruta: Fruit = get_tree().get_nodes_in_group("fruit")[0]
	fruta._on_body_entered(level.player)
	assert_eq(level.fruit_collected, antes + 1)
	assert_signal_emitted_with_parameters(level, "fruits_changed", [antes + 1, 13])


func test_llegar_a_la_meta_emite_level_completed_una_vez() -> void:
	watch_signals(level)
	level._finished = false
	level._on_goal_body_entered(level.player)
	level._on_goal_body_entered(level.player)
	assert_signal_emit_count(level, "level_completed", 1)


func test_caer_fuera_del_escenario_reaparece_en_el_inicio() -> void:
	watch_signals(level)
	level.player.global_position = Vector2(200, 400)
	await wait_physics_frames(3)
	assert_signal_emitted(level, "player_fell")
	assert_eq(level.player.global_position.round(), level.spawn_point.global_position.round())


func test_el_nivel_largo_anterior_sigue_disponible() -> void:
	var escena: PackedScene = load("res://scenes/levels/Level_Large.tscn")
	assert_not_null(escena)
	var nivel_largo = escena.instantiate()   # sin entrar al árbol: solo se comprueba su configuración
	assert_eq(nivel_largo.level_size_tiles, Vector2i(112, 18))
	nivel_largo.free()
