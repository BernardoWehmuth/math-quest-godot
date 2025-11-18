extends Camera2D
class_name CameraController

## --- Variáveis de Zoom (Ajuste no Editor) ---
@export var zoom_speed: float = 0.5
@export var min_zoom_out: float = 3.5
@export var max_zoom_in: float = 5.0

# Variável para guardar a direção do zoom vinda dos botões da UI
var ui_zoom_direction: float = 0.0

func _process(delta: float):	
	
	
	# --- DETECÇÃO DE ENTRADA ---
	var total_zoom_direction: float = 0.0
	
	if Input.is_action_pressed("zoom_in"):
		total_zoom_direction += 1.0
		
	if Input.is_action_pressed("zoom_out"):
		total_zoom_direction -= 1.0
		
	# 2. Se o teclado não estiver sendo usado, verifica os botões da UI
	if total_zoom_direction == 0.0:
		total_zoom_direction = ui_zoom_direction
	
	# --- APLICAÇÃO DO ZOOM ---
	if total_zoom_direction != 0.0:
		# Calcula o novo nível de zoom
		var new_zoom_level = zoom.x + (total_zoom_direction * zoom_speed * delta)
		
		# Limita o zoom
		new_zoom_level = clamp(new_zoom_level, min_zoom_out, max_zoom_in)
		
		# Aplica o novo zoom
		zoom = Vector2(new_zoom_level, new_zoom_level)


# -----------------------------------------------------------------
# FUNÇÕES DOS BOTÕES DA UI
# -----------------------------------------------------------------

func _on_zoom_in_pressed():
	ui_zoom_direction = 1.0 

func _on_zoom_in_released():
	if ui_zoom_direction == 1.0:
		ui_zoom_direction = 0.0

func _on_zoom_out_pressed():
	ui_zoom_direction = -1.0 

func _on_zoom_out_released():
	if ui_zoom_direction == -1.0:
		ui_zoom_direction = 0.0
