extends Node2D

@export var forca_vento: float = 600.0
@export var direcao: Vector2 = Vector2.UP
@onready var area = $Area2D

func _ready():
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"): # garante que só afeta o player
		body.add_to_group("sendo_empurrado_por_vento")
		body.set_meta("forca_vento", forca_vento)
		body.set_meta("direcao_vento", direcao)

func _on_body_exited(body):
	if body.is_in_group("player"):
		body.remove_from_group("sendo_empurrado_por_vento")
		body.set_meta("forca_vento", null)
		body.set_meta("direcao_vento", null)
