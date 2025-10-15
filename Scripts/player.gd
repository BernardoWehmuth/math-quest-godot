extends CharacterBody2D

@export var speed : float = 100.0
@export var jump_velocity : float = -150.0
@export var double_jump_velocity : float = -170

@onready var animated_sprite : AnimatedSprite2D = $AnimatedSprite2D

var has_double_jumped : bool = false
var animation_locked : bool = false
var direction : Vector2 = Vector2.ZERO
var was_in_air : bool = false

# Variável de controle de estado
var input_bloqueado: bool = false

# Escalas diferentes
var idle_scale: Vector2 = Vector2(0.025, 0.025)
var run_scale: Vector2 = Vector2(0.035, 0.035)
var jump_scale: Vector2 = Vector2(0.045, 0.045)


func _ready() -> void:
	animated_sprite.scale = idle_scale


func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	# BLOQUEIO DE INPUT
	if input_bloqueado:
		velocity = Vector2.ZERO
		move_and_slide()
		update_animation() # Mantém a animação (ex: 'idle')
		return 

	# >>> CORREÇÃO DA GRAVIDADE <<<
	# 1. Obtém a gravidade do nó CharacterBody2D.
	#    Se você não a configurou, o valor padrão do projeto será usado.
	var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") 
	
	# Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta # Usamos 'velocity.y' em vez de 'velocity'
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
				print(get_tree().current_scene.to_string()  )
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


func update_animation():
	# ... (restante da sua função update_animation) ...
	if not animation_locked:
		if direction.x != 0:
			animated_sprite.play("run")
			animated_sprite.scale = run_scale
		else:
			animated_sprite.play("idle")
			animated_sprite.scale = idle_scale


func update_facing_direction():
	# ... (restante da sua função update_facing_direction) ...
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true


func jump():
	# ... (restante da sua função jump) ...
	velocity.y = jump_velocity
	animated_sprite.play("jump")
	animated_sprite.scale = jump_scale
	animation_locked = true


func land():
	# ... (restante da sua função land) ...
	animation_locked = false
	animated_sprite.scale = idle_scale

# >>> FUNÇÕES DE BLOQUEIO DE INPUT ADICIONADAS <<<
func bloquear_input():
	input_bloqueado = true

func liberar_input():
	input_bloqueado = false
