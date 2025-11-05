# Script: quest_3.gd
extends Control

# --- 1. Referências da Cena ---
@onready var opcoes_container = $ContainerOpcoes
@onready var feedback_label = $FeedbackLabel
@onready var proximo_nivel_btn = $BotaoProximoNivel
@onready var botao_verificar = $BotaoVerificar
@onready var label_verificar = $LabelVerificar

# Caminhos atualizados
@onready var box_x = $BoxX
@onready var box_y = $BoxY
@onready var box_z = $BoxZ

@onready var slot_x = $BoxX/SlotX 
@onready var slot_y = $BoxY/SlotY
@onready var slot_z = $BoxZ/SlotZ

@onready var container_equacoes = $ContainerEquacoes
@onready var equacao_label_1 = $ContainerEquacoes/EquacaoLabel1
@onready var equacao_label_2 = $ContainerEquacoes/EquacaoLabel2
@onready var equacao_label_3 = $ContainerEquacoes/EquacaoLabel3

# --- 2. Setup Inicial ---
func _ready():

	proximo_nivel_btn.pressed.connect(gerar_equacoes)
	if not botao_verificar.is_connected("pressed", _on_verificar_pressed):
		botao_verificar.pressed.connect(_on_verificar_pressed)
	
	for slot in [slot_x, slot_y, slot_z]:
		if not slot:
			push_error("Um dos slots (slot_x, slot_y, slot_z) não foi encontrado! Verifique os caminhos.")
			continue
			
		if slot.has_signal("answer_dropped"):
			slot.connect("answer_dropped", _on_answer_dropped)
		else:
			push_warning("Slot não tem o sinal 'answer_dropped'.")

		if slot.has_signal("valor_liberado"):
			slot.connect("valor_liberado", _on_valor_liberado)
		else:
			push_warning("Slot não tem o sinal 'valor_liberado'.")

	gerar_equacoes()

# --- 3. Lógica Principal (Gerador) ---
func gerar_equacoes():
	# ... (toda a primeira parte do 'gerar_equacoes' é igual) ...
	feedback_label.text = "       Arraste os valores para as incógnitas..."
	proximo_nivel_btn.hide()
	botao_verificar.hide()
	label_verificar.hide()
	
	for box in [box_x, box_y, box_z]:
		box.hide() 
	for label in [equacao_label_1, equacao_label_2, equacao_label_3]:
		label.hide() 
		
	for slot in [slot_x, slot_y, slot_z]:
		if slot.has_method("set_empty"):
			slot.set_empty()
		
		slot.modulate = Color.WHITE
		var label_resposta = slot.get_node_or_null("LabelResposta")
		if label_resposta:
			label_resposta.text = "?"
		slot.set_meta("resposta_correta", null)
		
	var respostas_corretas_unicas = []
	
	match Difficulty.dificuldade:
		0:
			respostas_corretas_unicas = gerar_nivel_1()
		1:
			respostas_corretas_unicas = gerar_nivel_2()
		2:
			respostas_corretas_unicas = gerar_nivel_3()
		_:
			respostas_corretas_unicas = gerar_nivel_1()

	# --- Geração de Opções ---
	var respostas_falsas = []
	var opcoes_nodes = opcoes_container.get_children()
	var num_total_opcoes = opcoes_nodes.size()
	var num_respostas_falsas = num_total_opcoes - respostas_corretas_unicas.size()

	# --- CORREÇÃO ---
	# O valor correto mais alto possível é 9 (dos níveis 1 e 2).
	# Vamos definir o teto dos números falsos para 10 (ou 12), em vez de 15.
	# Isso torna os números falsos mais "críveis".
	var teto_respostas_falsas = 10

	while respostas_falsas.size() < num_respostas_falsas:
		# Usa o novo teto mais baixo
		var falsa = randi_range(1, teto_respostas_falsas) 
		
		# Garante que a resposta falsa não seja uma das corretas
		# e também que não seja repetida
		if not falsa in respostas_corretas_unicas and not falsa in respostas_falsas:
			respostas_falsas.append(falsa)
	# --- FIM DA CORREÇÃO ---
			
	var todas_opcoes = respostas_corretas_unicas + respostas_falsas
	todas_opcoes.shuffle()
	
	for j in range(opcoes_nodes.size()):
		if opcoes_nodes[j].has_method("reset_option"):
			opcoes_nodes[j].reset_option(todas_opcoes[j])
		else:
			var label_valor = opcoes_nodes[j].get_node_or_null("LabelValor")
			if label_valor:
				label_valor.text = str(todas_opcoes[j])
			opcoes_nodes[j].set_meta("valor", todas_opcoes[j])


