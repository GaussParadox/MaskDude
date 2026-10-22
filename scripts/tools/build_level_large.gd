## Regenera Levels/Level_Large.tscn (nivel largo anterior) a partir del diseño descrito aquí.
## Uso (desde la carpeta del proyecto):
##   godot --headless --script res://scripts/tools/build_level.gd
## También puedes editar Level1.tscn directamente en el editor de Godot
## (pintando tiles en la capa "Ground"); este script es solo una comodidad.
extends SceneTree

const TILE := 16
const W := 112
const H := 18
const GROUND_ROW := 14

var ground: TileMapLayer
var decor: TileMapLayer


func _initialize() -> void:
	var root := Node2D.new()
	root.name = "Level_Large"
	root.set_script(load("res://scripts/levels/Level1.gd"))

	decor = TileMapLayer.new()
	decor.name = "Decor"
	decor.tile_set = load("res://scenes/world/tilesets/Decor.tres")
	root.add_child(decor)

	ground = TileMapLayer.new()
	ground.name = "Ground"
	ground.tile_set = load("res://scenes/world/tilesets/Terrain.tres")
	root.add_child(ground)

	_build_terrain()
	_build_decor()

	var spawn := Marker2D.new()
	spawn.name = "SpawnPoint"
	spawn.position = _foot(3, GROUND_ROW)
	root.add_child(spawn)

	root.add_child(_make_checkpoint("Checkpoint1", _foot(44, GROUND_ROW)))
	root.add_child(_make_checkpoint("Checkpoint2", _foot(87, GROUND_ROW)))
	root.add_child(_make_goal(_foot(101, 11)))

	var player: Node2D = load("res://scenes/player/MaskDude.tscn").instantiate()
	player.position = spawn.position
	root.add_child(player)

	# Dueños para que todo se guarde en la escena.
	for n in [decor, ground, spawn, player]:
		n.owner = root
	for n in root.get_children():
		n.owner = root
		if n != player:
			for c in n.get_children():
				_set_owner_rec(c, root)

	var packed := PackedScene.new()
	packed.pack(root)
	var err := ResourceSaver.save(packed, "res://scenes/levels/Level_Large.tscn")
	print("Level_Large.tscn guardado: ", error_string(err))
	quit()


func _set_owner_rec(n: Node, root: Node) -> void:
	n.owner = root
	for c in n.get_children():
		_set_owner_rec(c, root)


## Posición en píxeles del centro-inferior de un tile superior (para los "pies").
func _foot(col: int, row: int) -> Vector2:
	return Vector2(col * TILE + TILE / 2, row * TILE)


# ---------------------------------------------------------------- terreno

func _grass_cell(x: int) -> Vector2i:
	return Vector2i(6 + x % 3, 0)


func _dirt_cell(x: int, y: int) -> Vector2i:
	return Vector2i(6 + x % 3, 1 + (y % 2))


## Suelo continuo de hierba + tierra hasta el fondo del nivel.
func _ground(x0: int, x1: int) -> void:
	for x in range(x0, x1 + 1):
		ground.set_cell(Vector2i(x, GROUND_ROW), 0, _grass_cell(x))
		for y in range(GROUND_ROW + 1, H):
			ground.set_cell(Vector2i(x, y), 0, _dirt_cell(x, y))


## Plataforma flotante: hierba arriba y una fila de tierra debajo.
func _platform(x0: int, x1: int, row: int) -> void:
	for x in range(x0, x1 + 1):
		ground.set_cell(Vector2i(x, row), 0, _grass_cell(x))
		ground.set_cell(Vector2i(x, row + 1), 0, _dirt_cell(x, 1))


## Columna de bloques de piedra de `height` tiles apoyada en el suelo.
func _stone_column(x: int, height: int) -> void:
	for i in range(height):
		ground.set_cell(Vector2i(x, GROUND_ROW - 1 - i), 0, Vector2i(12, 5))


func _build_terrain() -> void:
	# Muros laterales para que el jugador no salga del escenario.
	for y in range(H):
		ground.set_cell(Vector2i(-1, y), 0, Vector2i(12, 5))
		ground.set_cell(Vector2i(W, y), 0, Vector2i(12, 5))

	# Tramo 1: inicio y escalones de piedra (tutorial de salto).
	_ground(0, 23)
	for x in [11, 12]: _stone_column(x, 1)
	for x in [15, 16]: _stone_column(x, 2)
	for x in [19, 20]: _stone_column(x, 3)

	# Primer foso con una plataforma de ayuda.
	_platform(25, 26, 12)

	# Tramo 2: suelo con plataformas altas opcionales.
	_ground(28, 45)
	_platform(32, 35, 11)
	_platform(38, 41, 8)

	# Segundo foso.
	_platform(47, 48, 12)
	_ground(50, 57)

	# Tramo 3: ascenso y descenso por plataformas sobre un foso largo.
	_platform(54, 56, 11)
	_platform(59, 61, 9)
	_platform(64, 66, 7)
	_platform(69, 72, 9)
	_platform(75, 78, 11)
	_platform(81, 83, 13)

	# Tramo final: suelo, escalera de piedra y podio dorado con la meta.
	_ground(84, W - 1)
	_stone_column(94, 1)
	_stone_column(95, 2)
	_stone_column(96, 3)
	for x in range(97, 105):
		for y in range(11, GROUND_ROW):
			ground.set_cell(Vector2i(x, y), 0, Vector2i(17, 9))


func _build_decor() -> void:
	# Muro de ladrillos al fondo de la zona final.
	for x in range(100, W):
		for y in range(6, GROUND_ROW):
			decor.set_cell(Vector2i(x, y), 0, Vector2i(17 + x % 4, 4 + y % 3))


# ---------------------------------------------------------------- objetos

func _make_checkpoint(node_name: String, pos: Vector2) -> Area2D:
	var area := Area2D.new()
	area.name = node_name
	area.position = pos
	area.collision_layer = 0
	area.collision_mask = 2
	area.add_to_group("checkpoint", true)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(16, 32)
	shape.name = "CollisionShape2D"
	shape.shape = rect
	shape.position = Vector2(0, -16)
	area.add_child(shape)
	var spr := Sprite2D.new()
	spr.name = "Sprite2D"
	spr.texture = load("res://assets/sprites/terrain/Terrain.png")
	spr.region_enabled = true
	spr.region_rect = Rect2(192, 144, 16, 16)  # bloque naranja pequeño
	spr.position = Vector2(0, -8)
	area.add_child(spr)
	return area


func _make_goal(pos: Vector2) -> Area2D:
	var area := Area2D.new()
	area.name = "Goal"
	area.position = pos
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(32, 40)
	shape.name = "CollisionShape2D"
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
