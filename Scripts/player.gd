extends CharacterBody2D

# ==============================================================================
# PROPRIEDADES EXPORTADAS E VARIÁVEIS GERAIS
# ==============================================================================

@export var speed : float = 100.0
@export var jump_velocity : float = -150.0
@export var double_jump_velocity : float = -170

# Removido: deadly_tile_offset_y (Não é mais necessário)

# ==============================================================================
# VARIÁVEIS DE REFERÊNCIA E CONSTANTES
# ==============================================================================

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D
# Removido: @onready var tilemap (Não é mais necessário)
# Removido: const DEADLY_PROPERTY_NAME, const TILEMAP_LAYER (Não são mais necessários)

var has_double_jumped : bool = false
var animation_locked : bool = false
var direction : Vector2 = Vector2.ZERO
var was_in_air : bool = false
var input_bloqueado: bool = false

# Escalas
var idle_scale: Vector2 = Vector2(0.025, 0.025)
var run_scale: Vector2 = Vector2(0.035, 0.035)
var jump_scale: Vector2 = Vector2(0.045, 0.045)


# ==============================================================================
# FUNÇÕES DO GODOT
# ==============================================================================

func _ready() -> void:
	animated_sprite.scale = idle_scale
	
	# É CRÍTICO: SEU NÓ PLAYER DEVE ESTAR NO GRUPO "player"!
	# Selecione o nó Player, vá em 'Nó' -> 'Grupos' e adicione "player".
	
func _physics_process(delta: float) -> void:
	# Removido: Toda a lógica de is_standing_on_deadly_tile()
	
	if get_tree().paused:
		return
	
	# BLOQUEIO DE INPUT
	if input_bloqueado:
		velocity = Vector2.ZERO
		move_and_slide()
		update_animation()
		return

	# >>> CORREÇÃO DA GRAVIDADE <<<
	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") 
	
	# Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta
		was_in_air = true
	else:
		has_double_jumped = false
		
		if was_in_air == true:
			land()
			
		was_in_air = false

	# Pulo
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			jump()
			if get_tree().current_scene.scene_file_path == "res://Levels/test_level.tscn":
				has_double_jumped = true
		elif not has_double_jumped:
			velocity.y = double_jump_velocity
			has_double_jumped = true

	# Movimento horizontal
	direction = Input.get_vector("left", "right", "up", "down")
	if direction:
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	move_and_slide()
	
	update_animation()
	update_facing_direction()

# Removido: is_standing_on_deadly_tile() e handle_death()

# ==============================================================================
# OUTRAS FUNÇÕES (Mantidas do seu original)
# ==============================================================================

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


func jump():
	velocity.y = jump_velocity
	animated_sprite.play("jump")
	animated_sprite.scale = jump_scale
	animation_locked = true


func land():
	animation_locked = false
	animated_sprite.scale = idle_scale

func bloquear_input():
	input_bloqueado = true

func liberar_input():
	input_bloqueado = false
