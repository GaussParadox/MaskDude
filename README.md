# Mask Dude – El Festín del Tótem

Juego de plataformas 2D hecho en **Godot 4.5**. Mask Dude, guardián de la aldea, debe recuperar las frutas de la
ofrenda que escaparon a la Cámara Antigua y llegar al Tótem Dorado antes del amanecer.

## Integrantes

| Integrante | Rol |
|---|---|
|---Oscar Andrés Arciniegas Bustos — Narrativa e interfaz---|
|---Wilson Alejandro Saavedra Arenales — Calidad y pruebas---|
|---Hugo Orielso Cañas Lozano — Jugador y física---|
|---Elkin Sebastian Perez Marquez — Niveles, arte, audio y build---|


> Completar con los integrantes reales del equipo y su rol.

## Versión de Godot

**Godot 4.5** (stable), renderizador *GL Compatibility*. No requiere C# ni plugins.

## Cómo abrir y ejecutar

1. Descarga Godot 4.5 desde https://godotengine.org/download.
2. En el **Project Manager**, pulsa **Import** y selecciona el archivo `project.godot` de esta carpeta.
3. Abre el proyecto y pulsa **F5** (la escena principal es `scenes/world/World.tscn`). No debe aparecer ningún error en el panel *Debugger*.

### Controles

| Acción | Teclas |
|---|---|
| Moverse | A / D o ← / → |
| Saltar | Espacio, W o ↑ |
| **Doble salto** | pulsar Saltar otra vez en el aire |
| **Dash** | Shift o K |
| Avanzar diálogos | Enter o E (Esc salta la introducción / el diálogo) |
| Reiniciar nivel | R |
| Silenciar | M |
| Ver estado del jugador (depuración) | F3 |

## Cómo ejecutar las pruebas

Framework: **GUT 9.5.0** (en `addons/gut/`). Desde la carpeta del proyecto:

```
godot --headless --import
godot --headless -s addons/gut/gut_cmdln.gd -gconfig=res://test/gut_config.json
```

(el primer comando solo hace falta la primera vez). Resultado esperado: **61 pruebas, 0 fallos**.
Los reportes quedan en `test/reports/` (`gut_results.xml` y `REPORTE_PRUEBAS.md`). También se pueden correr desde el
editor, en el panel **GUT** (*Run All*). Detalle en `test/README.md`.

## Release

Versión **v1.0.0**: _[enlace a la release, p. ej. https://github.com/<usuario>/<repo>/releases/tag/v1.0.0]_
(debe apuntar al último commit anterior a la hora límite).

## Estructura del repositorio

```
MaskDude/
├── project.godot   export_presets.cfg   icon.svg
├── README.md   CHANGELOG.md   .gitignore   .gitattributes
├── addons/         gut/ o gdUnit4/ (versión declarada en addons/README.md)
├── assets/
│   ├── audio/      efectos de sonido (+ CREDITS.md con licencias)
│   ├── musica/     música y jingles (+ CREDITS.md)
│   ├── sprites/    player/, fruits/, terrain/, backgrounds/, platforms/ (+ CREDITS.md)
│   └── fuentes/    fuentes (ninguna propia; ver README)
├── scenes/         escenas .tscn y recursos, por funcionalidad:
│   ├── player/     MaskDude.tscn, MaskDudeFrames.tres
│   ├── items/      Fruit.tscn y frames/ (un SpriteFrames por fruta)
│   ├── levels/     Level1.tscn (pantalla única) y Level_Large.tscn (nivel largo anterior)
│   ├── narrative/  DialogueBox.tscn
│   └── world/      World.tscn (escena principal) y tilesets/
├── scripts/        scripts .gd (mismas carpetas que scenes/) y tools/ (generadores de niveles)
├── test/           pruebas unitarias y reportes
└── docs/           PDF del parcial, diagramas/, adr/, evidencias/ y Movimientos_y_Narrativa.md
```

### Notas de diseño
- `scripts/narrative/Story.gd` concentra todos los textos de la historia.
- Para añadir una fruta: instancia `scenes/items/Fruit.tscn` en el nodo `Fruits` de `Level1` y cambia su propiedad
  `Frames` por otro `.tres` de `scenes/items/frames/`.
- `scripts/tools/build_level.gd` regenera `Level1.tscn`
  (`godot --headless --script res://scripts/tools/build_level.gd`); `build_level_large.gd` regenera `Level_Large.tscn`.
- Input Map, parámetros de movimiento y el diagrama de estados: `docs/Movimientos_y_Narrativa.md`.

## Créditos de recursos de terceros

- **Música**: "Hungry Dino" de SketchyLogic (CC-BY 3.0) — https://opengameart.org/content/hungry-dino-9-chiptune-tracks-10-sfx
- **Efectos de sonido**: "NES Sounds" de Baŝto (CC0), "RPG Sound Pack" de artisticdude (CC0) y un sonido de
  Prinsu-Kun (CC0), obtenidos vía https://github.com/dulsi/mari0. Detalle en `assets/audio/CREDITS.md` y `assets/musica/CREDITS.md`.
- **Gráficos y sprites**: "Pixel Adventure 1" de Pixel Frog (CC0, atribución no obligatoria pero incluida) — https://pixelfrog-assets.itch.io/pixel-adventure-1. Detalle en `assets/sprites/CREDITS.md`.
- **Pruebas**: GUT (Godot Unit Test) de Butch Wessels, licencia MIT — https://github.com/bitwes/Gut
- **Motor**: Godot Engine (licencia MIT).

## Enlaces
- Repositorio: https://github.com/GaussParadox/MaskDude
- Release: https://github.com/GaussParadox/MaskDude/releases/tag/v1.0.0