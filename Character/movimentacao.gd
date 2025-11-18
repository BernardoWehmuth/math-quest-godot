extends CanvasLayer

@onready var reliquia1 = $Reliquia1
@onready var reliquia2 = $Reliquia2
@onready var reliquia3 = $Reliquia3
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var caminho_cena = get_tree().current_scene.scene_file_path
	if "fase2.tscn" in caminho_cena:
		reliquia1.show()
	elif "fase3.tscn" in caminho_cena:
		reliquia1.show()
		reliquia2.show()
	elif "fase4.tscn" in caminho_cena:
		reliquia1.show()
		reliquia2.show()
		reliquia3.show()
