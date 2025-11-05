extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if get_tree().get_current_scene().get_name() == "fase1":
			body.global_position = Vector2(193, 60)
		elif get_tree().get_current_scene().get_name() == "Fase3":
			body.global_position = Vector2(42, 275)
