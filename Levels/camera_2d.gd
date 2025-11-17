extends Camera2D
class_name CameraController

## --- Variáveis de Zoom (Ajuste no Editor) ---

# A velocidade com que a câmera aplica o zoom.
@export var zoom_speed: float = 0.5

# O nível MÍNIMO de zoom (mais "longe" / vê mais área).
@export var min_zoom_out: float = 0.5

# O nível MÁXIMO de zoom (mais "perto" / vê bem de perto).
@export var max_zoom_in: float = 6.0

# -------------------------------------------------

# Variável para guardar a direção do zoom vinda dos botões da UI
var ui_zoom_direction: float = 0.0

# _process roda a cada frame
func _process(delta: float):
	
	# --- DETECÇÃO DE ENTRADA ---
	var total_zoom_direction: float = 0.0
	
	# 1. Verifica o Mapa de Entradas (Teclado)
	# "zoom_in" (botão "Menos") = Aumenta o valor do zoom (chega perto)
	if Input.is_action_pressed("zoom_in"):
		total_zoom_direction += 1.0
		
	# "zoom_out" (botão "Mais") = Diminui o valor do zoom (afasta)
	if Input.is_action_pressed("zoom_out"):
		total_zoom_direction -= 1.0
		
	# 2. Se o teclado não estiver sendo usado, verifica os botões da UI
	if total_zoom_direction == 0.0:
		total_zoom_direction = ui_zoom_direction
	
	# --- APLICAÇÃO DO ZOOM ---
	if total_zoom_direction != 0.0:
		# Calcula o novo nível de zoom
		var new_zoom_level = zoom.x + (total_zoom_direction * zoom_speed * delta)
		
		# Limita o zoom para ficar EXATAMENTE entre 0.5 e 6.0
		new_zoom_level = clamp(new_zoom_level, min_zoom_out, max_zoom_in)
		
		# Aplica o novo zoom
		zoom = Vector2(new_zoom_level, new_zoom_level)


# -----------------------------------------------------------------
# FUNÇÕES PÚBLICAS PARA CONECTAR AOS BOTÕES DA UI
# (Conecte os sinais 'button_down' e 'button_up' dos seus botões a estas funções)
# -----------------------------------------------------------------

# Conecte o "button_down" do seu botão de Zoom In ("Menos") aqui
func _on_zoom_in_pressed():
	ui_zoom_direction = 1.0 # 1.0 = Zoom In (mais perto)

# Conecte o "button_up" do seu botão de Zoom In ("Menos") aqui
func _on_zoom_in_released():
	if ui_zoom_direction == 1.0:
		ui_zoom_direction = 0.0

# Conecte o "button_down" do seu botão de Zoom Out ("Mais") aqui
func _on_zoom_out_pressed():
	ui_zoom_direction = -1.0 # -1.0 = Zoom Out (mais longe)

# Conecte o "button_up" do seu botão de Zoom Out ("Mais") aqui
func _on_zoom_out_released():
	if ui_zoom_direction == -1.0:
		ui_zoom_direction = 0.0
