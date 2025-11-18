extends Node2D

@onready var explicacao_pergaminho = $Player/Camera2D/Canvas_layer/Explicacao_Fase
@onready var pergaminho_coletavel = $Pergaminho
@onready var anim_pergaminho_seta = $Pergaminho/AnimatedSprite2D

@onready var porta_entrada = $PortaEntrada
const quest_3: PackedScene = preload("res://Quests/Quest 3.tscn") 
@onready var tela_quest = $Player/Camera2D/Canvas_layer

@onready var area_reliquia = $AreaReliquia
@onready var reliquia_desc = $Player/Camera2D/ReliquiaDesc

@onready var botao_iniciar = $TouchScreenButton
@onready var label_iniciar_sprite = $Label

@onready var botao_iniciar2 = $TouchScreenButton2
@onready var label_iniciar_sprite2 = $Label2

@onready var botao_iniciar3 = $TouchScreenButton3
@onready var label_iniciar_sprite3 = $Label3

@onready var porta = $Porta/AnimatedSprite2D

@onready var player = $Player
var quest3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_pergaminho_seta.play("idle")
	pergaminho_coletavel.play("idle")
	porta_entrada.play("fechando")
	await get_tree().create_timer(1.5).timeout
	porta_entrada.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_botao_iniciar_button_pressed() -> void:
	if player.is_on_floor():
		if Difficulty.dificuldade == 0:
			quest3 = quest_3.instantiate()
			tela_quest.add_child(quest3)
			SignalConcluido.connect("concluido", Callable(self, "_on_signal_invited"))
			botao_iniciar.hide()
			label_iniciar_sprite.hide()
			player.input_bloqueado = true
		elif Difficulty.dificuldade == 1:
			quest3 = quest_3.instantiate()
			tela_quest.add_child(quest3)
			botao_iniciar2.hide()
			label_iniciar_sprite2.hide()
			player.input_bloqueado = true
		elif Difficulty.dificuldade == 2:
			quest3 = quest_3.instantiate()
			tela_quest.add_child(quest3)
			botao_iniciar3.hide()
			label_iniciar_sprite3.hide()
			player.input_bloqueado = true	
		
func _on_signal_invited():
	Difficulty.dificuldade += 1
	player.input_bloqueado = false
	quest3.queue_free()
	if Difficulty.dificuldade == 3:
		Difficulty.dificuldade = 4


func _on_area_2d_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("player"):
		porta.play("abrindo")
		await get_tree().create_timer(1.5).timeout 
		get_tree().change_scene_to_file("res://Levels/TitleScreen.tscn")


func _on_touch_screen_button_pressed() -> void:
	reliquia_desc.queue_free()
	player.liberar_input()
	Difficulty.dificuldade = 1

func _on_area_reliquia_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") && Difficulty.dificuldade != 1:
		player.bloquear_input()
		await get_tree().create_timer(1.0).timeout 
		reliquia_desc.show()
		
func _on_area_pergaminho_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("player"):
		pergaminho_coletavel.play("sumindo")
		anim_pergaminho_seta.queue_free()
		await get_tree().create_timer(0.5).timeout
		pergaminho_coletavel.queue_free()
		player.bloquear_input()
		explicacao_pergaminho.show()


func _on_button_pressed() -> void:
	explicacao_pergaminho.queue_free()
	player.liberar_input()
