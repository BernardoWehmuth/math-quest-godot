extends Area2D

@onready var animated_sprite = $AnimatedSprite2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") && Difficulty.dificuldade == 4:
		animated_sprite.play("explosao")
		await get_tree().create_timer(0.5).timeout
		animated_sprite.hide()
