# MultiplicationQuest.gd
extends Node2D

# Variáveis do Puzzle
var num1: int
var num2: int
var resposta_correta: int

# [MUDANÇA AQUI]: Não é mais @onready. A referência é passada de fora.
var pergunta_label: Label 

@onready var doors_parent: Node2D
@onready var doors: Array[Area2D] = []

# ATENÇÃO: Defina os caminhos para as transições de cena
const NEXT_LEVEL_PATH = "res://Levels/test_level.tscn"
const QUEST_SCENE_PATH = "res://Levels/test_level2.tscn"


# [NOVA FUNÇÃO]: Recebe a referência do Label do Level e inicia a Quest
func setup_quest_ui(label_externo: Label):
	pergunta_label = label_externo
	# [CORREÇÃO FINAL]: Encontra o nó $Portas AQUI, garantindo que ele exista
	doors_parent = $Portas
	
	# Verificação de segurança (Se o erro for aqui, o nome do nó $Portas está errado)
	if doors_parent == null:
		push_error("ERRO CRÍTICO: O nó $Portas não foi encontrado na Quest!")
		return
	# Coleta as portas (movido do _ready)
	for child in doors_parent.get_children():
		if child.is_in_group("door"): 
			doors.append(child)
			child.door_selected.connect(_on_door_selected)
			
	if doors.is_empty():
		push_error("ERRO: Nenhuma porta encontrada no doors_parent.")
		return
		
	# Inicia a missão com o Label pronto para uso
	gerar_pergunta()


func _ready():
	# O _ready agora serve apenas para verificar se o setup foi feito, se for necessário.
	# A lógica principal de inicialização foi para setup_quest_ui.
	pass # Deixe o _ready() limpo, pois ele será chamado antes de setup_quest_ui


func gerar_pergunta():
	# Só executa se o Label foi passado com sucesso
	if pergunta_label == null:
		push_error("ERRO: Label da pergunta não foi passado pelo botão de iniciar!")
		return

	# 1. Gera a Pergunta
	num1 = randi_range(3, 9)
	num2 = randi_range(3, 9)
	resposta_correta = num1 * num2
	
	# [AÇÃO CHAVE]: Atualiza o texto do Label do level
	pergunta_label.text = "  
	  Quanto é " + str(num1) + " x " + str(num2) + "?"
	pergunta_label.show() # Garante que o Label apareça
	
	# Reativa as portas para nova interação
	for door in doors:
		door.set_monitoring(true)
		door.modulate = Color.WHITE
		
	# 2. Gera Distratores (Respostas Incorretas)
	var opcoes_de_resposta = [resposta_correta]
	
	while opcoes_de_resposta.size() < doors.size():
		var distrator = resposta_correta + randi_range(-5, 5)
		
		if distrator > 0 and not opcoes_de_resposta.has(distrator):
			opcoes_de_resposta.append(distrator)
			
	opcoes_de_resposta.shuffle()
	
	# 3. Configura e Exibe as Opções nas Portas
	for i in range(doors.size()):
		var answer = opcoes_de_resposta[i]
		var is_correct = (answer == resposta_correta)
		
		doors[i].setup_door(answer, is_correct)

# --- Lógica de Fim de Missão ---

func _on_door_selected(is_correct: bool):
	for door in doors:
		door.set_monitoring(false)
		
	if is_correct:
		print("Correto! Passando de fase.")
		await get_tree().create_timer(1.0).timeout 
		passar_de_fase()
	else:
		print("Errado! Recomeçando a missão.")
		await get_tree().create_timer(1.0).timeout 
		recomecar_missao()

func passar_de_fase():
	# Antes de mudar de cena, LIMPA o Label para a próxima vez
	if pergunta_label != null:
		pergunta_label.text = "" 
		pergunta_label.hide()
		
	# Altera para a próxima cena (Sucesso)
	get_tree().change_scene_to_file(NEXT_LEVEL_PATH)

func recomecar_missao():
	# Antes de mudar de cena, LIMPA o Label
	if pergunta_label != null:
		pergunta_label.text = ""
		pergunta_label.hide() 
	
	# Recarrega a cena atual (Falha)
	get_tree().change_scene_to_file(QUEST_SCENE_PATH)
