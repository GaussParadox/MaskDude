## Regenera Levels/Level1.tscn (pantalla única de 32x18 tiles, basada en la imagen de referencia).
## Uso (desde la carpeta del proyecto):
##   godot --headless --script res://scripts/tools/build_level.gd
## También puedes editar Level1.tscn directamente en el editor de Godot.
extends SceneTree

const TILE := 16
const SIZE := Vector2i(32, 18)
## La imagen de referencia tiene su cuadrícula de 16px desplazada (2, 11) respecto a la esquina.
const ORIGIN := Vector2(2, 11)

# Fuentes del TileSet World/Terrain.tres
const SRC_TERRAIN := 0
const SRC_FRAME := 1

# Tiles del atlas
const PLANK_L := Vector2i(17, 1)
const PLANK_M := Vector2i(18, 1)
const PLANK_R := Vector2i(19, 1)
const STONE_TOP := Vector2i(1, 0)         # borde superior de piedra (suelo)
const STONE_LEFT := Vector2i(0, 1)        # borde izquierdo de piedra (pared derecha)
const COPPER_BOTTOM := Vector2i(1, 6)     # barra de cobre horizontal (techo)
const COPPER_RIGHT := Vector2i(2, 5)      # barra de cobre vertical (pared izquierda)
const COPPER_CORNER := Vector2i(2, 6)
const STONE_STEP := Vector2i(2, 0)       # escalón de piedra entre los dos suelos

# Regiones de los bloques "pirámide" en Terrain.png
const PYRAMID_SMALL := Rect2(192, 16, 16, 16)
const PYRAMID_BIG := Rect2(208, 16, 32, 32)

# Frutas: [tipo, x, y] (centro, en píxeles). Posiciones medidas de la imagen de referencia.
const FRUITS := [
	["Bananas", 167, 57], ["Pineapple", 202, 57], ["Kiwi", 240, 58], ["Melon", 276, 58],
	["Strawberry", 310, 59], ["Cherries", 347, 60],
	["Pineapple", 146, 86], ["Apple", 183, 87], ["Cherries", 219, 88], ["Bananas", 256, 87],
	["Orange", 291, 88], ["Pineapple", 326, 86], ["Apple", 366, 87],
]

# Plataformas flotantes: esquina superior izquierda (x, y) en píxeles.
const HOVER := [[153, 135], [206, 140], [261, 132], [314, 137]]

# Zonas de narrativa: [clave en Story.gd, centro x, centro y, ancho, alto]
const STORY_TRIGGERS := [
	["hint_double_jump", 92, 140, 24, 40],
	["hint_dash", 222, 118, 44, 56],
	["totem_midway", 402, 140, 36, 40],
]

# Bloques pirámide: [x, y, es_grande] en píxeles.
const PYRAMIDS := [
	[34, 27, true], [450, 235, true],
	[34, 235, false], [82, 235, false], [402, 203, false], [466, 107, false], [466, 219, false],
]

var ground: TileMapLayer
var frame: TileMapLayer
var floor_shade: TileMapLayer
var props: Node2D
var platforms: Node2D
var fruits: Node2D


func _initialize() -> void:
	var root := Node2D.new()
	root.name = "Level1"
	root.set_script(load("res://scripts/levels/Level1.gd"))
	root.set("level_size_tiles", SIZE)

	root.add_child(_make_background())

	ground = _make_layer("Ground")
	root.add_child(ground)
	props = _make_node("Props")
	root.add_child(props)
	platforms = _make_node("Platforms")
	root.add_child(platforms)
	frame = _make_layer("Frame")
	root.add_child(frame)
	fruits = _make_node("Fruits")
	root.add_child(fruits)
	floor_shade = _make_layer("FloorShade")
	floor_shade.modulate = Color(0.6, 0.6, 0.7)  # suelo inferior en sombra, como en la referencia
	root.add_child(floor_shade)

	_build_ground()
	_build_frame()
	_build_props()
	_build_platforms()
	_build_fruits()
	root.add_child(_make_story_triggers())

	var spawn := Marker2D.new()
	spawn.name = "SpawnPoint"
	spawn.position = Vector2(64, 155)
	root.add_child(spawn)
	root.add_child(_make_goal(Vector2(436, 123)))

	var player: Node2D = load("res://scenes/player/MaskDude.tscn").instantiate()
	player.position = spawn.position
	root.add_child(player)

	for n in root.get_children():
		n.owner = root
		if n != player:
			for c in n.get_children():
				_set_owner_rec(c, root)

	var packed := PackedScene.new()
	packed.pack(root)
	var err := ResourceSaver.save(packed, "res://scenes/levels/Level1.tscn")
	print("Level1.tscn guardado: ", error_string(err))
	quit()


