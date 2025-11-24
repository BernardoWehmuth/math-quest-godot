extends Sprite2D

var porta_alvo: Node2D
@onready var camera := get_viewport().get_camera_2d()

func _ready():
	match name:
		"SetaPorta1":
			porta_alvo = get_tree().get_root().get_node("fase1/Porta")
		"SetaPorta2":
			porta_alvo = get_tree().get_root().get_node("fase1/Porta2")
		"SetaPorta3":
			porta_alvo = get_tree().get_root().get_node("fase1/Porta3")
		"SetaPorta4":
			porta_alvo = get_tree().get_root().get_node("fase1/Porta4")


func _process(delta):
	if porta_alvo == null:
		return
	if camera == null:
		return

	# posição global da porta (mundo)
	var pos_global = porta_alvo.global_position

	# CONVERSÃO CORRETA NO GODOT 4
	var pos_tela = get_viewport().get_canvas_transform() * porta_alvo.global_position

	# Atualiza posição da seta (CanvasLayer usa tela!)
	position = pos_tela

	# Rotação correta na HUD
	var dir = pos_tela - position
	rotation = dir.angle()
