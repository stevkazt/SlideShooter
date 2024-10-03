extends Node
# This is Singleton
var score
var lifes
var sfx
var boss
var powers = {
	"available" = false,
	"type" = 0
}

func _ready():
	boss = false
	sfx = true
	score = 0
	lifes = 3
	
