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
@onready var porta_prox_fase = $PortaProxFase
@onready var area_porta_prox_fase = $PortaProxFase/AreaPortaProxFase
@onready var label_prox_fase = $Player/Camera2D/CanvasLayer/LabelPortaProx
@onready var porta_entrada = $PortaEntrada

func _ready():
	porta_entrada.play("fechando")
	await get_tree().create_timer(1.0).timeout
	porta_entrada.queue_free()
	porta_prox_fase.play("fechada")
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

@warning_ignore("unused_parameter")
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
	if Difficulty.dificuldade == 4:
		label_contador.modulate = Color.GREEN


@warning_ignore("unused_parameter")
func _on_area_2d_body_exited(body: Node2D) -> void:
	GettingBack.gettingBack = false
	if entrou == true:
		if ContadorEntrada.entrada == variavel_local_entrou + 1:
			variavel_local_entrou += 1
			sprite_porta.play("closing")
				

@warning_ignore("unused_parameter")
func porta_saida(body: Node2D) -> void:
	if Difficulty.dificuldade == 4:
		porta_prox_fase.play("aberta")
		await get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_file("res://Levels/fase2.tscn")
	else:
		label_prox_fase.show()
		await get_tree().create_timer(3.5).timeout
		label_prox_fase.hide()
