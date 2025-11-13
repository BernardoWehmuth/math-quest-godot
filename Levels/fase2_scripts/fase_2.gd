extends Node2D

# Sinal emitido quando a balança está equilibrada
signal equilibrada

var reliquia_coletada = false
# --- Configuração do Puzzle ---
@export var peso_alvo_pena: float = 1.0
const MAX_CAIXAS_NA_BALANCA = 6

@onready var player = $Player
@onready var sprite_verde = $Sprite_verde
@onready var label_concluido = $Player/Camera2D/CanvasLayer/LabelConcluido
@onready var porta_entrada = $PortaEntrada
@onready var reliquia = $Reliquia
@onready var area_reliquia = $AreaReliquia

# --- Pesos Constantes ---
const PESO_CAIXA_LEVE = 1.0 / 6.0
const PESO_CAIXA_MEIO = 1.0 / 3.0
const PESO_CAIXA_PESADA = 1.0 / 2.0

var x_antigo: float
var y_antigo: float
# --- Escala Constante ---
const ESCALA_CAIXA = Vector2(0.096, 0.105)
const ESCALA_NORMAL = Vector2(0.165, 0.165)

# -----------------------------------------------------------------
# --- Posições Visuais das Caixas na Balança (Suas Posições) ---
# -----------------------------------------------------------------
var posicoes_esquerda_pesado = [
	Vector2(121.259, 66.59), Vector2(107.26, 65.59), Vector2(135.259, 66.589),
	Vector2(114.259, 52.59), Vector2(128.258, 52.59), Vector2(121.0, 39.0)
]
var posicoes_equilibrado = [
	Vector2(108.259, 54.179), Vector2(94.26, 53.18), Vector2(122.259, 54.179),
 	Vector2(101.259, 40.179), Vector2(115.258, 40.179), Vector2(108.0, 26.59)
]
var posicoes_direita_pesado = [
	Vector2(111.259, 25.179), Vector2(97.26, 24.18), Vector2(125.259, 25.179),
	Vector2(104.259, 11.179), Vector2(118.258, 11.179), Vector2(111.0, -2.41)
]

# --- Referências de Nós ---
@onready var balanca_sprite = $"nó balanca/balanca"
@onready var pena_pos = $"nó balanca/pena"
var sprite_caixa: Sprite2D
# --- MUDANÇA AQUI ---
# Removemos a 'area_remover' e adicionamos o 'botao_remover'
# Certifique-se que o nó "BotaoRemover" existe na sua cena!
@onready var botao_remover = $BotaoRemover

@onready var sprite_porta = $ExitDoor/AnimatedSprite2D

var posicao_antiga_ultima_caixa: Vector2
@onready var caixas_leves = [$no_caixa_leve1, $no_caixa_leve2, $no_caixa_leve3, $no_caixa_leve4, $no_caixa_leve5, $no_caixa_leve6]
@onready var caixas_medias = [$no_caixa_meio1, $no_caixa_meio2, $no_caixa_meio3]
@onready var caixas_pesadas = [$no_caixa_pesada1, $no_caixa_pesada2]
@onready var flecha_saida = $Player/Camera2D/CanvasLayer/Flecha

@onready var reliquia_desc = $Player/Camera2D/CanvasLayer/ReliquiaDesc

@onready var label_not_concluido = $Player/Camera2D/CanvasLayer/LabelNotConcluido

# --- Estado do Puzzle ---
var peso_atual: float = 0.0
var esta_equilibrada: bool = false
var pilha_de_caixas: Array[Node2D] = [] # Armazena os NÓS BASE (ex: $no_caixa_leve1)
var posicoes_antigas_caixas_adicionadas: Array[Vector2] = []
var ultima_caixa: Area2D
# ------------------------------------------------
# --- INICIALIZAÇÃO (MODIFICADO) ---
# ------------------------------------------------

func _ready():
	_verificar_equilibrio()
	porta_entrada.play("fechando")
	_conectar_caixas()
	sprite_porta.play("fechada")
	sprite_verde.hide()
	# --- MUDANÇA AQUI ---
	# Conecta o sinal 'pressed' do novo botão diretamente
	# à função de remover a última caixa.
	botao_remover.pressed.connect(_remover_ultima_caixa)
	await get_tree().create_timer(1.5).timeout
	porta_entrada.hide()
	# Define o estado inicial da balança

# ------------------------------------------------
# --- CONEXÕES E INTERAÇÃO ---
# ------------------------------------------------

func _conectar_caixas():
	var todas_as_caixas = caixas_leves + caixas_medias + caixas_pesadas
	
	for caixa: Node2D in todas_as_caixas:
		if caixa.name.begins_with("no_caixa_leve"):
			caixa.set_meta("peso", PESO_CAIXA_LEVE)
		elif caixa.name.begins_with("no_caixa_meio"):
			caixa.set_meta("peso", PESO_CAIXA_MEIO)
		else:
			caixa.set_meta("peso", PESO_CAIXA_PESADA)
			
		var botao: TouchScreenButton = caixa.get_node("Botao")
		if not botao:
			push_warning("Caixa %s não tem um nó 'Botao'!" % caixa.name)
			continue
			
		var sprite: Sprite2D = caixa.get_node("Sprite2D")
		if not sprite:
			push_warning("Caixa %s não tem um nó 'Sprite2D'!" % caixa.name)
			continue
			
		# Garante que a escala inicial esteja correta
		sprite.scale = ESCALA_NORMAL
			
		botao.pressed.connect(_on_caixa_botao_pressed.bind(caixa))

# ------------------------------------------------
# --- AÇÕES DE CLIQUE ---
# ------------------------------------------------

