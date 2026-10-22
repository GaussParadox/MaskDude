extends GutTest
## Verifica la estructura exigida para la entrega del repositorio.

const ARCHIVOS := ["project.godot", "export_presets.cfg", "icon.svg", "README.md", "CHANGELOG.md",
	".gitignore", ".gitattributes"]
const CARPETAS := ["addons", "assets", "assets/audio", "assets/musica", "assets/sprites", "assets/fuentes",
	"scenes", "scripts", "test", "docs", "docs/adr", "docs/diagramas", "docs/evidencias"]


func test_archivos_de_la_raiz() -> void:
	for f in ARCHIVOS:
		assert_true(FileAccess.file_exists("res://" + f), "Falta el archivo %s" % f)


func test_carpetas_requeridas() -> void:
	for d in CARPETAS:
		assert_true(DirAccess.dir_exists_absolute("res://" + d), "Falta la carpeta %s/" % d)


func test_gitignore_excluye_cache_y_credenciales() -> void:
	var texto := FileAccess.get_file_as_string("res://.gitignore")
	assert_string_contains(texto, ".godot/")
	assert_string_contains(texto, "export_credentials.cfg")


func test_no_hay_credenciales_de_exportacion() -> void:
	assert_false(FileAccess.file_exists("res://.godot/export_credentials.cfg"))
	assert_false(FileAccess.file_exists("res://export_credentials.cfg"))


func test_framework_de_pruebas_declara_version() -> void:
	var cfg := ConfigFile.new()
	assert_eq(cfg.load("res://addons/gut/plugin.cfg"), OK, "GUT no está instalado en addons/gut/")
	assert_ne(String(cfg.get_value("plugin", "version", "")), "", "Falta la versión de GUT")
	assert_string_contains(FileAccess.get_file_as_string("res://addons/README.md"), "GUT")


func test_cada_carpeta_de_assets_tiene_licencias() -> void:
	for d in ["audio", "musica", "sprites"]:
		assert_true(FileAccess.file_exists("res://assets/%s/CREDITS.md" % d), "Falta CREDITS.md en assets/%s" % d)


func test_escena_principal_existe() -> void:
	var main: String = ProjectSettings.get_setting("application/run/main_scene")
	assert_true(ResourceLoader.exists(main), "La escena principal no existe: %s" % main)


func test_readme_contiene_secciones_obligatorias() -> void:
	var texto := FileAccess.get_file_as_string("res://README.md")
	for seccion in ["Integrantes", "Versión de Godot", "Cómo abrir y ejecutar", "Cómo ejecutar las pruebas",
			"Release", "Créditos de recursos de terceros"]:
		assert_string_contains(texto, seccion, "README sin la sección '%s'" % seccion)
