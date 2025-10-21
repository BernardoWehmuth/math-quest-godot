# Balanca.gd
extends Node2D

# Sinal de vitória
signal equilibrada

# --- Configuração ---
@export var peso_alvo_pena: int = 1 # O valor que você quer que o jogador alcance

# --- Estado do Puzzle ---
@onready var balanca_sprite = $BalancaSprite
var peso_atual: int = 0
var esta_equilibrada: bool = false

# A "Pilha" de caixas. Vamos guardar a REFERÊNCIA da caixa original
var pilha_de_caixas: Array[Node] = []

func _ready():
	balanca_sprite.play("diretaheavy")
	_verificar_equilibrio()


func _on_area_remover_input_event(viewport, event, shape_idx):
	if event.is_action_pressed() and event.is_pressed():
		remover_ultima_caixa()

func remover_ultima_caixa():
	# 1. Verifica se a pilha não está vazia
	if pilha_de_caixas.is_empty():
		print("Pilha vazia, nada a remover.")
		return

	# 2. Pega a última caixa que foi adicionada (LIFO)
	var caixa_removida = pilha_de_caixas.pop_back()
	
	# 3. Devolve o peso
	peso_atual -= caixa_removida.valor_peso
	print("Peso atual: ", peso_atual)

	# 4. "Reativa" a caixa original no cenário
	caixa_removida.reativar()
	
	# 6. Verifica o estado da balança
	_verificar_equilibrio()

# Esta função apaga e redesenha os sprites na pilha

# Esta função atualiza o estado e a rotação alvo
func _verificar_equilibrio():
	var diferenca = peso_atual - peso_alvo_pena
	
	if diferenca < 0:
		# DESEQUILIBRADO
		esta_equilibrada = false
		balanca_sprite.play("diretaheavy")
	elif diferenca > 0:
		# DESEQUILIBRADO
		esta_equilibrada = false
		balanca_sprite.play("esquerdaheavy")
	else:
	# EQUILIBRADO
		if not esta_equilibrada:
			esta_equilibrada = true
			balanca_sprite.play("igual")
			print("Balança Equilibrada!")
