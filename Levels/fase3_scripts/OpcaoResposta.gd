# Script: OpcaoResposta.gd
extends Panel

@onready var label_valor = $LabelValor
var valor : int = 0

func _ready():
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
		
# Função para definir o valor (chamada pelo quest_3.gd)
func reset_option(novo_valor: int):
	valor = novo_valor
	label_valor.text = str(novo_valor) # Define o texto
	set_meta("valor", novo_valor) 
	
	# Garante que a opção esteja visível e clicável
	mouse_filter = MOUSE_FILTER_STOP # Permite cliques
	modulate = Color.WHITE # Cor normal

# Esta função é chamada AUTOMATICAMENTE pelo Godot 4
func _get_drag_data(_at_position: Vector2) -> Variant:
	# Se a opção já foi usada (está vazia), não deixa arrastar
	if label_valor.text == "":
		return null # Cancela o arraste

	var meu_valor = get_meta("valor")
	
	var preview_label = Label.new()
	preview_label.text = str(meu_valor)
	preview_label.modulate = Color(1, 1, 1, 0.7)
	preview_label.set_size(label_valor.get_size()) 
	set_drag_preview(preview_label)
	
	var drag_data = {
		"valor": meu_valor,
		"origem": self 
	}
	return drag_data

# Chamada pelo SlotResposta quando este número é usado
func foi_usada():
	label_valor.text = "" # Fica VAZIO
	mouse_filter = MOUSE_FILTER_IGNORE # Desabilita cliques
	modulate = Color(0.7, 0.7, 0.7) # (Opcional) Fica cinza

func on_mouse_entered():
	modulate = Color.YELLOW
	
func on_mouse_exited():
	modulate = Color.WHITE
