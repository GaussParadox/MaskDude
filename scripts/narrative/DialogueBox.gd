class_name DialogueBox
extends CanvasLayer
## Caja de diálogo con retrato, nombre y texto que aparece letra a letra.
## Uso:  await dialogue.play([{"who": "Mask Dude", "text": "Hola"}])
## Enter / E: completar el texto o pasar a la siguiente línea.  Esc: saltar todo el diálogo.

signal _next

const CHARS_PER_SECOND := 45.0
const BLIP_EVERY := 3   ## un "blip" de sonido cada N letras

## Retratos por nombre de personaje: [textura, región].
const PORTRAITS := {
	"Mask Dude": ["res://assets/sprites/player/Idle.png", Rect2(0, 0, 32, 32)],
	"Tótem Dorado": ["res://assets/sprites/terrain/Terrain.png", Rect2(288, 144, 32, 32)],
}

var active := false

var _typing := false
var _waiting := false
var _skip_all := false
var _progress := 0.0
var _last_blip := 0

@onready var root: Control = $Root
@onready var portrait: TextureRect = $Root/Panel/Portrait
@onready var name_label: Label = $Root/Panel/Name
@onready var text_label: RichTextLabel = $Root/Panel/Text
@onready var hint: Label = $Root/Panel/Hint
@onready var blip: AudioStreamPlayer = $Blip


func _ready() -> void:
	root.hide()


## Muestra las líneas una a una y termina cuando se acabaron (o se saltó).
func play(lines: Array) -> void:
	active = true
	_skip_all = false
	root.show()
	for line in lines:
		if _skip_all:
			break
		await _show_line(line)
	root.hide()
	active = false


func _show_line(line: Dictionary) -> void:
	var who: String = line.get("who", "")
	name_label.text = who
	if PORTRAITS.has(who):
		var data: Array = PORTRAITS[who]
		var tex := AtlasTexture.new()
		tex.atlas = load(data[0])
		tex.region = data[1]
		portrait.texture = tex
		portrait.show()
		name_label.offset_left = 52.0
		text_label.offset_left = 52.0
	else:
		portrait.hide()
		name_label.offset_left = 12.0
		text_label.offset_left = 12.0
	text_label.text = line.get("text", "")
	text_label.visible_characters = 0
	_progress = 0.0
	_last_blip = 0
	hint.hide()
	_typing = true
	_waiting = false
	await _next


func _process(delta: float) -> void:
	if not _typing:
		return
	_progress += delta * CHARS_PER_SECOND
	var total := text_label.get_total_character_count()
	var shown := mini(int(_progress), total)
	text_label.visible_characters = shown
	if shown - _last_blip >= BLIP_EVERY:
		_last_blip = shown
		blip.pitch_scale = randf_range(0.9, 1.15)
		blip.play()
	if shown >= total:
		_finish_typing()


func _finish_typing() -> void:
	_typing = false
	_waiting = true
	text_label.visible_characters = -1
	hint.show()


func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
	if event.is_action_pressed("ui_cancel"):
		_skip_all = true
		_typing = false
		_waiting = false
		_next.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("interact"):
		if _typing:
			_finish_typing()
		elif _waiting:
			_waiting = false
			_next.emit()
		get_viewport().set_input_as_handled()