# --- 4. Geradores de Nível ---
# (As funções gerar_nivel_1, gerar_nivel_2, e gerar_nivel_3
# continuam exatamente iguais a antes)
func gerar_nivel_1() -> Array:
	box_x.show()
	equacao_label_1.show()
	
	var x = randi_range(2, 9)
	var a = randi_range(2, 5)
	var b = randi_range(1, 10)
	var c = (a * x) + b
	
	equacao_label_1.text = "%d x + %d = %d" % [a, b, c]
	
	slot_x.set_meta("resposta_correta", x)
	return [x]

func gerar_nivel_2() -> Array:
	box_x.show(); box_y.show()
	equacao_label_1.show(); equacao_label_2.show()
	
	var x = randi_range(1, 9); var y = randi_range(1, 9)
	while y == x: y = randi_range(1, 9)
		
	var c1 = x + y
	equacao_label_1.text = "x + y = %d" % c1
	
	var a = randi_range(2, 5); var b = randi_range(2, 5)
	var c2 = (a * x) + (b * y)
	equacao_label_2.text = "%d x + %d y = %d" % [a, b, c2]
	
	slot_x.set_meta("resposta_correta", x)
	slot_y.set_meta("resposta_correta", y)
	return [x, y]

func gerar_nivel_3() -> Array:
	box_x.show(); box_y.show(); box_z.show()
	equacao_label_1.show(); equacao_label_2.show(); equacao_label_3.show()
	
	var x = randi_range(1, 6); var y = randi_range(1, 6); var z = randi_range(1, 6)
	while y == x: y = randi_range(1, 6)
	while z == x or z == y: z = randi_range(1, 6)
	
	var c1 = x + y + z
	equacao_label_1.text = "x + y + z = %d" % c1
	
	var a = randi_range(2, 4); var b = randi_range(2, 4)
	var c2 = (a * x) + (b * y)
	equacao_label_2.text = "%d x + %d y = %d" % [a, b, c2]
	
	var a3 = randi_range(1, 3); var b3 = randi_range(2, 4); var c3 = randi_range(1, 3)
	var c3_res = (a3 * x) + (b3 * y) + (c3 * z)
	equacao_label_3.text = "%d x + %d y + %d z = %d" % [a3, b3, c3, c3_res]
	
	slot_x.set_meta("resposta_correta", x)
	slot_y.set_meta("resposta_correta", y)
	slot_z.set_meta("resposta_correta", z)
	return [x, y, z]


# --- 5. Lógica de Verificação ---
# (As funções _on_answer_dropped, check_all_slots_filled,
# e _on_verificar_pressed continuam exatamente iguais a antes)
func _on_answer_dropped(slot_que_recebeu):
	slot_que_recebeu.modulate = Color.WHITE
	
	if check_all_slots_filled():
		botao_verificar.show()
		label_verificar.show()

func check_all_slots_filled() -> bool:
	var slots_a_checar = []
	if box_x.visible: slots_a_checar.append(slot_x)
	if box_y.visible: slots_a_checar.append(slot_y)
	if box_z.visible: slots_a_checar.append(slot_z)

	for slot in slots_a_checar:
		var label_resposta = slot.get_node_or_null("LabelResposta")
		if not label_resposta or label_resposta.text == "?":
			return false
	
	return true

func _on_verificar_pressed():
	var todas_estao_corretas = true
	var slots_a_checar = []
	if box_x.visible: slots_a_checar.append(slot_x)
	if box_y.visible: slots_a_checar.append(slot_y)
	if box_z.visible: slots_a_checar.append(slot_z)

	for slot in slots_a_checar:
		var label_resposta = slot.get_node_or_null("LabelResposta")
		var correta = slot.get_meta("resposta_correta")
		
		if not label_resposta or label_resposta.text == "?":
			todas_estao_corretas = false
			slot.modulate = Color.WHITE
			continue
			
		var recebida = int(label_resposta.text)
		
		if correta == recebida:
			slot.modulate = Color.GREEN
		else:
			slot.modulate = Color.RED
			todas_estao_corretas = false
		
	if todas_estao_corretas:
		feedback_label.text = "                 Parabéns! Todas corretas!"
		await get_tree().create_timer(1.5).timeout 
		proximo_nivel_btn.show()
		botao_verificar.hide()
		label_verificar.hide()
		SignalConcluido.emit_signal("concluido")
		print(Difficulty.dificuldade)
	else:
		feedback_label.text = "Ops! Algum valor está errado. Tente de novo."
		botao_verificar.hide()
		label_verificar.hide()
		await get_tree().create_timer(2.5).timeout
		feedback_label.text = "       Arraste os valores para as incógnitas..."
		
		for slot in slots_a_checar:
			slot.modulate = Color.WHITE

# --- 6. Lógica de "Devolver" Opção ---
# (A função _on_valor_liberado continua exatamente igual a antes)
func _on_valor_liberado(valor: int):
	
	for opcao in opcoes_container.get_children():
		if opcao.get_meta("valor") == valor:
			if opcao.has_method("reset_option"):
				opcao.reset_option(valor)
			break
