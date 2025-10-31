# LevelEquacoes.gd
extends Control

@onready var equacoes_container = $ContainerEquacoes
@onready var opcoes_container = $ContainerOpcoes
@onready var feedback_label = $FeedbackLabel
@onready var proximo_nivel_btn = $BotaoProximoNivel
@onready var botao_verificar = $BotaoVerificar
@onready var label_verificar = $LabelVerificar

func _ready():
	proximo_nivel_btn.pressed.connect(gerar_equacoes)
	botao_verificar.hide()
	label_verificar.hide()
	
	for equacao_row in equacoes_container.get_children():
		var slot_a = equacao_row.get_node("Termo1_Slot")
		var slot_b = equacao_row.get_node("Termo2_Slot")
		
		slot_a.connect("answer_dropped", _on_answer_dropped)
		slot_b.connect("answer_dropped", _on_answer_dropped)
		
	gerar_equacoes()

func gerar_equacoes():
	feedback_label.text = "           Arraste o valor de x para a equação..."
	proximo_nivel_btn.hide()
	botao_verificar.hide()
	label_verificar.hide()
	
	var respostas_corretas = []
	var respostas_falsas = []
	
	var equacoes = equacoes_container.get_children()
	
	for i in range(equacoes.size()):
		var equacao_row = equacoes[i]
		
		var label_a = equacao_row.get_node("Termo1_Label")
		var slot_a = equacao_row.get_node("Termo1_Slot")
		var op_label = equacao_row.get_node("Op")
		var label_b = equacao_row.get_node("Termo2_Label")
		var slot_b = equacao_row.get_node("Termo2_Slot")
		var resultado_label = equacao_row.get_node("Resultado")
		
		var a : int
		var b : int
		var c : int
		var op_simbolo : String

		match i:
			0: 
				a = randi_range(1, 10); b = randi_range(1, 10); c = a + b; op_simbolo = "+"
			1: 
				a = randi_range(5, 15); b = randi_range(1, a - 1); c = a - b; op_simbolo = "-"
			2: 
				a = randi_range(2, 9); b = randi_range(2, 9); c = a * b; op_simbolo = "×"
			3: 
				c = randi_range(2, 9); b = randi_range(2, 9); a = b * c; op_simbolo = "÷"
		
		var resposta_correta = 0
		var slot_ativo = null

		for slot in [slot_a, slot_b]:
			slot.get_node("LabelResposta").text = "x"
			slot.modulate = Color.WHITE
			slot.set_meta("resposta_correta", null)
			if slot.has_method("set_empty"):
				slot.set_empty()
		
		op_label.text = op_simbolo
		
		if randf() > 0.5:
			label_a.hide(); slot_a.show(); label_b.show(); slot_b.hide()
			label_b.text = str(b); resultado_label.text = str(c)
			resposta_correta = a; slot_ativo = slot_a
		else:
			label_a.show(); slot_a.hide(); label_b.hide(); slot_b.show()
			label_a.text = str(a); resultado_label.text = str(c)
			resposta_correta = b; slot_ativo = slot_b
			
		slot_ativo.set_meta("resposta_correta", resposta_correta)
		respostas_corretas.append(resposta_correta)

	while respostas_falsas.size() < 4:
		var falsa = randi_range(1, 15)
		if not falsa in respostas_corretas and not falsa in respostas_falsas:
			respostas_falsas.append(falsa)
			
	var todas_opcoes = respostas_corretas + respostas_falsas
	todas_opcoes.shuffle()
	
	var opcoes_nodes = opcoes_container.get_children()
	for j in range(opcoes_nodes.size()):
		if opcoes_nodes[j].has_method("reset_option"):
			opcoes_nodes[j].reset_option(todas_opcoes[j])

func _on_answer_dropped(slot_que_recebeu):
	slot_que_recebeu.modulate = Color.WHITE
	
	var all_filled = check_all_slots_filled()
	if not all_filled:
		botao_verificar.hide()
		label_verificar.hide()
	else:
		botao_verificar.show()
		label_verificar.show()

func check_all_slots_filled() -> bool:
	for equacao_row in equacoes_container.get_children():
		var slot_a = equacao_row.get_node("Termo1_Slot")
		var slot_b = equacao_row.get_node("Termo2_Slot")
		var slot_ativo = slot_a if slot_a.visible else slot_b
		
		var label_resposta = slot_ativo.get_node("LabelResposta")
		
		if label_resposta.text == "x":
			return false
	
	return true

func _on_verificar_pressed():
	
	var todas_estao_corretas = true
	
	for equacao_row in equacoes_container.get_children():
		var slot_a = equacao_row.get_node("Termo1_Slot")
		var slot_b = equacao_row.get_node("Termo2_Slot")
		var slot_ativo = slot_a if slot_a.visible else slot_b
		
		var correta = slot_ativo.get_meta("resposta_correta")
		var label_resposta = slot_ativo.get_node("LabelResposta")
		
		if label_resposta.text == "x":
			todas_estao_corretas = false
			slot_ativo.modulate = Color.WHITE
			continue
			
		var recebida = int(label_resposta.text)
		
		if correta == recebida:
			slot_ativo.modulate = Color.GREEN
		else:
			slot_ativo.modulate = Color.RED
			todas_estao_corretas = false
		
	if todas_estao_corretas:
		feedback_label.text = "                     Parabéns! Todas corretas!"
		proximo_nivel_btn.show()
		botao_verificar.hide()
		label_verificar.hide()
		SignalConcluido.emit_signal("concluido")
	else:
		feedback_label.text = "Ops! Alguma resposta está errada. Tente de novo."
		await get_tree().create_timer(1.5).timeout
		feedback_label.text = "               Arraste o valor de x para a equação..."
		for equacao_row in equacoes_container.get_children():
			var slot_a = equacao_row.get_node("Termo1_Slot")
			var slot_b = equacao_row.get_node("Termo2_Slot")
			var slot_ativo = slot_a if slot_a.visible else slot_b
			slot_ativo.modulate = Color.WHITE
