extends Label

# Total de portas
const TOTAL_PORTAS := 4

func _ready():
	atualizar_contador()

# Função para atualizar a Label
func atualizar_contador():
	# Pega o valor atual do Difficulty.dificuldade (ou outro contador global)
	var portas_concluidas = Difficulty.dificuldade
	if Difficulty.dificuldade == 0:
		text = " %d  / %d" % [portas_concluidas, TOTAL_PORTAS]
	else:
		text = "%d / %d" % [portas_concluidas, TOTAL_PORTAS]
