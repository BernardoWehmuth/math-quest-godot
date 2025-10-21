extends Node2D

var quest_count = 0

var quest_ativa = false
const QUEST_CENA = preload("res://Quests/Quest 1.tscn")
var jogador: CharacterBody2D = null # Tipagem opcional para segurança
var camera: Camera2D = null
@onready var label_contador = $Player/Camera2D/CanvasLayer/CanvasLayer/Label
@onready var sprite_porta = $SpritePorta
var voltando: bool = false
var entrou = true
var variavel_local_entrou = 0

func _ready():
	sprite_porta.play("opened")
	jogador = get_tree().get_first_node_in_group("player")
	camera = jogador.find_child("Camera2D") # Ajuste o nome "Camera2D" se for diferente
	if camera == null:
		push_error("ERRO: Camera2D não encontrada para anexar a quest!")
	# Encontra o jogador ao iniciar
	if jogador == null:
		push_error("ERRO: O Personagem Jogável não foi adicionado ao grupo 'player'.")

# ... (Sua função _on_click_area_input_event que chama iniciar_quest) ...

func iniciar_quest():
	entrou = false
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
	quest_ativa = true
	
	
	get_tree().root.add_child(quest_instance)

func _ao_concluir_quest(sucesso: bool):
	
	sprite_porta.play("opening")
	while true:
		await get_tree().create_timer(1.0).timeout
		if GettingBack.gettingBack == true:
			await get_tree().create_timer(1.0).timeout
			quest_ativa = false
			jogador.position = Vector2(LastPosition.player_position)
			label_contador.atualizar_contador()
			sprite_porta.play("opened")
			GettingBack.gettingBack = false
			break
			entrou = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GettingBack.gettingBack = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	GettingBack.gettingBack = false
	if entrou == true:
		if ContadorEntrada.entrada == variavel_local_entrou + 1:
			variavel_local_entrou += 1
			sprite_porta.play("closing")
				
			
