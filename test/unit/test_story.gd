extends GutTest
## Pruebas de los textos de la narrativa (scripts/narrative/Story.gd).


func test_intro_tiene_titulo_tarjetas_y_dialogo() -> void:
	assert_ne(Story.TITLE, "", "El título no debe estar vacío")
	assert_eq(Story.INTRO_CARDS.size(), 3, "La cinemática inicial tiene 3 tarjetas")
	assert_gt(Story.INTRO_DIALOGUE.size(), 0, "Debe haber diálogo de introducción")


func test_todas_las_lineas_tienen_quien_y_texto() -> void:
	var todas: Array = []
	todas.append_array(Story.INTRO_DIALOGUE)
	for lines: Array in Story.DIALOGUES.values():
		todas.append_array(lines)
	for total_frutas in [0, 5, 13]:
		todas.append_array(Story.ending_lines(total_frutas, 13))
	for line: Dictionary in todas:
		assert_true(line.has("who") and line.has("text"), "Línea incompleta: %s" % str(line))
		assert_ne(String(line["text"]).strip_edges(), "", "Texto vacío")


func test_todos_los_personajes_tienen_retrato() -> void:
	var todas: Array = []
	todas.append_array(Story.INTRO_DIALOGUE)
	for lines: Array in Story.DIALOGUES.values():
		todas.append_array(lines)
	for n in [0, 5, 13]:
		todas.append_array(Story.ending_lines(n, 13))
	for line: Dictionary in todas:
		assert_true(DialogueBox.PORTRAITS.has(line["who"]), "Sin retrato para '%s'" % line["who"])


func test_final_con_todas_las_frutas() -> void:
	var lines := Story.ending_lines(13, 13)
	assert_eq(lines.size(), 3)
	assert_string_contains(lines[0]["text"], "completa")
	assert_string_contains(Story.epilogue(13, 13), "a salvo")


func test_final_parcial_menciona_cantidad() -> void:
	var lines := Story.ending_lines(4, 13)
	assert_string_contains(lines[0]["text"], "4 de 13")
	assert_string_contains(Story.epilogue(4, 13), "escasa")


func test_final_sin_frutas() -> void:
	var lines := Story.ending_lines(0, 13)
	assert_string_contains(lines[0]["text"], "manos vacías")
	assert_string_contains(Story.epilogue(0, 13), "oscura")


func test_los_tres_finales_son_distintos() -> void:
	var a := str(Story.ending_lines(13, 13))
	var b := str(Story.ending_lines(5, 13))
	var c := str(Story.ending_lines(0, 13))
	assert_ne(a, b)
	assert_ne(b, c)
	assert_ne(a, c)


func test_consejos_de_los_dos_movimientos_nuevos() -> void:
	assert_true(Story.HINTS.has("hint_double_jump"))
	assert_true(Story.HINTS.has("hint_dash"))
	assert_string_contains(Story.HINTS["hint_dash"].to_lower(), "dash")
	assert_string_contains(Story.HINTS["hint_double_jump"].to_lower(), "doble salto")
