# FeedbackPopup.gd
extends Control

# Tempo que o aviso fica na tela
const TEMPO_EXIBICAO = 1.0 # 1 segundo

@onready var label: Label = $FeedbackLabel

# Função para mostrar a mensagem com a cor correta
func mostrar_aviso(mensagem: String, cor: Color):
	label.text = mensagem
	label.modulate = cor
	self.visible = true
	
	# Pausa por 1 segundo (TEMPO_EXIBICAO)
	await get_tree().create_timer(TEMPO_EXIBICAO).timeout
	
	# Esconde e remove o nó
	self.queue_free()

# Opcional: Para fazer a mensagem desaparecer gradualmente
# func _process(delta):
#     if is_instance_valid(self):
#         self.modulate.a = lerp(self.modulate.a, 0.0, delta * 3.0)
