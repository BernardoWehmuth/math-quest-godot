# OpcaoResposta.gd
class_name OpcaoResposta
extends Panel

var is_empty = false

# NOVO: Conecta o sinal de mouse_exited no _ready
func _ready():
	self.mouse_exited.connect(_on_mouse_exited)

func _get_drag_data(_at_position):
	if is_empty:
		return null

	var valor_texto = $LabelValor.text
	var data = {
		"tipo": "resposta",
		"valor": int(valor_texto),
		"source_node": self
	}

	var preview = Label.new()
	preview.text = valor_texto
	preview.modulate = Color(1, 1, 1, 0.7)
	set_drag_preview(preview)
	
	return data

# --- LÓGICA DO BRILHO (INÍCIO) ---
func _can_drop_data(_at_position, data):
	var is_valid = is_empty and data.has("tipo") and data["tipo"] == "resposta"
	
	if is_valid:
		# Brilha (Glow ON)
		self.modulate = Color.YELLOW
	
	return is_valid

# NOVO: Função para parar o brilho quando o mouse sai
func _on_mouse_exited():
	# Só reseta a cor se estiver brilhando (amarelo)
	if self.modulate == Color.YELLOW:
		# Volta para a cor de "vazio"
		self.modulate = Color(0.5, 0.5, 0.5, 0.7)

# --- LÓGICA DO BRILHO (FIM) ---
	
func _drop_data(_at_position, data):
	var source_slot = data["source_node"]
	
	if source_slot:
		source_slot.set_empty()
	
	# Chama reset_option, que já define a cor para Color.WHITE
	self.reset_option(data["valor"])


func set_empty():
	is_empty = true
	$LabelValor.text = ""
	# Define a cor de "vazio"
	modulate = Color(0.5, 0.5, 0.5, 0.7)

func reset_option(novo_valor):
	is_empty = false
	$LabelValor.text = str(novo_valor)
	# Define a cor de "cheio" (Glow OFF)
	modulate = Color.WHITE
