extends Node2D

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://Levels/vila.tscn")


func _on_touch_screen_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/vila.tscn")
