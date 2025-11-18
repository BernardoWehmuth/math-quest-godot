# Engrenagem.gd (Script anexado ao TouchScreenButton "Engrenagem")
extends Button

# Referências aos nós filhos. 
# Certifique-se de que os nomes dos nós correspondem aos caminhos.
@onready var continuar_button = $Sprite2D/BotaoContinuar
@onready var sair_button = $Sprite2D/BotaoSair
@onready var sprite_sair_continuar = $Sprite2D # O fundo/painel do menu de pausa
@onready var engrenagem = $Engrenagem
@onready var aumentar_zoom = $AumentarFov
@onready var diminuir_zoom = $DiminuirFov
@onready var sprite_fov = $Sprite2D2

# Caminho para o menu principal
const TITLE_SCREEN_PATH = "res://Levels/TitleScreen.tscn"


func _process(_delta: float):
	if Input.is_action_just_pressed("pause"):
		toggle_pause()
		
func _ready():

	# --- 1. CONFIGURAÇÃO INICIAL ---
	
	# Esconde todos os elementos do menu de pausa no início do jogo.
	# O próprio visual da Engrenagem (este TouchScreenButton) permanece visível.
	sprite_sair_continuar.hide()
	continuar_button.hide() 
	sair_button.hide()
	sprite_fov.hide()
	diminuir_zoom.hide()
	aumentar_zoom.hide()
	
	
# Função principal chamada ao clicar na Engrenagem
func toggle_pause():
	# Inverte o estado de pausa do jogo: se estiver pausado, despausa; se não estiver, pausa.
	set_pause_state(not get_tree().paused)
	
# Função para aplicar o estado de pausa e gerenciar a visibilidade do menu
func set_pause_state(should_pause: bool):
	# Pausa ou despausa o jogo
	get_tree().paused = should_pause
	
	if should_pause:
		# ABRE O MENU DE PAUSA:
		
		# Mostra o fundo do menu e os botões
		engrenagem.hide()
		sprite_sair_continuar.show()
		continuar_button.show()
		sair_button.show()
		sprite_fov.show()
		diminuir_zoom.show()
		aumentar_zoom.show()
		
		# Desativa o clique no próprio botão Engrenagem, 
		# para que o menu não feche se for clicado acidentalmente novamente.
		set_process_input(false)
		
	else:
		# FECHA O MENU DE PAUSA:
		
		# Esconde o fundo do menu e os botões
		engrenagem.show()
		sprite_sair_continuar.hide()
		continuar_button.hide()
		sair_button.hide()
		sprite_fov.hide()
		diminuir_zoom.hide()
		aumentar_zoom.hide()
		
		# Reativa o clique na Engrenagem, permitindo que ela seja pressionada novamente.
		set_process_input(true)
		
# Função para sair da fase e voltar ao menu
func sair_para_menu():
	# CRÍTICO: Despausa o jogo antes de trocar de cena para evitar bugs.
	get_tree().paused = false
	# Carrega a cena do Menu Principal
	get_tree().change_scene_to_file(TITLE_SCREEN_PATH)
