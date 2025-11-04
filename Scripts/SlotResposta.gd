# Script: SlotResposta.gd
extends Panel

# Sinal que o quest_3.gd está ouvindo
signal answer_dropped(slot_que_recebeu)
# Sinal para "devolver" um número
signal valor_liberado(valor: int)

@onready var label_resposta = $LabelResposta

# Guarda o número que este slot está segurando
var valor_segurando: int = -1

func _ready():
	label_resposta.text = "?"
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# --- NOVO ---
	# Conecta o sinal de input deste painel
	gui_input.connect(_on_gui_input)

# --- NOVA FUNÇÃO ---
# Chamada quando o mouse clica ou interage com ESTE slot
func _on_gui_input(event: InputEvent):
	# Se for um clique esquerdo E o slot NÃO estiver vazio
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if valor_segurando != -1:
			print("Clicado para devolver o valor: ", valor_segurando)
			# Chama a função que "joga de volta" o número
			_esvaziar_e_liberar()

# Verifica se o que está sendo arrastado é válido
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return (data is Dictionary and data.has("valor"))

# Ação a ser tomada quando os dados são soltos
func _drop_data(_at_position: Vector2, data: Variant):
	
	# 1. Se o slot JÁ tinha um número (ex: "5")...
	if valor_segurando != -1:
		# ... e o número novo (ex: "4") é o mesmo, não faz nada.
		if valor_segurando == data.valor:
			return 
		
		# ... mas se for um número diferente, libera o antigo ("5").
		print("Liberando valor antigo: ", valor_segurando)
		valor_liberado.emit(valor_segurando)

	# 2. Define o novo valor (ex: "4")
	valor_segurando = data.valor
	label_resposta.text = str(valor_segurando)
	print("Recebeu o valor: ", valor_segurando)
	
	# 3. Informa à OpcaoResposta ("4") que ela foi usada
	if data.has("origem") and data.origem.has_method("foi_usada"):
		data.origem.foi_usada()
		
	# 4. Avisa ao quest_3.gd que um slot foi preenchido
	answer_dropped.emit(self)


# --- ATUALIZADO ---
# Função interna que faz o trabalho de esvaziar
func _esvaziar_e_liberar():
	# Se já está vazio, não faz nada
	if valor_segurando == -1:
		return
		
	# 1. Emite o sinal para "jogar de volta" o número
	valor_liberado.emit(valor_segurando)
	
	# 2. Esvazia a si mesmo
	valor_segurando = -1
	label_resposta.text = "?"
	modulate = Color.WHITE

# --- ATUALIZADO ---
# Método que o quest_3.gd usa para limpar o slot no 'gerar_equacoes'
func set_empty():
	# Agora ele só chama a função interna
	_esvaziar_e_liberar()
