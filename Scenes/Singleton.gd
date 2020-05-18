extends Node
# This is Singleton
var score
var lifes
var sfx
var boss
var powers : Array
var update 
var Stage 
var last_powers : Array
var stuff
	# Power 1 = stair
	# Power 2 = shield
	# Power 3 = Rocket

func _ready():
	stuff = false
	Stage = 1
	update = false
	powers.resize(0)
	last_powers = [0,0,0]
	boss = false
	sfx = true
	score = 0
	lifes = 3
	
