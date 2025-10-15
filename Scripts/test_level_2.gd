extends Node2D

func _on_botao_proxima_pressed():
	# Troca para a cena principal do jogo
	get_tree().change_scene_to_file("res://Levels/TitleScreen.tscn")