func _set_owner_rec(n: Node, root: Node) -> void:
	n.owner = root
	for c in n.get_children():
		_set_owner_rec(c, root)


func _make_node(node_name: String) -> Node2D:
	var n := Node2D.new()
	n.name = node_name
	return n


func _make_layer(layer_name: String) -> TileMapLayer:
	var l := TileMapLayer.new()
	l.name = layer_name
	l.tile_set = load("res://scenes/world/tilesets/Terrain.tres")
	l.position = ORIGIN
	return l


# ---------------------------------------------------------------- fondo

func _make_background() -> Node2D:
	var bg := Node2D.new()
	bg.name = "Background"
	var s := Sprite2D.new()
	s.name = "Pattern"
	s.texture = load("res://assets/sprites/backgrounds/Brown.png")
	s.centered = false
	s.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	s.region_enabled = true
	# Interior del marco: x 34..482, y 27..251. La región se desplaza para alinear el zigzag.
	s.region_rect = Rect2(32, 54, 448, 224)
	s.position = Vector2(34, 27)
	bg.add_child(s)
	return bg


# ---------------------------------------------------------------- terreno

var _terrain := {}   # Vector2i -> "cap" | "dirt"


## Columnas x0..x1 con hierba en `cap_row` y tierra hasta `last_row`.
func _hill(x0: int, x1: int, cap_row: int, last_row: int) -> void:
	for x in range(x0, x1 + 1):
		_terrain[Vector2i(x, cap_row)] = "cap"
		for y in range(cap_row + 1, last_row + 1):
			if not _terrain.has(Vector2i(x, y)):
				_terrain[Vector2i(x, y)] = "dirt"


## Elige el tile según los vecinos: borde izquierdo/derecho solo si el lado está al aire.
func _paint_terrain() -> void:
	for cell: Vector2i in _terrain:
		var left_open := not _terrain.has(cell + Vector2i.LEFT)
		var right_open := not _terrain.has(cell + Vector2i.RIGHT)
		var col := 7
		if left_open:
			col = 6
		elif right_open:
			col = 8
		var row := 0 if _terrain[cell] == "cap" else 1
		if cell.y == 15:
			row = 2   # borde inferior, sobre el suelo de piedra
		ground.set_cell(cell, SRC_TERRAIN, Vector2i(col, row))


## Tablón de un solo sentido (se puede atravesar desde abajo).
func _plank(row: int, tiles: Array) -> void:
	for t in tiles:
		ground.set_cell(Vector2i(t[0], row), SRC_TERRAIN, t[1])


func _build_ground() -> void:
	# Lado izquierdo: bloque alto con escalones que bajan al suelo.
	_hill(5, 7, 13, 14)
	_hill(1, 5, 9, 14)
	_hill(8, 9, 14, 14)
	# Lado derecho: escalones que suben hasta el bloque alto.
	_hill(23, 26, 13, 15)
	_hill(26, 29, 7, 15)
	_hill(20, 22, 14, 15)
	for x in range(20, 30):
		if not _terrain.has(Vector2i(x, 15)):
			_terrain[Vector2i(x, 15)] = "dirt"
	_paint_terrain()
	_plank(10, [[6, PLANK_M], [7, PLANK_R]])
	_plank(9, [[24, PLANK_L], [25, PLANK_M]])


func _build_frame() -> void:
	# Techo de cobre (fila 0) y esquina
	frame.set_cell(Vector2i(1, 0), SRC_FRAME, COPPER_CORNER)
	for x in range(2, 31):
		frame.set_cell(Vector2i(x, 0), SRC_FRAME, COPPER_BOTTOM)
	# Pared izquierda (cobre): más adentro arriba, más afuera abajo
	for y in range(1, 8):
		frame.set_cell(Vector2i(1, y), SRC_FRAME, COPPER_RIGHT)
	for y in range(9, 15):
		frame.set_cell(Vector2i(0, y), SRC_FRAME, COPPER_RIGHT)
	frame.set_cell(Vector2i(0, 15), SRC_FRAME, COPPER_CORNER)
	frame.set_cell(Vector2i(1, 8), SRC_FRAME, COPPER_CORNER)
	# Pared derecha (piedra)
	for y in range(1, 16):
		frame.set_cell(Vector2i(30, y), SRC_FRAME, STONE_LEFT)
	# Suelos de piedra: izquierdo (fila 15) y derecho, más bajo (fila 16)
	for x in range(1, 19):
		frame.set_cell(Vector2i(x, 15), SRC_FRAME, STONE_TOP)
	frame.set_cell(Vector2i(19, 15), SRC_FRAME, STONE_STEP)
	for x in range(19, 30):
		floor_shade.set_cell(Vector2i(x, 16), SRC_FRAME, STONE_TOP)


