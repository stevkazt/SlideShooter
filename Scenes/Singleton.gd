extends Node
# This is Singleton
var score
var lifes
var sfx
var boss
var powers : Array
	# Power 1 = stair
	# Power 2 = shield
	# Power 3 = Rocket

func _ready():
	powers.resize(0)
	boss = false
	sfx = true
	score = 0
	lifes = 3
	
