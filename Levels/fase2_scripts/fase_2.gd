extends Node2D

# Sinal emitido quando a balança está equilibrada
signal equilibrada

var reliquia_coletada = false

# --- Configuração do Puzzle ---
@export var peso_alvo_pena: float = 1.0
const MAX_CAIXAS_NA_BALANCA = 6

@onready var movimentacao = $Player/Camera2D/CanvasLayer/CanvasLayer
# --- Referências ---
@onready var player = $Player
@onready var sprite_verde = $Sprite_verde
@onready var label_concluido = $Player/Camera2D/CanvasLayer/LabelConcluido
@onready var porta_entrada = $PortaEntrada
@onready var reliquia = $Reliquia
@onready var area_reliquia = $AreaReliquia
@onready var seta_anubis = $Anubis/Seta
@onready var explicacao_fase = $Player/Camera2D/CanvasLayer/Explicacao
@onready var sprite_porta = $ExitDoor/AnimatedSprite2D
@onready var flecha_saida = $Player/Camera2D/CanvasLayer/Flecha
@onready var reliquia_desc = $Player/Camera2D/CanvasLayer/ReliquiaDesc
@onready var label_not_concluido = $Player/Camera2D/CanvasLayer/LabelNotConcluido
@onready var balanca_sprite = $"nó balanca/balanca"
@onready var pena_pos = $"nó balanca/pena"

# --- Pesos ---
const PESO_CAIXA_LEVE = 1.0 / 6.0
const PESO_CAIXA_MEIO = 1.0 / 3.0
const PESO_CAIXA_PESADA = 1.0 / 2.0

# --- Escalas ---
const ESCALA_CAIXA = Vector2(0.096, 0.105)
const ESCALA_NORMAL = Vector2(0.165, 0.165)

# --- Caixas disponíveis ---
@onready var caixas_leves = [$no_caixa_leve1, $no_caixa_leve2, $no_caixa_leve3, $no_caixa_leve4, $no_caixa_leve5, $no_caixa_leve6]
@onready var caixas_medias = [$no_caixa_meio1, $no_caixa_meio2, $no_caixa_meio3]
@onready var caixas_pesadas = [$no_caixa_pesada1, $no_caixa_pesada2]

# --- Estado ---
var peso_atual: float = 0.0
var esta_equilibrada: bool = false
var pilha_de_caixas: Array[Node2D] = []
var posicoes_antigas_caixas_adicionadas: Array[Vector2] = []

# --- Posições Visuais ---
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

# ------------------------------------------------
# --- READY ---
# ------------------------------------------------
func _ready():
	seta_anubis.play("idle")
	_verificar_equilibrio()
	sprite_verde.hide()
	label_concluido.hide()
	flecha_saida.hide()

	porta_entrada.play("fechando")
	await get_tree().create_timer(1.5).timeout
	porta_entrada.hide()

	_conectar_caixas()
	sprite_porta.play("fechada")


# ------------------------------------------------
# --- CONECTAR CAIXAS COM AREA2D ---
# ------------------------------------------------
func _conectar_caixas():
	var todas = caixas_leves + caixas_medias + caixas_pesadas

	for caixa in todas:

		# Define peso
		if caixa.name.begins_with("no_caixa_leve"):
			caixa.set_meta("peso", PESO_CAIXA_LEVE)
		elif caixa.name.begins_with("no_caixa_meio"):
			caixa.set_meta("peso", PESO_CAIXA_MEIO)
		else:
			caixa.set_meta("peso", PESO_CAIXA_PESADA)

		# Area2D obrigatória
		var area: Area2D = caixa.get_node("Area2D")
		if area == null:
			push_warning("Caixa %s sem Area2D!" % caixa.name)
			continue

		# Conecta o sinal
		area.body_entered.connect(Callable(self, "_on_area_caixa_entered").bind(caixa))

		# Escala normal
		var sprite: Sprite2D = caixa.get_node("Sprite2D")
		if sprite:
			sprite.scale = ESCALA_NORMAL


