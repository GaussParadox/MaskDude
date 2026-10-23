# Changelog

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y versionado semántico.



## [1.0.0] - 2026-10-19
### Añadido
- Jugador **Mask Dude** (`CharacterBody2D`) con máquina de estados: `IDLE`, `RUN`, `JUMP`, `FALL`, `DOUBLE_JUMP`, `DASH` y `LOCKED`.
- Movimientos adicionales: **doble salto** (acción `double_jump`) y **dash** (acción `dash`), con parámetros editables en el Inspector.
- Nivel 1 de pantalla única (512x288) basado en la imagen de referencia, con plataformas, colisiones, tablones de un solo sentido, plataformas flotantes y meta.
- 13 frutas coleccionables con animación en bucle y contador en pantalla.
- Narrativa dentro del juego: cinemática de introducción, diálogos con retratos, consejos contextuales y tres finales según las frutas recogidas.
- Audio: música de fondo, efectos (salto, fruta, dash, caída, victoria) y tecla M para silenciar.
- Nivel largo anterior conservado como `scenes/levels/Level_Large.tscn`.
- Estructura de repositorio para la entrega (`scenes/`, `scripts/`, `assets/`, `docs/`, `test/`, `addons/`).
- Pruebas unitarias automatizadas con GUT 9.5.0 (61 pruebas) y reportes en `test/reports/`.
- Documentación: diagrama de estados del jugador, Input Map, parámetros y guion de la narrativa en `docs/`.

### Corregido (dentro de 1.0.0)
- Las frutas ya no usan `await` al recogerse: reiniciar el nivel a mitad de la animación no deja procesos pendientes.
- La introducción detecta el reinicio (R) y se detiene limpiamente.
