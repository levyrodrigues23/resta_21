extends Control

@onready var board = get_node('Board')
@onready var end_game_screen = get_node('EndGame')
@onready var hand_board = get_node('hand')
@onready var name_player_1 = get_node("namePlayer1")
@onready var name_player_2 = get_node("namePlayer2")
@onready var score_board = get_node("ScoreBoard")
@onready var event_label = get_node("EventLabel")
@onready var nomes_label = get_node("nomes")





var player_1 : Player
var player_2 : Player
var player_1_continue = true
var player_2_continue = true
var player_active = true
var wins_player_1 = 0
var wins_player_2 = 0
var deck : Array

const CHANCE_EVENTO := 0.6

var texto_evento = ""
var bencao_alvo = ""
var baiao_alvo = ""
var perdido_alvo = ""
var jangada_alvo = ""
var cordel_alvo = ""
var ultimo_evento = ""
var tween_evento : Tween

const TEMPO_EVENTO := 3.5


func nome_do(alvo):
	return player_1.player_name if alvo == "player_1" else player_2.player_name


func sortear_evento():
	bencao_alvo = ""
	baiao_alvo = ""
	perdido_alvo = ""
	jangada_alvo = ""
	cordel_alvo = ""
	ultimo_evento = ""

	if randf() > CHANCE_EVENTO:
		texto_evento = "Brisa do mar: nenhum causo nesta rodada."
		mostrar_evento()
		return

	var alvo = "player_1" if randi() % 2 == 0 else "player_2"
	var eventos = ["bencao", "baiao", "perdido", "jangada", "cordel"]

	match eventos[randi() % eventos.size()]:
		"bencao":
			bencao_alvo = alvo
			texto_evento = "Bênção do Padre Cícero: se " + nome_do(alvo) + " estourar 21, a última carta volta pro baralho."
		"baiao":
			baiao_alvo = alvo
			texto_evento = "Baião de Dois: na próxima vez que " + nome_do(alvo) + " puxar, vêm duas cartas."
		"perdido":
			perdido_alvo = alvo
			texto_evento = "Labirinto das Falésias: " + nome_do(alvo) + " se perdeu no Morro Branco e vai perder a próxima vez."
		"jangada":
			jangada_alvo = alvo
			texto_evento = "Jangada Pescadora: a próxima carta de " + nome_do(alvo) + " será a menor entre as duas do topo."
		"cordel":
			cordel_alvo = alvo
			texto_evento = "Cordel da Feira: na sua vez, " + nome_do(alvo) + " vê qual é a próxima carta."

	checar_perdido()
	mostrar_evento()


func mostrar_evento():
	var vez = "player_1" if player_active else "player_2"
	var texto = texto_evento

	if cordel_alvo == vez and deck.size() > 0:
		texto += "\nPróxima carta: " + deck[0].title

	if texto == ultimo_evento:
		return
	ultimo_evento = texto

	event_label.text = texto
	event_label.visible = true
	event_label.modulate.a = 1.0

	if tween_evento:
		tween_evento.kill()
	tween_evento = create_tween()
	tween_evento.tween_interval(TEMPO_EVENTO)
	tween_evento.tween_property(event_label, "modulate:a", 0.0, 0.8)
	tween_evento.tween_callback(event_label.hide)


func checar_perdido():
	var vez = "player_1" if player_active else "player_2"

	if perdido_alvo == vez:
		perdido_alvo = ""
		texto_evento = "Labirinto das Falésias: " + nome_do(vez) + " se perdeu no Morro Branco e passou a vez!"
		player_active = not player_active

func generate_deck():
	var cards = []
	var houses = ["Paus", "Espadas", "Ouro", "Copas"]
	
	for np in houses:
		for i in range(1, 14):
			cards.append( Card.new(i, np) )
	return cards

func updateBoard():
	board.text = 'Vez do ' + (player_1.player_name if player_active else player_2.player_name)
	board.text += ' | Jogador ' + player_1.player_name + ' - ' + str(player_1.score) + ' pontos '
	board.text += ' | Jogador ' + player_2.player_name + ' - ' + str(player_2.score) + ' pontos '
	
	board.text += '\n' + player_1.show_hands()
	board.text += '\n' + player_2.show_hands()
	
func update_score_board():
	score_board.text = (
		player_1.player_name + ": " + str(wins_player_1)
		+ " x "
		+ str(wins_player_2) + ": " + player_2.player_name
	)

