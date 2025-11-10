# Nó raiz: TouchScreenButton
extends TouchScreenButton

signal opcao_pressionada(node_da_opcao, valor: int)

@onready var label_valor = $LabelValor
var valor: int = 0

func _ready():
	# Conecta internamente, UMA SÓ VEZ.
	if not pressed.is_connected(_on_self_pressed):
		pressed.connect(_on_self_pressed)

func _on_self_pressed():
	opcao_pressionada.emit(self, valor)

func reset_option(novo_valor: int):
	valor = novo_valor 
	label_valor.text = str(novo_valor) 
	set_meta("valor", novo_valor)
	show() 
	modulate = Color.WHITE
