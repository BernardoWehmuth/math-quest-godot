extends Control

# --- 1. Referências da Cena ---
@onready var opcoes_container = $ContainerOpcoes
@onready var feedback_label = $FeedbackLabel
@onready var proximo_nivel_btn = $BotaoProximoNivel
@onready var botao_verificar = $BotaoVerificar
@onready var label_verificar = $LabelVerificar
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
@onready var dica = $Dica

# --- 2. Variáveis de Estado ---
var selected_value: int = -1
var selected_source_node = null
var highlight_color = Color.YELLOW

# --- 3. Setup Inicial ---
func _ready():
	proximo_nivel_btn.pressed.connect(gerar_equacoes)
	if not botao_verificar.is_connected("pressed", _on_verificar_pressed):
		botao_verificar.pressed.connect(_on_verificar_pressed)
	
	for slot in [slot_x, slot_y, slot_z]:
		if not slot:
			push_error("Um dos slots não foi encontrado!")
			continue
			
		var SINAL_SLOT = "slot_pressionado"
		
		# Apenas conecta SE AINDA NÃO ESTIVER CONECTADO.
		if not slot.is_connected(SINAL_SLOT, _on_slot_pressed):
			slot.connect(SINAL_SLOT, _on_slot_pressed)

	gerar_equacoes()

# --- 4. Lógica Principal (Gerador) ---
func gerar_equacoes():
	feedback_label.text = "     Toque no valor e depois no local..."
	proximo_nivel_btn.hide()
	botao_verificar.hide()
	label_verificar.hide()
	
	clear_selection()
	
	for box in [box_x, box_y, box_z]:
		box.hide()
	for label in [equacao_label_1, equacao_label_2, equacao_label_3]:
		label.hide()
		
	for slot in [slot_x, slot_y, slot_z]:
		if slot.has_method("set_empty"):
			slot.set_empty()
		slot.modulate = Color.WHITE
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
	var teto_respostas_falsas = 10

	while respostas_falsas.size() < num_respostas_falsas:
		var falsa = randi_range(1, teto_respostas_falsas)
		if not falsa in respostas_corretas_unicas and not falsa in respostas_falsas:
			respostas_falsas.append(falsa)
			
	var todas_opcoes = respostas_corretas_unicas + respostas_falsas
	todas_opcoes.shuffle()
	
	for j in range(opcoes_nodes.size()):
		var option_node = opcoes_nodes[j]
		var valor_opcao = todas_opcoes[j]

		if option_node.has_method("reset_option"):
			option_node.reset_option(valor_opcao)
		
		var SINAL_OPCAO = "opcao_pressionada"
		
		# Apenas conecta SE AINDA NÃO ESTIVER CONECTADO.
		if not option_node.is_connected(SINAL_OPCAO, _on_option_pressed):
			option_node.connect(SINAL_OPCAO, _on_option_pressed)


# --- 5. Geradores de Nível ---
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
	box_x.show()
	box_y.show()
	equacao_label_1.show()
	equacao_label_2.show()

	var x = randi_range(1, 9)
	var y = randi_range(1, 9)

	# Impede x = y (apenas para deixar as opções sempre únicas visualmente)
	while y == x:
		y = randi_range(1, 9)

	# Primeira equação
	var c1 = x + y
	equacao_label_1.text = "x + y = %d" % c1

	# Segunda equação – garantir que a != b para solução única
	var a = randi_range(2, 5)
	var b = randi_range(2, 5)
	while b == a:
		b = randi_range(2, 5)

	# Agora é matematicamente impossível ter múltiplas soluções
	var c2 = (a * x) + (b * y)
	equacao_label_2.text = "%d x + %d y = %d" % [a, b, c2]

	# Respostas certas
	slot_x.set_meta("resposta_correta", x)
	slot_y.set_meta("resposta_correta", y)

	return [x, y]


func gerar_nivel_3() -> Array:
	dica.show()
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

