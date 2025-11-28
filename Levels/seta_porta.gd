extends Sprite2D

var porta_alvo: Node2D
@onready var camera := get_tree().get_root().get_node("fase1/Player/Camera2D")
@onready var player := get_tree().get_root().get_node("fase1/Player")
const ROTATION_OFFSET = -PI/2

func _ready():
	match name:
		"SetaPorta1": porta_alvo = get_node("/root/fase1/Porta")
		"SetaPorta2": porta_alvo = get_node("/root/fase1/Porta2")
		"SetaPorta3": porta_alvo = get_node("/root/fase1/Porta3")
		"SetaPorta4": porta_alvo = get_node("/root/fase1/Porta4")

func _process(delta):
	if not porta_alvo: return
	
	# Calcula direção entre o player e a porta
	var dir = player.global_position - porta_alvo.global_position 

	# Rotaciona a seta pra apontar na direção correta
	rotation = dir.angle() + ROTATION_OFFSET

func _on_area_seta_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		queue_free()
