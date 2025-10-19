extends Area2D

func _on_body_entered(body: Node2D) -> void:
	# DEBUG CRÍTICO: Este print DEVE aparecer quando você toca o espinho.
	print("SINAL body_entered DISPARADO! Corpo que entrou: ", body.name, " Tipo: ", body.get_class())
	
	if body.is_in_group("player"):
		Difficulty.dificuldade = 0
		get_tree().change_scene_to_file("res://Levels/TitleScreen.tscn")
