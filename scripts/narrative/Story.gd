class_name Story
## Todos los textos de la narrativa en un solo lugar (fácil de editar y de citar en el documento).
## Cada línea de diálogo es un Diccionario: {"who": quién habla, "text": texto}.

const TITLE := "EL FESTÍN DEL TÓTEM"
const SUBTITLE := "Un nivel de Mask Dude"

## Cinemática de introducción: tarjetas de texto sobre fondo negro (plantean el conflicto).
const INTRO_CARDS := [
	"Cada año, en la noche de la cosecha, la aldea ofrece sus mejores frutas al Tótem Dorado.",
	"Esta vez las frutas despertaron. Escaparon flotando hacia la Cámara Antigua... y el Tótem se apagó.",
	"Si la ofrenda no llega antes del amanecer, la cosecha del próximo año se perderá.",
]

## Diálogo al revelar el nivel: presenta el objetivo y los poderes.
const INTRO_DIALOGUE := [
	{"who": "Mask Dude", "text": "Las frutas flotan por toda la cámara... y el Tótem está arriba, al otro lado."},
	{"who": "Tótem Dorado", "text": "Guardián de la Máscara... recoge la ofrenda y tráela hasta mí antes del amanecer."},
	{"who": "Tótem Dorado", "text": "Los espíritus te prestan dos poderes: el doble salto y el dash. Úsalos con sabiduría."},
	{"who": "Mask Dude", "text": "Entendido. ¡Vamos por esas frutas!"},
]

const OBJECTIVE := "Objetivo: recoge las frutas y llega al Tótem Dorado"

## Consejos breves (no pausan el juego) que se activan al pasar por una zona.
const HINTS := {
	"hint_double_jump": "Doble salto: pulsa SALTO otra vez en el aire (Espacio / W / ↑)",
	"hint_dash": "Dash: pulsa SHIFT o K para lanzarte hacia delante (una vez por salto)",
}

## Diálogos a mitad del nivel (pausan el control del jugador).
const DIALOGUES := {
	"totem_midway": [
		{"who": "Tótem Dorado", "text": "Ya siento tu ofrenda, guardián... sube hasta mi bloque cuando estés listo."},
		{"who": "Mask Dude", "text": "Casi llego. ¿Habré recogido todas?"},
	],
}


## Diálogo final: cierra el conflicto según las frutas recogidas.
static func ending_lines(collected: int, total: int) -> Array:
	if collected >= total:
		return [
			{"who": "Tótem Dorado", "text": "¡Todas las frutas! La ofrenda está completa."},
			{"who": "Mask Dude", "text": "Lo logramos... la aldea tendrá su cosecha."},
			{"who": "Tótem Dorado", "text": "Mi luz vuelve a brillar. Que comience el Festín. Gracias, guardián."},
		]
	if collected > 0:
		return [
			{"who": "Tótem Dorado", "text": "Me traes %d de %d frutas... la ofrenda está incompleta." % [collected, total]},
			{"who": "Mask Dude", "text": "Perdón. Algunas flotaban más alto de lo que pensé."},
			{"who": "Tótem Dorado", "text": "Mi luz brilla apenas. El Festín será modesto este año. Quizá puedas volver por el resto."},
		]
	return [
		{"who": "Tótem Dorado", "text": "Llegas con las manos vacías, guardián... la ofrenda no está."},
		{"who": "Mask Dude", "text": "Lo sé... Déjame intentarlo otra vez."},
		{"who": "Tótem Dorado", "text": "Mi luz casi se apaga. Las frutas siguen flotando en la cámara. Inténtalo de nuevo."},
	]


## Texto de la pantalla final.
static func epilogue(collected: int, total: int) -> String:
	if collected >= total:
		return "La cosecha está a salvo.\nLa aldea celebra bajo la luz del Tótem."
	if collected > 0:
		return "La cosecha será escasa este año.\n¿Podrás recuperar todas las frutas?"
	return "La noche sigue oscura.\nLas frutas aún esperan en la Cámara Antigua."
