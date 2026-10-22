extends GutTest
## Caja de diálogo: avanzar con Enter/E y saltar con Esc.

const BoxScene := preload("res://scenes/narrative/DialogueBox.tscn")
const LINEAS := [
	{"who": "Mask Dude", "text": "Hola"},
	{"who": "Tótem Dorado", "text": "Adiós"},
]

var caja: DialogueBox


func before_each() -> void:
	caja = BoxScene.instantiate()
	add_child_autoqfree(caja)
	await wait_physics_frames(2)


func _evento(accion: String) -> InputEventAction:
	var e := InputEventAction.new()
	e.action = accion
	e.pressed = true
	return e


func test_empieza_oculta_e_inactiva() -> void:
	assert_false(caja.active)
	assert_false(caja.root.visible)


func test_play_muestra_la_primera_linea_con_nombre_y_retrato() -> void:
	caja.play(LINEAS)
	await wait_physics_frames(2)
	assert_true(caja.active)
	assert_true(caja.root.visible)
	assert_eq(caja.name_label.text, "Mask Dude")
	assert_true(caja.portrait.visible)
	assert_eq(caja.text_label.text, "Hola")


func test_primera_pulsacion_completa_el_texto_y_la_segunda_avanza() -> void:
	caja.play(LINEAS)
	await wait_physics_frames(1)
	assert_true(caja._typing)
	caja._unhandled_input(_evento("interact"))
	assert_false(caja._typing, "La primera pulsación completa el texto")
	assert_true(caja._waiting)
	caja._unhandled_input(_evento("interact"))
	await wait_physics_frames(2)
	assert_eq(caja.name_label.text, "Tótem Dorado")


func test_al_terminar_todas_las_lineas_se_oculta() -> void:
	caja.play(LINEAS)
	await wait_physics_frames(1)
	for i in 4:
		caja._unhandled_input(_evento("interact"))
		await wait_physics_frames(1)
	assert_false(caja.active)
	assert_false(caja.root.visible)


func test_escape_salta_todo_el_dialogo() -> void:
	caja.play(LINEAS)
	await wait_physics_frames(1)
	caja._unhandled_input(_evento("ui_cancel"))
	await wait_physics_frames(2)
	assert_false(caja.active)


func test_narrador_sin_retrato_oculta_el_retrato() -> void:
	caja.play([{"who": "Narrador", "text": "Había una vez..."}])
	await wait_physics_frames(2)
	assert_false(caja.portrait.visible)
