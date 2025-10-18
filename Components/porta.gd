extends Node2D

@onready var area: Area2D = $AnimatedSprite2D/Area2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var col: CollisionShape2D = $AnimatedSprite2D/Area2D/CollisionShape2D

var is_open: bool = false
var player_in_range: bool = false
var locked: bool = false      # coloque true se quiser travada até pegar chave

func _ready() -> void:
	area.body_entered.connect(_on_area_entered)
	area.body_exited.connect(_on_area_exited)
	anim.play("closed")
	

func _on_area_entered(body: Node) -> void:
	# Dica: coloque seu Player no grupo "player" (Node > Groups)
	if body.is_in_group("player"):
		anim.play("opening")
		await get_tree().create_timer(1.0).timeout
		player_in_range = true
		LastPosition.player_position = global_position
		body.position = Vector2(1849, 171)
		anim.play("closed")
		queue_free()
		# aqui você pode exibir um "Pressione E"

func _on_area_exited(body: Node) -> void:
	if body.is_in_group("player"):
		anim.play("closing")
		player_in_range = false
		# esconda a dica

func _input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		toggle()

func toggle() -> void:
	if locked or anim.is_playing():
		return
	if is_open:
		anim.play("close")
		is_open = false
		col.disabled = false      # volta a bloquear a passagem
	else:
		anim.play("open")
		is_open = true
		col.disabled = true       # libera a passagem
	if sfx: sfx.play()

# (Opcional) Para usar chave:
func unlock_with(key_id: String) -> void:
	if key_id == "chave_porta_1":
		locked = false
