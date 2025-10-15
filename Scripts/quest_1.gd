# QuestMatematica.gd
extends Control

# Variáveis para a pergunta
var num1: int
var num2: int
var resposta_correta: int
var botoes: Array[TouchScreenButton] = [] # Array para segurar todos os botões
@onready var ui_canvas: CanvasLayer = $CanvasLayer
# Referências dos nós (Ajuste os caminhos!)
@onready var pergunta_label = ui_canvas.get_node("CenterContainer/Panel/OpcoesContainer/PerguntaLabel")
@onready var feedback_label = ui_canvas.get_node("CenterContainer/Panel/OpcoesContainer/FeedbackLabel")
@onready var opcoes_container = ui_canvas.get_node("CenterContainer/Panel/OpcoesContainer") 
@onready var FEEDBACK_POPUP_CENA = preload("res://Quests/FeedbackPopUp.tscn")

signal quest_concluida(sucesso: bool)

func _ready():
	if opcoes_container == null:
		push_error("ERRO: Container de Opções não encontrado. Verifique o caminho!")
		return
		
	botoes.clear() 
	
	# Itera sobre todos os filhos do container e adiciona SOMENTE os botões
	for child in opcoes_container.get_children():
		if child is TouchScreenButton:
			botoes.append(child) 

	if botoes.is_empty():
		push_error("ERRO: Nenhum botão encontrado dentro do OpcoesContainer!")
		return
		
	# Conecta a função de verificação a TODOS os botões
	for botao in botoes:
		# Conecta o signal 'pressed' do TouchScreenButton
		botao.pressed.connect(func(): verificar_resposta(botao))
		
	gerar_pergunta()

func gerar_pergunta():
	# Define a visibilidade inicial
	feedback_label.text = ""
	
	# [CORREÇÃO AQUI]: Simula 'disabled = false' reativando o processamento de input
	for botao in botoes:
		botao.set_process_input(true)
		# Reseta a cor para o estado normal (se mudou de cor antes)
		botao.modulate = Color.WHITE
		
	# 1. Gera a Pergunta
	num1 = randi_range(1, 15)
	num2 = randi_range(1, 15)
	resposta_correta = num1 + num2
	pergunta_label.text = "Quanto é " + str(num1) + " + " + str(num2) + "?"
	
	# 2. Gera Distratores (Respostas Incorretas)
	var opcoes_de_resposta = [resposta_correta]
	
	# Gera 3 respostas incorretas que não sejam a correta
	while opcoes_de_resposta.size() < 4:
		var distrator = resposta_correta + randi_range(-5, 5)
		
		if distrator > 0 and not opcoes_de_resposta.has(distrator):
			opcoes_de_resposta.append(distrator)
			
	# 3. Embaralha as opções
	opcoes_de_resposta.shuffle() 
	
	# 4. Atribui as opções aos botões
	for i in range(botoes.size()):
		# [CORREÇÃO AQUI]: Acessa o nó Label filho para alterar o texto
		var label_filho: Label = botoes[i].get_node("Label") 
		if label_filho != null:
			label_filho.text = str(opcoes_de_resposta[i])
		else:
			push_error("ERRO: Botão não possui nó 'Label'.")

func verificar_resposta(botao_pressionado: TouchScreenButton):
	# [CORREÇÃO AQUI]: Simula 'disabled = true' desativando o processamento de input
	for botao in botoes:
		botao.set_process_input(false)
		
	# [CORREÇÃO AQUI]: Pega o texto do Label do botão pressionado
	var botao_label: Label = botao_pressionado.get_node("Label")
	if botao_label == null:
		push_error("Botão pressionado não possui Label. Não é possível ler a resposta.")
		return

	var resposta_jogador = int(botao_label.text)

	if resposta_jogador == resposta_correta:
		
		_mostrar_feedback_flutuante("CORRETO!", Color.GREEN)
		botao_pressionado.modulate = Color.GREEN 
		await get_tree().create_timer(2.0).timeout 
		quest_concluida.emit(true)
		queue_free()
		
	else:
		# Lógica de ERRO
		_mostrar_feedback_flutuante("ERRADO!", Color.RED)
		botao_pressionado.modulate = Color.RED
		
		await get_tree().create_timer(2.0).timeout 
		
		# Reseta a cor e gera a nova pergunta
		# A cor é resetada em gerar_pergunta(), mas pode ser feito aqui:
		botao_pressionado.modulate = Color.WHITE 
		gerar_pergunta()
		
		# A função gerar_pergunta() já reativa o processamento de input
		
# Função auxiliar para instanciar e mostrar o Pop-up
func _mostrar_feedback_flutuante(mensagem: String, cor: Color):
	var popup = FEEDBACK_POPUP_CENA.instantiate()
	get_tree().root.add_child(popup)
	popup.mostrar_aviso(mensagem, cor)
