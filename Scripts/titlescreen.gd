extends Node2D

func _on_botao_jogar_pressed():
	# Troca para a cena principal do jogo
	get_tree().change_scene_to_file("res://Levels/cenainicial.tscn")

func _on_botao_sair_pressed():
	# Sai do app no celular
	get_tree().quit()
