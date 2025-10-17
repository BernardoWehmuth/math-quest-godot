extends TouchScreenButton

const QUEST_CENA: PackedScene = preload("res://Quests/Quest 1.tscn") 

var game_manager: Node

func _ready():
	# Encontra o GameManager pelo grupo
	game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager == null:
		push_error("ERRO: GameManager não encontrado.")
	
	pressed.connect(_on_start_quest_pressed)

func _on_start_quest_pressed():
	if game_manager == null or game_manager.quest_ativa:
		return
	hide()

	# 2️⃣ Instancia a quest
	var quest_instance = QUEST_CENA.instantiate()
	get_tree().current_scene.add_child(quest_instance)
	
	# 3️⃣ Conecta ao signal de conclusão
	quest_instance.quest_concluida.connect(_on_quest_concluida)
	
	# 4️⃣ Sinaliza que a quest está ativa
	game_manager.quest_ativa = true


func _on_quest_concluida(sucesso: bool):
	# Mostra o botão de volta
	get_parent().get_parent().get_parent()._ao_concluir_quest(true)
	show()
	# Quest terminou, libera a flag
	game_manager.quest_ativa = false
