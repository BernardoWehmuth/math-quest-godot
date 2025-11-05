extends Node2D

@onready var porta_entrada = $PortaEntrada

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	porta_entrada.play("fechando")
	await get_tree().create_timer(1.5).timeout
	porta_entrada.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
