# Door.gd
extends Area2D

# Variáveis do Status (configuradas pelo Gerenciador da Missão)
var door_answer: int = 0
var is_correct_answer: bool = false

# [MUDANÇA AQUI]: Removemos o @onready. A busca será manual.
var answer_label: Label
@onready var selection_timer: Timer = $SelectionTimer

# Sinal emitido para o Gerenciador da Missão quando o tempo acaba
signal door_selected(is_correct: bool)

# =================================================================
# 1. SETUP: Recebe a configuração do Gerenciador
# =================================================================

func setup_door(answer: int, is_correct: bool):
	"""Recebe e configura a resposta e o status de correção desta porta."""
	door_answer = answer
	is_correct_answer = is_correct
	
	# [AÇÃO CHAVE]: Força a busca do Label APENAS UMA VEZ
	if answer_label == null:
		# Tenta achar o Label. Se não encontrar, retorna null (sem erro de crash)
		answer_label = get_node_or_null("Label")
	
	# Verificação de segurança:
	if answer_label != null:
		# Se encontrou, atualiza o texto
		answer_label.text = str(answer)
	else:
		# Se este erro aparecer, o Label na Door.tscn está com o nome errado
		push_error("ERRO CRÍTICO: Não encontrei o nó 'Label' em Door.tscn!")
		
	modulate = Color.WHITE
	set_monitoring(true)

# ... (o restante das funções é o mesmo)
func _ready():
	pass
	
func _on_body_entered(body: Node2D):
	"""Começa a contagem de 3 segundos quando o jogador entra."""
	if body.is_in_group("player"):
		modulate = Color.YELLOW # Feedback visual: Seleção em andamento
		selection_timer.start()

func _on_body_exited(body: Node2D):
	"""Cancela a contagem se o jogador sair antes do tempo."""
	if body.is_in_group("player"):
		selection_timer.stop()
		modulate = Color.WHITE # Retorna à cor normal

# =================================================================
# 3. VERIFICAÇÃO: Ação no Fim do Timer
# =================================================================

func _on_selection_timer_timeout():
	"""Chamado quando o tempo de 3 segundos termina."""
	
	# Desativa a porta para que não possa ser selecionada novamente
	set_monitoring(false)
	
	# Feedback visual final
	if is_correct_answer:
		modulate = Color.GREEN
	else:
		modulate = Color.RED
		
	# Emite o sinal para o Gerenciador da Missão
	door_selected.emit(is_correct_answer)
