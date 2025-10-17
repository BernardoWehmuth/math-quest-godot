extends Node2D

var quest_count = 0

var quest_ativa = false
const QUEST_CENA = preload("res://Quests/Quest 1.tscn")
var jogador: CharacterBody2D = null # Tipagem opcional para segurança
var camera: Camera2D = null

func _ready():
	jogador = get_tree().get_first_node_in_group("player")
	camera = jogador.find_child("Camera2D") # Ajuste o nome "Camera2D" se for diferente
	if camera == null:
		push_error("ERRO: Camera2D não encontrada para anexar a quest!")
	# Encontra o jogador ao iniciar
	if jogador == null:
		push_error("ERRO: O Personagem Jogável não foi adicionado ao grupo 'player'.")

# ... (Sua função _on_click_area_input_event que chama iniciar_quest) ...

func iniciar_quest():
	if quest_ativa or jogador == null or camera == null:
		return

	# ... (bloqueia o input, etc.) ...

	var quest_instance = QUEST_CENA.instantiate()
	quest_instance.quest_concluida.connect(_ao_concluir_quest)

	# >>> NOVO PASSO: Adiciona a quest como filho da câmera <<<
	camera.add_child(quest_instance) 

	# Opcional: Garante que a quest está no centro da view da câmera
	# quest_instance.global_position = camera.global_position
	# *Note: O CenterContainer deve fazer a centralização visual.

	# >>> 1. BLOQUEIA O MOVIMENTO DO JOGADOR <<<
	jogador.bloquear_input()

	quest_ativa = true
	
	
	get_tree().root.add_child(quest_instance)

func _ao_concluir_quest(sucesso: bool):
	quest_ativa = false

	# >>> 2. LIBERA O MOVIMENTO DO JOGADOR <<<
	if jogador != null:
		jogador.liberar_input() 
		
	if sucesso:
		quest_count += 1
	else:
		print("Anubis: Ah, que pena. Tente novamente!")
