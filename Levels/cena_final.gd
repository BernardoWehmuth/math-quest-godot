extends Control

@onready var video = $VideoStreamPlayer
var proxima_cena = preload("res://Levels/TitleScreen.tscn")

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	video.play()


func _on_video_stream_player_finished() -> void:
	get_tree().change_scene_to_packed(proxima_cena)
