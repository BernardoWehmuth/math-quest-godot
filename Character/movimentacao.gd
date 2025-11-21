extends CanvasLayer

@onready var reliquia1 = $Reliquia1
@onready var reliquia2 = $Reliquia2
@onready var reliquia3 = $Reliquia3
@onready var pergaminho = $Pergaminho
@onready var explicacao = $ExplicacaoFase
var caminho_cena
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	caminho_cena = get_tree().current_scene.scene_file_path
	
	if "fase2.tscn" in caminho_cena:
		reliquia1.show()
	elif "fase3.tscn" in caminho_cena:
		reliquia1.show()
		reliquia2.show()
	elif "fase4.tscn" in caminho_cena:
		reliquia1.show()
		reliquia2.show()
		reliquia3.show()


func _on_button_pergaminho_pressed() -> void:
	if "fase1.tscn" in caminho_cena:
		explicacao.play("fase1")
		explicacao.show()
		pergaminho.hide()
	elif "fase3.tscn" in caminho_cena:
		explicacao.play("fase3")
		explicacao.show()
		pergaminho.hide()

func _on_button_explicacao_pressed() -> void:
	explicacao.hide()
	pergaminho.show()
