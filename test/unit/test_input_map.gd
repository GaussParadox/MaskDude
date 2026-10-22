extends GutTest
## El Input Map debe tener cada acción requerida (incluidos doble salto y dash).

const ACCIONES := ["move_left", "move_right", "jump", "double_jump", "dash",
	"interact", "restart", "mute", "debug_state"]


func _teclas(accion: String) -> Array:
	var out: Array = []
	for ev in InputMap.action_get_events(accion):
		if ev is InputEventKey:
			out.append(ev.physical_keycode)
	return out


func test_existen_todas_las_acciones() -> void:
	for accion in ACCIONES:
		assert_true(InputMap.has_action(accion), "Falta la acción '%s'" % accion)


func test_cada_accion_tiene_al_menos_un_evento() -> void:
	for accion in ACCIONES:
		assert_gt(InputMap.action_get_events(accion).size(), 0, "'%s' sin teclas" % accion)


func test_doble_salto_comparte_teclas_de_salto() -> void:
	assert_true(KEY_SPACE in _teclas("double_jump"))
	assert_true(KEY_SPACE in _teclas("jump"))


func test_dash_en_shift_y_k() -> void:
	var teclas := _teclas("dash")
	assert_true(KEY_SHIFT in teclas, "dash debe incluir Shift")
	assert_true(KEY_K in teclas, "dash debe incluir K")


func test_enter_ya_no_reinicia_el_nivel() -> void:
	assert_false(KEY_ENTER in _teclas("restart"), "Enter es de 'interact', no de 'restart'")
	assert_true(KEY_ENTER in _teclas("interact"))
