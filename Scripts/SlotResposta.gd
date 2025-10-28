# SlotResposta.gd
class_name OpcaoResposta
extends Panel

signal answer_dropped(slot_node)
var source_option_panel = null
var is_empty = false

# --- 1. Lógica de ser um Alvo (Receber um Drop) ---

func _can_drop_data(at_position, data):
	var esta_vazio = ($LabelResposta.text == "x")
	return data.has("tipo") and data["tipo"] == "resposta" and esta_vazio

func _drop_data(at_position, data):
	# Pega o nó de origem (pode ser um OpcaoResposta ou outro SlotResposta)
	var source_node = data["source_node"]

	# MANDA A ORIGEM SE ESVAZIAR
	if source_node:
		source_node.set_empty()
	
	# Armazena de onde este número veio (o "berço")
	# Se a origem for um OpcaoResposta, ele é o berço.
	if source_node is OpcaoResposta:
		source_option_panel = source_node
	# Se a origem for outro SlotResposta, pegamos o berço *dele*
	elif data.has("original_source"):
		source_option_panel = data["original_source"]

	# Coloca o valor aqui
	$LabelResposta.text = str(data["valor"])
	
	# Emite o sinal para o LevelEquacoes (para limpar a cor vermelha/verde)
	answer_dropped.emit(self)


# --- 2. Lógica de ser Arrastado (Quando está "Cheio") ---

func _get_drag_data(at_position):
	if $LabelResposta.text == "x":
		return null
	
	var valor_texto = $LabelResposta.text
	var data = {
		"tipo": "resposta",
		"valor": int(valor_texto),
		"source_node": self, # Envia a si mesmo como origem
		"original_source": source_option_panel # Envia o "berço"
	}

	var preview = Label.new()
	preview.text = valor_texto
	preview.modulate = Color(1, 1, 1, 0.7)
	set_drag_preview(preview)
	
	# --- NÃO ESVAZIA MAIS O SLOT AQUI! ---
	
	return data

# --- 3. Função de Controle (NOVA) ---

# Chamado por um OpcaoResposta ou outro SlotResposta quando pegam este número
func set_empty():
	$LabelResposta.text = "x"
	modulate = Color.WHITE
	source_option_panel = null # Esquece o berço
	
	# Emite o sinal para o LevelEquacoes saber que este slot foi limpo
	answer_dropped.emit(self)
