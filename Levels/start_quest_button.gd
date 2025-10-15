# StartQuestTouchButton.gd
extends TouchScreenButton

# Pré-carrega a cena da missão
const MULTIPLICATION_QUEST_CENA = preload("res://Quests/Quest 2.tscn")

func _ready():
	# Certifique-se de que o sinal 'pressed' está conectado no editor, ou faça a conexão aqui:
	pressed.connect(_on_start_quest_touch_button_pressed)

# StartQuestTouchButton.gd

func _on_start_quest_touch_button_pressed():
	# 1. Desativa a escuta de input e esconde o botão que foi clicado
	set_process_input(false)
	hide() # Esconde o TouchScreenButton

	var level_root = get_parent() 
	
	# Encontra o Label que será a Pergunta (Label/Label2)
	var label_da_pergunta: Label = level_root.get_node("Label/Label2")
	
	# 2. Instancia a Quest
	var quest_instance = MULTIPLICATION_QUEST_CENA.instantiate()

	if label_da_pergunta != null:
		# Passa a referência para a Quest, que irá preencher e chamar o .show()
		quest_instance.setup_quest_ui(label_da_pergunta)
		
		# [NOVO AQUI]: Esconde o Label principal que contém o texto de 'iniciar quest'
		var label_pai: Control = level_root.get_node("Label") 
		
			 # Esconde o nó pai "Label" (se ele tem o texto de 'iniciar')

	# ... (adiciona a quest)
	get_tree().current_scene.add_child(quest_instance)