# --- 6. Lógica de Verificação ---
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
		feedback_label.text = "             Parabéns! Todas corretas!"
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
		feedback_label.text = "     Toque no valor e depois no local..."
		for slot in slots_a_checar:
			slot.modulate = Color.WHITE

# --- 7. Lógica de Toque ---
func _on_slot_pressed(slot_node):
	var label_resposta = slot_node.get_node_or_null("LabelResposta")
	if not label_resposta: 
		return 
	
	var slot_esta_vazio = (label_resposta.text == "?")
	
	# Se já tem um valor selecionado (vindo de uma opção)
	if selected_value != -1 and selected_source_node in opcoes_container.get_children():
		# Se o slot destino não está vazio, devolve o valor antigo
		if not slot_esta_vazio:
			var valor_antigo = int(label_resposta.text)
			_devolver_valor_para_opcao(valor_antigo)
		
		# Coloca o valor selecionado no slot
		label_resposta.text = str(selected_value)
		selected_source_node.hide()
		clear_selection()
		
		if check_all_slots_filled():
			botao_verificar.show()
			label_verificar.show()
		else:
			botao_verificar.hide()
			label_verificar.hide()
	
	# Se não tem valor selecionado e o slot não está vazio
	# Clicou no slot para devolver o valor
	elif selected_value == -1 and not slot_esta_vazio:
		var valor_no_slot = int(label_resposta.text)
		
		# Devolve o valor para as opções
		_devolver_valor_para_opcao(valor_no_slot)
		
		# Limpa o slot
		label_resposta.text = "?"
		
		botao_verificar.hide()
		label_verificar.hide()

func _on_option_pressed(option_node, valor: int):
	# Se já tem algo selecionado, cancela e seleciona o novo
	if selected_value != -1:
		clear_selection()
	
	# Seleciona a opção
	selected_value = valor
	selected_source_node = option_node
	option_node.modulate = highlight_color

func clear_selection():
	if selected_source_node:
		selected_source_node.modulate = Color.WHITE
	selected_value = -1
	selected_source_node = null

func _devolver_valor_para_opcao(valor: int):
	for opcao in opcoes_container.get_children():
		if opcao.get_meta("valor") == valor:
			opcao.show()
			opcao.modulate = Color.WHITE
			break


func _on_botao_dica_pressed() -> void:
	var slots = []
	if box_x.visible: slots.append(slot_x)

	# 1. Procurar slot vazio ou errado
	var slot_para_corrigir = null
	for slot in slots:
		var label_resposta = slot.get_node_or_null("LabelResposta")
		var correta = int(slot.get_meta("resposta_correta"))

		if not label_resposta:
			continue
		
		var atual = label_resposta.text
		
		# Slot vazio
		if atual == "?":
			slot_para_corrigir = slot
			break
		
		# Slot preenchido mas errado
		if atual != str(correta):
			slot_para_corrigir = slot
			break
	
	# Se todos estão já corretos
	if slot_para_corrigir == null:
		feedback_label.text = "                    A dica ja foi usada!"
		await get_tree().create_timer(1.3).timeout
		feedback_label.text = "       Toque no valor e depois no local..."
		return

	# 2. Preencher com a resposta correta
	var resposta = int(slot_para_corrigir.get_meta("resposta_correta"))
	var label_resposta = slot_para_corrigir.get_node("LabelResposta")
	
	# Se tem um valor errado dentro, devolve para opções
	if label_resposta.text != "?" and label_resposta.text != str(resposta):
		_devolver_valor_para_opcao(int(label_resposta.text))

	label_resposta.text = str(resposta)
	slot_para_corrigir.modulate = Color(0.7, 1, 0.7) # destaque verde leve
	
	# 3. Esconder a opção correspondente
	for opcao in opcoes_container.get_children():
		if opcao.get_meta("valor") == resposta:
			opcao.hide()
			opcao.modulate = Color.WHITE
			break

	# 4. Limpar seleção para evitar conflitos
	clear_selection()

	# 5. Se tudo foi preenchido → mostrar botão de verificar
	if check_all_slots_filled():
		botao_verificar.show()
		label_verificar.show()
