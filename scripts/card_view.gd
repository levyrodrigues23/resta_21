extends Node2D

@onready
var house_children = get_node("area")
@onready
var num1 = get_node("num1")
@onready
var num2 = get_node("num2")

func setup_view( num, house ):
	get_node('num1').text = str( num )	
	get_node('house1').text = house
	$area/house_cc.text = house	
	$area/house_tl.text = ''
	$area/house_tr.text = ''
	$area/house_br.text = ''
	$area/house_bl.text = ''
	$area/house_cl.text = ''
	$area/house_cr.text = ''
	$area/house_tc.text = ''
	$area/house_td.text = ''
	$area/house_cc_10a.text = ''
	$area/house_cc_10b.text = ''
	
	if( num == 11):
		get_node('num1').text = 'J'
		get_node('num2').text = 'J'
	elif( num == 12):
		get_node('num1').text = 'Q'
		get_node('num2').text = 'Q'
	elif( num == 13):
		get_node('num1').text = 'K'
		get_node('num2').text = 'K'
	
	if( num >= 2 ):
		$area/house_cc.text = ''
		$area/house_tl.text = house
		$area/house_br.text = house
	if( num >= 3 ):
		$area/house_cc.text = house
	if( num >= 4 ):
		$area/house_tr.text = house
		$area/house_bl.text = house
	if( num == 5 or num == 7 or num == 9 ):
		$area/house_cc.text = house
	
	if( num > 5 ):
		$area/house_cr.text = house
		$area/house_cl.text = house
	if( num == 4 or num == 6 or num == 8 or num == 10 ):
		$area/house_cc.text = ''
	
	if( num >= 8 ):
		$area/house_tc.text = house
		$area/house_td.text = house
	
	if( num == 10 ):
		$area/house_cc_10a.text = house
		$area/house_cc_10b.text = house
	
	if( num > 10 ):
		$area/house_tl.text = ''
		$area/house_tr.text = ''
		$area/house_br.text = ''
		$area/house_bl.text = ''
		$area/house_cl.text = ''
		$area/house_cr.text = ''
		$area/house_tc.text = ''
		$area/house_td.text = ''
		$area/house_cc_10a.text = ''
		$area/house_cc_10b.text = ''

	var figuras = {
		"♣️": {11: ['🐂', 'vaqueiro'], 12: ['🌺', 'maria_bonita'], 13: ['⭐', 'lampiao']},
		"♦️": {11: ['⛵', 'jangadeiro'], 12: ['🧵', 'rendeira'], 13: ['⚓', 'dragao_do_mar']},
		"♥️": {11: ['📜', 'cordelista'], 12: ['🏹', 'iracema'], 13: ['🐦', 'patativa']},
		"♠️": {11: ['🕯️', 'romeiro'], 12: ['⚔️', 'barbara_de_alencar'], 13: ['🙏', 'padre_cicero']},
	}

	if( num > 10 ):
		var figura = figuras[house][num]
		var retrato = "res://assets/cartas/" + figura[1] + ".png"
		if( ResourceLoader.exists(retrato) ):
			$area/retrato.texture = load(retrato)
			$area/retrato.visible = true
			$area/house_cc.text = ''
		else:
			$area/character_house.text = figura[0]
			
func _ready():
	pass
