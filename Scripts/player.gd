extends CharacterBody2D

# ======================================================================
# PROPRIEDADES EXPORTADAS E VARIÁVEIS GERAIS
# ======================================================================

@export var speed : float = 100.0
@export var jump_velocity : float = -150.0
@export var double_jump_velocity : float = -170.0

var has_double_jumped : bool = false
var animation_locked : bool = false
var direction : Vector2 = Vector2.ZERO
var was_in_air : bool = false
var input_bloqueado: bool = false

# Escalas
var idle_scale: Vector2 = Vector2(0.025, 0.025)
var run_scale: Vector2 = Vector2(0.035, 0.035)
var jump_scale: Vector2 = Vector2(0.045, 0.045)

# ======================================================================
# REFERÊNCIAS
# ======================================================================
@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

# ======================================================================
# FUNÇÕES PRINCIPAIS
# ======================================================================

func _ready() -> void:
	animated_sprite.scale = idle_scale
	# Garante que este nó está no grupo correto
	if not is_in_group("player"):
		add_to_group("player")

func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return

	if input_bloqueado:
		animated_sprite.play("idle")
		velocity = Vector2.ZERO
		move_and_slide()
		update_animation()
		return

	# Gravidade
	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	if not is_on_floor():
		velocity.y += gravity * delta
		was_in_air = true
	else:
		has_double_jumped = false
		if was_in_air:
			land()
		was_in_air = false

	# Pulo
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump()
		elif not has_double_jumped:
			velocity.y = double_jump_velocity
			has_double_jumped = true

	# Movimento horizontal
	direction = Input.get_vector("left", "right", "up", "down")
	if direction:
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# ==================================================================
	# FORÇA DO VENTO (ventiladores)
	# ==================================================================
	if is_in_group("sendo_empurrado_por_vento"):
		var forca_vento = get_meta("forca_vento")
		var direcao_vento = get_meta("direcao_vento")
		if forca_vento != null and direcao_vento != null:
			velocity += direcao_vento * (forca_vento * delta)
			animated_sprite.play("jump")

	# ==================================================================
	move_and_slide()
	update_animation()
	update_facing_direction()

# ======================================================================
# ANIMAÇÕES E DIREÇÃO
# ======================================================================

func update_animation():
	if not animation_locked:
		if direction.x != 0:
			animated_sprite.play("run")
			animated_sprite.scale = run_scale
		else:
			animated_sprite.play("idle")
			animated_sprite.scale = idle_scale

func update_facing_direction():
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true

# ======================================================================
# AÇÕES DE PULO E QUEDA
# ======================================================================

func jump():
	velocity.y = jump_velocity
	animated_sprite.play("jump")
	animated_sprite.scale = jump_scale
	animation_locked = true

func land():
	animation_locked = false
	animated_sprite.scale = idle_scale

# ======================================================================
# BLOQUEIO DE INPUT
# ======================================================================

func bloquear_input():
	input_bloqueado = true

func liberar_input():
	input_bloqueado = false
