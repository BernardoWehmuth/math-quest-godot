# SlotResposta.gd
extends Panel

signal answer_dropped(slot_node)
var source_option_panel = null

# NOVO: Conecta o sinal de mouse_exited no _ready
func _ready():
	self.mouse_exited.connect(_on_mouse_exited)

# --- LÓGICA DO BRILHO (INÍCIO) ---
func _can_drop_data(_at_position, data):
	var esta_vazio = ($LabelResposta.text == "x")
	var is_valid = data.has("tipo") and data["tipo"] == "resposta" and esta_vazio
	
	if is_valid:
		# Brilha (Glow ON)
		self.modulate = Color.YELLOW
		
	return is_valid

# NOVO: Função para parar o brilho quando o mouse sai
func _on_mouse_exited():
	# Só reseta a cor se estiver brilhando (amarelo)
	# (Não mexe se estiver VERDE ou VERMELHO)
	if self.modulate == Color.YELLOW:
		self.modulate = Color.WHITE

# --- LÓGICA DO BRILHO (FIM) ---

func _drop_data(_at_position, data):
	# Para o brilho (Glow OFF)
	self.modulate = Color.WHITE

	# --- O resto da função é igual ---
	var source_node = data["source_node"]

	if source_node:
		source_node.set_empty()
	
	if source_node is OpcaoResposta:
		source_option_panel = source_node
	elif data.has("original_source"):
		source_option_panel = data["original_source"]

	$LabelResposta.text = str(data["valor"])
	
	answer_dropped.emit(self)

func _get_drag_data(_at_position):
	if $LabelResposta.text == "x":
		return null
	
	var valor_texto = $LabelResposta.text
	var data = {
		"tipo": "resposta",
		"valor": int(valor_texto),
		"source_node": self,
		"original_source": source_option_panel
	}

	var preview = Label.new()
	preview.text = valor_texto
	preview.modulate = Color(1, 1, 1, 0.7)
	set_drag_preview(preview)
	
	return data

func set_empty():
	$LabelResposta.text = "x"
	# Garante que a cor seja resetada para branca (Glow OFF)
	modulate = Color.WHITE
	source_option_panel = null
	
	answer_dropped.emit(self)
