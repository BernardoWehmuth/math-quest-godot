extends Node2D

@onready var label_texto = $label_texto
@onready var label_design = $label_design
@onready var seta_botao = $seta/TouchScreenButton
@onready var seta_sprite = $seta
@onready var colisao_personagem = $CharacterBody2D/CollisionShape2D
@onready var botao_personagem = $CharacterBody2D/TouchScreenButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_texto.hide()
	label_design.hide()
	seta_botao.hide()
	seta_sprite.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		await get_tree().create_timer(0.5).timeout 
		get_tree().change_scene_to_file("res://Levels/fase1.tscn")


func _on_seta_screen_button_pressed() -> void:
	label_texto.hide()
	label_design.hide()
	seta_botao.hide()
	seta_sprite.hide()
	colisao_personagem.queue_free()


func _on_personagem_screen_button_pressed() -> void:
	label_texto.show()
	label_design.show()
	seta_botao.show()
	seta_sprite.show()
	botao_personagem.hide()
