# OpcaoResposta.gd
extends Panel

var is_empty = false

# --- 1. Lógica de ser Arrastado (Quando está "Cheio") ---

func _get_drag_data(at_position):
	if is_empty:
		return null

	var valor_texto = $LabelValor.text
	var data = {
		"tipo": "resposta",
		"valor": int(valor_texto),
		"source_node": self  # Envia a si mesmo como origem
	}

	var preview = Label.new()
	preview.text = valor_texto
	preview.modulate = Color(1, 1, 1, 0.7)
	set_drag_preview(preview)
	
	# NÃO CHAMA set_empty() AQUI!
	return data

# --- 2. Lógica de ser um Alvo (Quando está "Vazio") ---

func _can_drop_data(at_position, data):
	return is_empty and data.has("tipo") and data["tipo"] == "resposta"

func _drop_data(at_position, data):
	# Pega o nó de origem (que é um SlotResposta)
	var source_slot = data["source_node"]
	
	# MANDA O SLOT DE ORIGEM SE ESVAZIAR
	if source_slot:
		source_slot.set_empty() # <-- Esta é a nova função que vamos criar no SlotResposta
	
	# Agora, preenche a si mesmo
	self.reset_option(data["valor"])


# --- 3. Funções de Controle ---

# Chamado por um SlotResposta quando ele pega este número
func set_empty():
	is_empty = true
	$LabelValor.text = ""
	modulate = Color(0.5, 0.5, 0.5, 0.7)

# Chamado pelo LevelEquacoes ou por ele mesmo no _drop_data
func reset_option(novo_valor):
	is_empty = false
	$LabelValor.text = str(novo_valor)
	modulate = Color.WHITE
