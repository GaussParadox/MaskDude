# Reporte de pruebas unitarias

- Framework: **GUT 9.5.0**
- Motor: **Godot 4.5-stable** (headless)
- Fecha de ejecución: **2026-10-20**
- Resultado: **61 pruebas, 0 fallos**

Comando: `godot --headless -s addons/gut/gut_cmdln.gd -gconfig=res://test/gut_config.json`

| Archivo | Pruebas | Fallos |
|---|---|---|
| `test/unit/test_dialogue_box.gd` | 6 | 0 |
| `test/unit/test_fruit.gd` | 5 | 0 |
| `test/unit/test_input_map.gd` | 5 | 0 |
| `test/unit/test_mask_dude.gd` | 21 | 0 |
| `test/unit/test_project_structure.gd` | 8 | 0 |
| `test/unit/test_story.gd` | 8 | 0 |
| `test/unit/test_zz_level1.gd` | 8 | 0 |

## Detalle

### test/unit/test_dialogue_box.gd
- ✅ `test_empieza_oculta_e_inactiva`
- ✅ `test_play_muestra_la_primera_linea_con_nombre_y_retrato`
- ✅ `test_primera_pulsacion_completa_el_texto_y_la_segunda_avanza`
- ✅ `test_al_terminar_todas_las_lineas_se_oculta`
- ✅ `test_escape_salta_todo_el_dialogo`
- ✅ `test_narrador_sin_retrato_oculta_el_retrato`

### test/unit/test_fruit.gd
- ✅ `test_cada_fruta_tiene_animacion_idle_en_bucle_de_17_frames`
- ✅ `test_cada_fruta_tiene_animacion_collected_sin_bucle`
- ✅ `test_la_fruta_reproduce_idle_al_aparecer`
- ✅ `test_recoger_emite_la_senal_una_sola_vez`
- ✅ `test_otros_cuerpos_no_recogen_la_fruta`

### test/unit/test_input_map.gd
- ✅ `test_existen_todas_las_acciones`
- ✅ `test_cada_accion_tiene_al_menos_un_evento`
- ✅ `test_doble_salto_comparte_teclas_de_salto`
- ✅ `test_dash_en_shift_y_k`
- ✅ `test_enter_ya_no_reinicia_el_nivel`

### test/unit/test_mask_dude.gd
- ✅ `test_empieza_en_idle_sobre_el_suelo`
- ✅ `test_correr_cambia_a_run_y_vuelve_a_idle`
- ✅ `test_salto_basico_pasa_por_jump_y_fall`
- ✅ `test_pulsar_doble_salto_en_el_suelo_no_activa_doble_salto`
- ✅ `test_doble_salto_en_el_aire`
- ✅ `test_solo_un_doble_salto_por_salto`
- ✅ `test_aterrizar_recupera_el_doble_salto`
- ✅ `test_doble_salto_sube_mas_alto_que_el_salto_simple`
- ✅ `test_dash_en_el_suelo`
- ✅ `test_dash_recorre_la_distancia_esperada_y_termina`
- ✅ `test_dash_hacia_la_izquierda`
- ✅ `test_dash_tiene_cooldown`
- ✅ `test_dash_en_el_aire_no_tiene_gravedad`
- ✅ `test_dash_aereo_consume_la_carga_y_se_recupera_al_aterrizar`
- ✅ `test_sin_cargas_no_hay_dash_en_el_aire`
- ✅ `test_dash_termina_en_fall_si_esta_en_el_aire`
- ✅ `test_locked_ignora_el_input`
- ✅ `test_desbloquear_vuelve_a_idle`
- ✅ `test_respawn_deja_al_jugador_quieto`
- ✅ `test_la_etiqueta_de_depuracion_muestra_el_estado`
- ✅ `test_parametros_por_defecto_son_los_documentados`

### test/unit/test_project_structure.gd
- ✅ `test_archivos_de_la_raiz`
- ✅ `test_carpetas_requeridas`
- ✅ `test_gitignore_excluye_cache_y_credenciales`
- ✅ `test_no_hay_credenciales_de_exportacion`
- ✅ `test_framework_de_pruebas_declara_version`
- ✅ `test_cada_carpeta_de_assets_tiene_licencias`
- ✅ `test_escena_principal_existe`
- ✅ `test_readme_contiene_secciones_obligatorias`

### test/unit/test_story.gd
- ✅ `test_intro_tiene_titulo_tarjetas_y_dialogo`
- ✅ `test_todas_las_lineas_tienen_quien_y_texto`
- ✅ `test_todos_los_personajes_tienen_retrato`
- ✅ `test_final_con_todas_las_frutas`
- ✅ `test_final_parcial_menciona_cantidad`
- ✅ `test_final_sin_frutas`
- ✅ `test_los_tres_finales_son_distintos`
- ✅ `test_consejos_de_los_dos_movimientos_nuevos`

### test/unit/test_zz_level1.gd
- ✅ `test_tiene_13_frutas`
- ✅ `test_hay_punto_de_inicio_y_meta`
- ✅ `test_limites_de_camara_son_el_tamano_del_nivel`
- ✅ `test_zonas_de_narrativa_apuntan_a_textos_existentes`
- ✅ `test_recoger_una_fruta_actualiza_el_contador`
- ✅ `test_llegar_a_la_meta_emite_level_completed_una_vez`
- ✅ `test_caer_fuera_del_escenario_reaparece_en_el_inicio`
- ✅ `test_el_nivel_largo_anterior_sigue_disponible`
