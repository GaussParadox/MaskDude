extends Node2D
## Escena principal: nivel, interfaz, audio y narrativa (introducción, diálogos y final).

const SKIP_HINT := "Enter: continuar   ·   Esc: saltar"
const TOTEM_OFF := Color(0.4, 0.4, 0.5)       # Tótem apagado al inicio
const TOTEM_ON := Color(1.25, 1.15, 0.8)      # Tótem encendido al final

@onready var level: Node2D = $Level1
@onready var dialogue: DialogueBox = $DialogueBox
@onready var fruit_label: Label = $UI/FruitLabel
@onready var hint_label: Label = $UI/Hint
@onready var fade: ColorRect = $Cinematic/Fade
@onready var title_label: Label = $Cinematic/Title
@onready var subtitle_label: Label = $Cinematic/Subtitle
@onready var card_label: Label = $Cinematic/Card
@onready var footer_label: Label = $Cinematic/Footer
@onready var music: AudioStreamPlayer = $Audio/Music
@onready var collect_sound: AudioStreamPlayer = $Audio/Collect
@onready var all_fruits_sound: AudioStreamPlayer = $Audio/AllFruits
@onready var win_sound: AudioStreamPlayer = $Audio/Win
@onready var fall_sound: AudioStreamPlayer = $Audio/Fall
@onready var totem_sound: AudioStreamPlayer = $Audio/Totem

var _skip_intro := false
var _intro_running := false
var _ending := false
var _hint_tween: Tween


func _ready() -> void:
	music.stream.loop = true
	level.level_completed.connect(_on_level_completed)
	level.fruits_changed.connect(_on_fruits_changed)
	level.player_fell.connect(fall_sound.play)
	for trigger in get_tree().get_nodes_in_group("story_trigger"):
		trigger.triggered.connect(_on_story_triggered)
	_update_fruit_label(level.fruit_collected, level.fruit_total)
	_set_totem_glow(0.0)
	await _play_intro()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and _intro_running:
		_skip_intro = true
	elif event.is_action_pressed("restart"):
		get_tree().reload_current_scene()
	elif event.is_action_pressed("mute"):
		var master := AudioServer.get_bus_index("Master")
		AudioServer.set_bus_mute(master, not AudioServer.is_bus_mute(master))


# ---------------------------------------------------------------- introducción

func _play_intro() -> void:
	_intro_running = true
	level.player.set_locked(true)
	footer_label.text = SKIP_HINT
	footer_label.modulate.a = 0.6
	title_label.text = Story.TITLE
	subtitle_label.text = Story.SUBTITLE

	await _fade_labels([title_label, subtitle_label], 1.0, 1.0)
	await _wait_interact(2.5)
	await _fade_labels([title_label, subtitle_label], 0.0, 0.6)

	for text: String in Story.INTRO_CARDS:
		if _skip_intro:
			break
		card_label.text = text
		await _fade_labels([card_label], 1.0, 0.6)
		await _wait_interact(4.5)
		await _fade_labels([card_label], 0.0, 0.5)

	# Revela el nivel con el Tótem todavía apagado.
	footer_label.modulate.a = 0.0
	var reveal := create_tween()
	reveal.tween_property(fade, "color:a", 0.0, 0.2 if _skip_intro else 1.0)
	await reveal.finished

	if not _skip_intro:
		totem_sound.play()
		var glow := create_tween()
		glow.tween_method(_set_totem_glow, 0.0, 0.3, 1.0)
		await glow.finished
		await dialogue.play(Story.INTRO_DIALOGUE)
	else:
		_set_totem_glow(0.3)

	_intro_running = false
	level.player.set_locked(false)
	_show_hint(Story.OBJECTIVE, 6.0)


## Espera Enter/E o el tiempo máximo; Esc salta toda la introducción.
func _wait_interact(max_time: float) -> void:
	var elapsed := 0.0
	while elapsed < max_time and not _skip_intro:
		if not is_inside_tree():
			return   # el nivel se reinició (R) durante la introducción
		await get_tree().process_frame
		if not is_inside_tree():
			return
		elapsed += get_process_delta_time()
		if Input.is_action_just_pressed("interact"):
			break


func _fade_labels(labels: Array, alpha: float, time: float) -> void:
	var tween := create_tween().set_parallel(true)
	for label: Label in labels:
		tween.tween_property(label, "modulate:a", alpha, 0.05 if _skip_intro else time)
	await tween.finished


# ---------------------------------------------------------------- durante el nivel

func _on_story_triggered(story_id: String) -> void:
	if _ending:
		return
	if Story.HINTS.has(story_id):
		_show_hint(Story.HINTS[story_id], 5.0)
	elif Story.DIALOGUES.has(story_id):
		level.player.set_locked(true)
		await dialogue.play(Story.DIALOGUES[story_id])
		if not _ending:
			level.player.set_locked(false)


func _show_hint(text: String, seconds: float) -> void:
	if _hint_tween:
		_hint_tween.kill()
	hint_label.text = text
	_hint_tween = create_tween()
	_hint_tween.tween_property(hint_label, "modulate:a", 1.0, 0.3)
	_hint_tween.tween_interval(seconds)
	_hint_tween.tween_property(hint_label, "modulate:a", 0.0, 0.6)


func _on_fruits_changed(collected: int, total: int) -> void:
	_update_fruit_label(collected, total)
	if collected == total:
		all_fruits_sound.play()
	else:
		collect_sound.play()


func _update_fruit_label(collected: int, total: int) -> void:
	fruit_label.text = "Frutas: %d/%d" % [collected, total]


func _set_totem_glow(amount: float) -> void:
	var sprite: Sprite2D = level.goal.get_node("Sprite2D")
	sprite.modulate = TOTEM_OFF.lerp(TOTEM_ON, amount)


# ---------------------------------------------------------------- final

func _on_level_completed() -> void:
	if _ending:
		return
	_ending = true
	var collected: int = level.fruit_collected
	var total: int = level.fruit_total
	level.player.set_locked(true)
	music.stop()
	win_sound.play()
	totem_sound.play()

	# El Tótem se enciende más o menos según la ofrenda entregada.
	var target := 0.35 + 0.65 * float(collected) / maxf(total, 1.0)
	var glow := create_tween()
	glow.tween_method(_set_totem_glow, 0.3, target, 1.2)
	await glow.finished

	await dialogue.play(Story.ending_lines(collected, total))
	await _show_end_card(collected, total)


func _show_end_card(collected: int, total: int) -> void:
	title_label.text = "FIN"
	card_label.text = Story.epilogue(collected, total)
	subtitle_label.text = "Frutas: %d/%d" % [collected, total]
	card_label.offset_top = 6.0
	card_label.offset_bottom = 70.0
	subtitle_label.offset_top = 76.0
	subtitle_label.offset_bottom = 96.0
	footer_label.text = "Pulsa R para jugar de nuevo"

	var tween := create_tween()
	tween.tween_property(fade, "color:a", 1.0, 1.2)
	await tween.finished
	await _fade_labels([title_label, card_label, subtitle_label, footer_label], 1.0, 1.0)
