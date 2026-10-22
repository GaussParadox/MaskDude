# test/

Pruebas unitarias automatizadas con **GUT 9.5.0** (ver `addons/README.md`) y sus reportes.

```
test/
├── gut_config.json        configuración de GUT (carpeta de pruebas y salida del reporte)
├── unit/                  pruebas (test_*.gd)
└── reports/               gut_results.xml (JUnit) y REPORTE_PRUEBAS.md (resumen legible)
```

## Ejecutar

Desde la carpeta del proyecto (la primera vez, abre el proyecto una vez en el editor o ejecuta `godot --headless --import`):

```
godot --headless -s addons/gut/gut_cmdln.gd -gconfig=res://test/gut_config.json
```

También desde el editor: panel **GUT** (abajo) > *Run All*.

## Qué se prueba (61 pruebas, 259 aserciones)

| Archivo | Pruebas | Cubre |
|---|---|---|
| `test_mask_dude.gd` | 21 | Máquina de estados: correr, salto, **doble salto** (uno por salto, se recupera al aterrizar), **dash** (distancia, cooldown, cargas aéreas, sin gravedad), `LOCKED`, respawn, parámetros |
| `test_input_map.gd` | 5 | Acciones `double_jump`, `dash`, `interact`... y sus teclas |
| `test_story.gd` | 8 | Textos de la narrativa y los 3 finales |
| `test_dialogue_box.gd` | 6 | Caja de diálogo: avanzar, completar texto, saltar con Esc |
| `test_fruit.gd` | 5 | Animaciones en bucle de las 8 frutas y recolección única |
| `test_project_structure.gd` | 8 | Estructura exigida del repositorio, `.gitignore`, versión de GUT, créditos, README |
| `test_zz_level1.gd` | 8 | Nivel 1: 13 frutas, meta, límites de cámara, caída, zonas de narrativa |

Nota: `test_zz_level1.gd` lleva ese nombre para que GUT lo ejecute al final. En Godot 4.5 en modo headless,
liberar el nivel dentro de GUT cierra el proceso si todavía quedan pruebas por correr.

Último resultado: ver `test/reports/REPORTE_PRUEBAS.md`.
