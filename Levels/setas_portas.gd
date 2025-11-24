extends Node

@onready var camera = get_viewport().get_camera_2d()

@onready var seta1 = $SetaPorta1
@onready var seta2 = $SetaPorta2
@onready var seta3 = $SetaPorta3
@onready var seta4 = $SetaPorta4

@onready var porta1 = get_tree().get_root().get_node("fase1/Porta")
@onready var porta2 = get_tree().get_root().get_node("fase1/Porta2")
@onready var porta3 = get_tree().get_root().get_node("fase1/Porta3")
@onready var porta4 = get_tree().get_root().get_node("fase1/Porta4")

func _process(delta):
	_atualizar_seta(seta1, porta1)
	_atualizar_seta(seta2, porta2)
	_atualizar_seta(seta3, porta3)
	_atualizar_seta(seta4, porta4)

func _atualizar_seta(seta: Node2D, porta: Node2D):
	if not porta or not seta or not camera:
		return

	# posição da porta no mundo → para coordenada de tela
	var porta_tela = camera.global_to_screen(porta.global_position)

	# seta olha para a posição da porta em coordenadas de tela
	seta.look_at(porta_tela)