func end_game():
	var result = ''

	if player_1.score == player_2.score:
		end_game_screen.text = "Empate!"
		return
	elif player_1.score > 21:
		wins_player_2 += 1
		result = player_2.player_name
	elif player_2.score > 21:
		wins_player_1 += 1
		result = player_1.player_name
	elif player_1.score > player_2.score:
		wins_player_1 += 1
		result = player_1.player_name
	else:
		wins_player_2 += 1
		result = player_2.player_name
		
	end_game_screen.text = result + " venceu!!"
	update_score_board()


func _ready():
	board.text = "digite os nomes e clique em iniciar"
	score_board.text = " "
	event_label.hide()
	
	

func _on_puxar_button_up() -> void:
	if player_1 == null or player_2 == null:
		return

	var jogador_da_vez = player_1 if player_active else player_2
	var vez = "player_1" if player_active else "player_2"
	var quantidade = 1

	if baiao_alvo == vez:
		baiao_alvo = ""
		quantidade = 2
		texto_evento = "Baião de Dois! " + jogador_da_vez.player_name + " puxou duas cartas."

	if jangada_alvo == vez and deck.size() >= 2:
		jangada_alvo = ""
		if deck[1].get_value() < deck[0].get_value():
			var menor = deck[1]
			deck[1] = deck[0]
			deck[0] = menor
		texto_evento = "O jangadeiro escolheu a carta menor para " + jogador_da_vez.player_name + "."

	if cordel_alvo == vez:
		cordel_alvo = ""

	for i in range(quantidade):
		if( player_active ):
			player_1.take_card( deck )
			hand_board.add_child(player_1.hand[-1].interface)
			player_1.hand[-1].interface.position.x = (len(player_1.hand)-1)*150
			player_1.hand[-1].interface.get_node('paper').size.y = 220
		else:
			player_2.take_card( deck )
			player_2.hand[-1].interface.position.y = 230
			player_2.hand[-1].interface.position.x = (len(player_2.hand)-1)*150
			hand_board.add_child(player_2.hand[-1].interface)

	if bencao_alvo == vez and jogador_da_vez.score > 21:
		bencao_alvo = ""
		var devolvida = jogador_da_vez.hand.pop_back()
		jogador_da_vez.score -= devolvida.get_value()
		hand_board.remove_child(devolvida.interface)
		deck.append(devolvida)
		texto_evento = "O Padre Cícero salvou " + jogador_da_vez.player_name + ": " + devolvida.title + " voltou pro baralho."

	if( player_1.score == 21 or player_2.score == 21 ):
		end_game()
	elif( player_1.score < 22 and player_2.score < 22 ):
		player_active = not player_active
		checar_perdido()
	else:
		end_game()
	updateBoard()
	mostrar_evento()

func _on_manter_button_up() -> void:
	if player_1 == null or player_2 == null:
		return
	
	if( player_active):
		player_1_continue = false
	else:
		player_2_continue = false
	
	if( not player_1_continue and not player_2_continue ):
		end_game()
	player_active = not player_active

	var vez = "player_1" if player_active else "player_2"
	if cordel_alvo != "" and cordel_alvo != vez:
		cordel_alvo = ""
	checar_perdido()
	mostrar_evento()


func _on_btn_reset_button_up() -> void:
	if player_1 == null or player_2 == null:
		return
	
	print('Gerando baralho')
	deck = generate_deck()
	
	print('Embaralhando')
	deck.shuffle()
	player_active = true

	end_game_screen.text = ''
	

	player_1.reset( hand_board, deck )
	player_2.reset( hand_board, deck )

	sortear_evento()
	updateBoard()


func _on_btn_start_button_up() -> void:	
	var nome1 = name_player_1.text
	var nome2 = name_player_2.text
	
	if nome1 == "":
		nome1 = "Jogador 1"
	if nome2 == "":
		nome2 = "Jogador 2"
		
		
	nomes_label.text = ""
	player_1 =  Player.new(nome1)
	player_2 = Player.new(nome2)
	
	deck = generate_deck()
	deck.shuffle()
	
	player_1_continue = true
	player_2_continue = true
	player_active = true
	
	end_game_screen.text = ""
	

	wins_player_1 = 0
	wins_player_2 = 0

	sortear_evento()
	updateBoard()
	update_score_board()
	
	
	updateBoard()