# Esta ÚNICA função é chamada por QUALQUER botão de caixa
func _on_caixa_botao_pressed(caixa: Node2D):
	_adicionar_caixa(caixa)

# --- MUDANÇA AQUI ---

# ------------------------------------------------

# --- ADICIONAR E REMOVER CAIXAS ---

# ------------------------------------------------

func _adicionar_caixa(caixa: Node2D):
	if caixa in pilha_de_caixas:
		return
	if pilha_de_caixas.size() >= MAX_CAIXAS_NA_BALANCA:
		print("Limite máximo de caixas atingido.")
		return

	@warning_ignore("shadowed_variable")
	var sprite_caixa = caixa.get_node("Sprite2D")
	posicoes_antigas_caixas_adicionadas.append(sprite_caixa.global_position)

	var peso = caixa.get_meta("peso")
	pilha_de_caixas.append(caixa)
	peso_atual += peso

	caixa.get_node("Botao").hide()

	print("Caixa adicionada | Peso atual:", peso_atual)
	_verificar_equilibrio()


func _remover_ultima_caixa():
	if pilha_de_caixas.is_empty():
		print("Pilha vazia, nada a remover.")
		return

	# Remove a última caixa e sua posição correspondente
	var caixa: Node2D = pilha_de_caixas.pop_back()
	@warning_ignore("shadowed_variable")
	var posicao_antiga_ultima_caixa: Vector2 = posicoes_antigas_caixas_adicionadas.pop_back()

	var peso = caixa.get_meta("peso")
	peso_atual -= peso
	caixa.get_node("Botao").show()

	var sprite: Sprite2D = caixa.get_node("Sprite2D")

	var tween = create_tween().set_parallel(true)
	tween.tween_property(sprite, "position", posicao_antiga_ultima_caixa, 0.4)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", ESCALA_NORMAL, 0.4)

	print("Caixa removida | Peso atual:", peso_atual)
	_verificar_equilibrio()

# ------------------------------------------------
# --- VERIFICAR EQUILÍBRIO E ATUALIZAR VISUAL ---
# ------------------------------------------------

func _verificar_equilibrio():
	# (Seu código aqui está perfeito, nenhuma mudança necessária)
	var novo_estado: StringName = &""
	
	if is_equal_approx(peso_atual, peso_alvo_pena):
		novo_estado = &"equilibrado"
	elif peso_atual < peso_alvo_pena:
		novo_estado = &"direita_pesado"
	elif peso_atual > peso_alvo_pena:
		novo_estado = &"esquerda_pesado"
		
	match novo_estado:
		&"equilibrado":
			reliquia.show()
			Difficulty.dificuldade = 4
			pena_pos.position = Vector2(198, 53)
			balanca_sprite.position = Vector2(153, 34)
			balanca_sprite.play("equilibrado")
			if not esta_equilibrada:
				esta_equilibrada = true
				print("Balança Equilibrada!")
				emit_signal("equilibrada")
			label_concluido.show()
			sprite_verde.show()
			flecha_saida.show()
			for caixa in caixas_leves:
				if caixa not in pilha_de_caixas:
					caixa.queue_free()
			for caixa in caixas_medias:
				if caixa not in pilha_de_caixas:
					caixa.queue_free()
			for caixa in caixas_pesadas:
				if caixa not in pilha_de_caixas:
					caixa.queue_free()
			botao_remover.queue_free()
		
		&"direita_pesado":
			pena_pos.position = Vector2(185, 67)
			esta_equilibrada = false
			balanca_sprite.play("direita_pesado")
			
		&"esquerda_pesado":
			pena_pos.position = Vector2(196, 25)
			esta_equilibrada = false
			balanca_sprite.play("esquerda_pesado")
			
	_atualizar_posicoes_visuais_das_caixas(novo_estado)

# ------------------------------------------------
# --- FUNÇÃO DE ATUALIZAÇÃO VISUAL DAS CAIXAS ---
# ------------------------------------------------

func _atualizar_posicoes_visuais_das_caixas(estado: StringName):
	
	var array_de_posicoes: Array
	match estado:
		&"equilibrado":
			array_de_posicoes = posicoes_equilibrado
		&"direita_pesado":
			array_de_posicoes = posicoes_direita_pesado
		&"esquerda_pesado":
			array_de_posicoes = posicoes_esquerda_pesado
			
	for i in range(pilha_de_caixas.size()):
		var caixa_base: Node2D = pilha_de_caixas[i]
		var sprite_da_caixa: Sprite2D = caixa_base.get_node("Sprite2D")
		var pos_alvo = array_de_posicoes[i]
		
		var tween = create_tween().set_parallel(true)
		tween.tween_property(sprite_da_caixa, "global_position", pos_alvo, 0.3).set_trans(Tween.TRANS_SINE)
		tween.tween_property(sprite_da_caixa, "scale", ESCALA_CAIXA, 0.3)


func _on_porta_body_entered(body: Node2D) -> void:
	if esta_equilibrada && body.is_in_group("player") && reliquia_coletada:
		sprite_porta.play("abrindo")
		await get_tree().create_timer(1.5).timeout 
		get_tree().change_scene_to_file("res://Levels/fase3.tscn")
	elif !esta_equilibrada && body.is_in_group("player"):
		label_not_concluido.show()
		await get_tree().create_timer(3.5).timeout 
		label_not_concluido.hide()


func _on_botao_reliquia_pressed() -> void:
	reliquia_desc.queue_free()
	player.liberar_input()


func _on_area_reliquia_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") && Difficulty.dificuldade == 4:
		reliquia_coletada = true
		player.bloquear_input()
		await get_tree().create_timer(1.0).timeout
		reliquia_desc.show()