# ---------------------------------------------------------------- objetos

func _make_block(node_name: String, pos: Vector2, region: Rect2) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = node_name
	body.position = pos
	var spr := Sprite2D.new()
	spr.name = "Sprite2D"
	spr.texture = load("res://assets/sprites/terrain/Terrain.png")
	spr.centered = false
	spr.region_enabled = true
	spr.region_rect = region
	body.add_child(spr)
	var shape := CollisionShape2D.new()
	shape.name = "CollisionShape2D"
	var rect := RectangleShape2D.new()
	rect.size = region.size
	shape.shape = rect
	shape.position = region.size / 2.0
	body.add_child(shape)
	return body


func _build_props() -> void:
	for i in PYRAMIDS.size():
		var p: Array = PYRAMIDS[i]
		var region := PYRAMID_BIG if p[2] else PYRAMID_SMALL
		props.add_child(_make_block("Pyramid%d" % (i + 1), Vector2(p[0], p[1]), region))
	props.add_child(_make_block("PyramidTall", Vector2(50, 219), Rect2(240, 0, 16, 24)))


func _build_platforms() -> void:
	var tex: Texture2D = load("res://assets/sprites/platforms/Hover.png")
	for i in HOVER.size():
		var body := StaticBody2D.new()
		body.name = "Hover%d" % (i + 1)
		body.position = Vector2(HOVER[i][0] + 16, HOVER[i][1])
		var spr := Sprite2D.new()
		spr.name = "Sprite2D"
		spr.texture = tex
		spr.centered = false
		spr.position = Vector2(-16, 0)
		body.add_child(spr)
		var shape := CollisionShape2D.new()
		shape.name = "CollisionShape2D"
		var rect := RectangleShape2D.new()
		rect.size = Vector2(30, 4)
		shape.shape = rect
		shape.position = Vector2(0, 3)
		shape.one_way_collision = true
		body.add_child(shape)
		platforms.add_child(body)


func _build_fruits() -> void:
	var scene: PackedScene = load("res://scenes/items/Fruit.tscn")
	for i in FRUITS.size():
		var f: Node2D = scene.instantiate()
		f.name = "%s%d" % [FRUITS[i][0], i + 1]
		f.position = Vector2(FRUITS[i][1], FRUITS[i][2])
		f.set("frames", load("res://scenes/items/frames/%s.tres" % FRUITS[i][0]))
		fruits.add_child(f)
		f.owner = null


func _make_goal(pos: Vector2) -> Area2D:
	var area := Area2D.new()
	area.name = "Goal"
	area.position = pos
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape2D.new()
	shape.name = "CollisionShape2D"
	var rect := RectangleShape2D.new()
	rect.size = Vector2(32, 40)
	shape.shape = rect
	shape.position = Vector2(0, -20)
	area.add_child(shape)
	var spr := Sprite2D.new()
	spr.name = "Sprite2D"
	spr.texture = load("res://assets/sprites/terrain/Terrain.png")
	spr.region_enabled = true
	spr.region_rect = Rect2(288, 144, 32, 32)  # bloque dorado grande
	spr.position = Vector2(0, -16)
	area.add_child(spr)
	var label := Label.new()
	label.name = "Label"
	label.text = "META"
	label.add_theme_font_size_override("font_size", 8)
	label.position = Vector2(-14, -46)
	area.add_child(label)
	return area


func _make_story_triggers() -> Node2D:
	var holder := Node2D.new()
	holder.name = "StoryTriggers"
	for t in STORY_TRIGGERS:
		var area := Area2D.new()
		area.name = "Trigger_%s" % t[0]
		area.set_script(load("res://scripts/narrative/StoryTrigger.gd"))
		area.set("story_id", t[0])
		area.position = Vector2(t[1], t[2])
		area.collision_layer = 0
		area.collision_mask = 2
		var shape := CollisionShape2D.new()
		shape.name = "CollisionShape2D"
		var rect := RectangleShape2D.new()
		rect.size = Vector2(t[3], t[4])
		shape.shape = rect
		area.add_child(shape)
		holder.add_child(area)
	return holder
