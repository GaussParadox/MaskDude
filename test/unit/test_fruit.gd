extends GutTest
## Frutas: animaciones en bucle y recolección.

const FruitScene := preload("res://scenes/items/Fruit.tscn")
const PlayerScene := preload("res://scenes/player/MaskDude.tscn")
const FRUTAS := ["Apple", "Bananas", "Cherries", "Kiwi", "Melon", "Orange", "Pineapple", "Strawberry"]


func test_cada_fruta_tiene_animacion_idle_en_bucle_de_17_frames() -> void:
	for nombre in FRUTAS:
		var frames: SpriteFrames = load("res://scenes/items/frames/%s.tres" % nombre)
		assert_not_null(frames, "No carga %s.tres" % nombre)
		assert_true(frames.has_animation("idle"), "%s sin 'idle'" % nombre)
		assert_eq(frames.get_frame_count("idle"), 17, "%s: frames de idle" % nombre)
		assert_true(frames.get_animation_loop("idle"), "%s: idle debe repetirse" % nombre)


func test_cada_fruta_tiene_animacion_collected_sin_bucle() -> void:
	for nombre in FRUTAS:
		var frames: SpriteFrames = load("res://scenes/items/frames/%s.tres" % nombre)
		assert_eq(frames.get_frame_count("collected"), 6, "%s: frames de collected" % nombre)
		assert_false(frames.get_animation_loop("collected"))


func test_la_fruta_reproduce_idle_al_aparecer() -> void:
	var fruta: Fruit = FruitScene.instantiate()
	add_child_autoqfree(fruta)
	await wait_physics_frames(2)
	assert_eq(fruta.sprite.animation, &"idle")
	assert_true(fruta.sprite.is_playing())
	assert_true(fruta.is_in_group("fruit"))


func test_recoger_emite_la_senal_una_sola_vez() -> void:
	var fruta: Fruit = FruitScene.instantiate()
	add_child_autoqfree(fruta)
	var jugador: MaskDude = PlayerScene.instantiate()
	add_child_autoqfree(jugador)
	watch_signals(fruta)
	fruta._on_body_entered(jugador)
	fruta._on_body_entered(jugador)
	assert_signal_emit_count(fruta, "collected", 1)
	assert_eq(fruta.sprite.animation, &"collected")


func test_otros_cuerpos_no_recogen_la_fruta() -> void:
	var fruta: Fruit = FruitScene.instantiate()
	add_child_autoqfree(fruta)
	var intruso := Node2D.new()
	add_child_autoqfree(intruso)
	watch_signals(fruta)
	fruta._on_body_entered(intruso)
	assert_signal_not_emitted(fruta, "collected")
