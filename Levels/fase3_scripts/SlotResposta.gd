# Nó raiz: TouchScreenButton
extends TouchScreenButton

signal slot_pressionado(node_do_slot)

@onready var label_resposta = $LabelResposta

func _ready():
	label_resposta.text = "?"
	
	# Conecta internamente, UMA SÓ VEZ.
	if not pressed.is_connected(_on_self_pressed):
		pressed.connect(_on_self_pressed)

func _on_self_pressed():
	slot_pressionado.emit(self)

func set_empty():
	label_resposta.text = "?"
	modulate = Color.WHITE
