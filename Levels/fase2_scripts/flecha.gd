extends Sprite2D

# Se preferir arrastar manualmente no Inspector, use esses NodePaths:
@export var player_path: NodePath = NodePath("")
@export var exit_path: NodePath = NodePath("")

var player: Node2D = null
var exit_door: Node2D = null
const ROTATION_OFFSET := -PI / 2

func _ready():
	# 1) Tenta os NodePaths do Inspector (mais confiável)
	if player_path != NodePath("") and has_node(player_path):
		player = get_node(player_path) as Node2D
	if exit_path != NodePath("") and has_node(exit_path):
		exit_door = get_node(exit_path) as Node2D

	# 2) Tenta acessar diretamente pela cena atual (Godot 4)
	var scene_root = get_tree().current_scene
	if scene_root:
		if not player:
			# nomes exatos na raiz da cena: "Player"
			player = scene_root.get_node_or_null("Player") as Node2D
		if not exit_door:
			exit_door = scene_root.get_node_or_null("ExitDoor") as Node2D

	# 3) Tenta por caminhos relativos conhecidos (Arrow está em Fase2/Camera2D/CanvasLayer/Arrow)
	if not player:
		if has_node("../../../Player"):
			player = get_node("../../../Player") as Node2D
	if not exit_door:
		if has_node("../../../ExitDoor"):
			exit_door = get_node("../../../ExitDoor") as Node2D

	# 4) Fallback por grupos (adicione os nós aos grupos 'player' e 'exit' se quiser)
	if not player:
		var ps = get_tree().get_nodes_in_group("player")
		if ps.size() > 0:
			player = ps[0] as Node2D
	if not exit_door:
		var es = get_tree().get_nodes_in_group("exit")
		if es.size() > 0:
			exit_door = es[0] as Node2D

	# Opcional: inicialmente invisible (ativa quando quiser)
	# visible = false

func _process(_delta):
	if not player or not exit_door:
		return

	# Calcula direção entre o player e a porta
	var dir = player.global_position - exit_door.global_position 

	# Rotaciona a seta pra apontar na direção correta
	rotation = dir.angle() + ROTATION_OFFSET
