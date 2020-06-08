extends Node
# This is Singleton
var score
var lifes
var sfx = true
var powers : Array
var update # Used to change stage
var Stage 
var last_powers : Array
var stuff

	# Power 1 = stair
	# Power 2 = shield
	# Power 3 = Rocket

func _start():
	stuff = false
	Stage = 1
	update = false
	powers.resize(0)
	last_powers = [0,0,0]
	score = 0
	lifes = 3
	
