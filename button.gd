extends Button

func _on_botao_jogar_pressed():
	# Troca para a cena principal do jogo
	get_tree().change_scene_to_file("res://Levels/test_level.tscn")