# ------------------------------------------------
# --- PLAYER TOCA A CAIXA (COLETA) ---
# ------------------------------------------------
func _on_area_caixa_entered(body: Node2D, caixa: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_adicionar_caixa(caixa)


# ------------------------------------------------
# --- ADICIONAR CAIXA ---
# ------------------------------------------------
func _adicionar_caixa(caixa: Node2D):
	if pilha_de_caixas.has(caixa):
		return

	if pilha_de_caixas.size() >= MAX_CAIXAS_NA_BALANCA:
		print("Limite máximo atingido.")
		return

	var sprite = caixa.get_node("Sprite2D")
	posicoes_antigas_caixas_adicionadas.append(sprite.global_position)

	var peso = caixa.get_meta("peso")
	pilha_de_caixas.append(caixa)
	peso_atual += peso

	# desativa a area (não coleta duas vezes)
	caixa.get_node("Area2D").set_deferred("monitoring", false)

	print("Caixa adicionada | Peso atual:", peso_atual)

	_verificar_equilibrio()


# ------------------------------------------------
# --- REMOVER ÚLTIMA CAIXA ---
# ------------------------------------------------
func _remover_ultima_caixa():
	if pilha_de_caixas.is_empty():
		return

	var caixa: Node2D = pilha_de_caixas.pop_back()
	var pos_antiga = posicoes_antigas_caixas_adicionadas.pop_back()

	var sprite = caixa.get_node("Sprite2D")
	var peso = caixa.get_meta("peso")
	peso_atual -= peso

	# reativa para ser coletada de novo
	caixa.get_node("Area2D").set_deferred("monitoring", true)

	var tween = create_tween().set_parallel(true)
	tween.tween_property(sprite, "position", pos_antiga, 0.4)
	tween.tween_property(sprite, "scale", ESCALA_NORMAL, 0.4)

	_verificar_equilibrio()


# ------------------------------------------------
# --- VERIFICAR EQUILÍBRIO ---
# -----------------------------------------------
		
		
func _verificar_equilibrio():

	var estado: StringName = &""

	if is_equal_approx(peso_atual, peso_alvo_pena):
		estado = &"equilibrado"
	elif peso_atual < peso_alvo_pena:
		estado = &"direita_pesado"
	else:
		estado = &"esquerda_pesado"

	match estado:
		&"equilibrado":
			reliquia.show()
			Difficulty.dificuldade = 4
			pena_pos.position = Vector2(198, 53)
			balanca_sprite.position = Vector2(153, 34)
			balanca_sprite.play("equilibrado")

			if not esta_equilibrada:
				esta_equilibrada = true
				emit_signal("equilibrada")

			label_concluido.show()
			sprite_verde.show()
			flecha_saida.show()

		&"direita_pesado":
			pena_pos.position = Vector2(185, 67)
			esta_equilibrada = false
			balanca_sprite.play("direita_pesado")

		&"esquerda_pesado":
			pena_pos.position = Vector2(196, 25)
			esta_equilibrada = false
			balanca_sprite.play("esquerda_pesado")

	_atualizar_posicoes_visuais_das_caixas(estado)


# ------------------------------------------------
# --- POSIÇÕES DAS CAIXAS NA BALANÇA ---
# ------------------------------------------------
func _atualizar_posicoes_visuais_das_caixas(estado: StringName):

	var posicoes: Array

	match estado:
		&"equilibrado":
			posicoes = posicoes_equilibrado
		&"direita_pesado":
			posicoes = posicoes_direita_pesado
		&"esquerda_pesado":
			posicoes = posicoes_esquerda_pesado

	for i in range(pilha_de_caixas.size()):
		var caixa = pilha_de_caixas[i]
		var sprite = caixa.get_node("Sprite2D")

		var tween = create_tween().set_parallel(true)
		tween.tween_property(sprite, "global_position", posicoes[i], 0.3)
		tween.tween_property(sprite, "scale", ESCALA_CAIXA, 0.3)


# ------------------------------------------------
# --- RELÍQUIA / SAÍDA ---
# ------------------------------------------------
func _on_porta_body_entered(body):
	if esta_equilibrada and body.is_in_group("player") and reliquia_coletada:
		sprite_porta.play("abrindo")
		await get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_file("res://Levels/fase3.tscn")
	elif not esta_equilibrada and body.is_in_group("player"):
		label_not_concluido.show()
		await get_tree().create_timer(3.5).timeout
		label_not_concluido.hide()


func _on_area_reliquia_body_entered(body):
	if body.is_in_group("player") and Difficulty.dificuldade == 4:
		reliquia_coletada = true
		player.bloquear_input()
		await get_tree().create_timer(1.0).timeout
		reliquia_desc.show()
		Difficulty.dificuldade = 0
		movimentacao.reliquia2.show()


func _on_botao_reliquia_pressed():
	reliquia_desc.queue_free()
	player.liberar_input()


func _on_botao_anubis_pressed():
	player.bloquear_input()
	explicacao_fase.show()


func _on_botao_explicacao_pressed():
	player.liberar_input()
	explicacao_fase.hide()
