extends Node2D

export (PackedScene) var Enemy
export (PackedScene) var PLAYER

var player
var screensize

func _ready():
	$Music_Green.play()
	Singleton._start()
	randomize()
	if !Singleton.sfx:
		$Buttons/pause_menu/sfx/sfx.animation = "sfx_off"
		
	screensize =  get_viewport_rect().size
	#----------------------------------------------------------------------------------------------
	player =  PLAYER.instance()
	player.circle = true
	add_child(player)
	player.position = Vector2(screensize.x/2,screensize.y/2)

func _process(_delta):
	$BG/ParallaxBackground/ParallaxLayer.motion_offset.y += 3


func _on_ninjaSpawn_timeout():
	var e = Enemy.instance()
	e.ninja_sprite = 1
	e.type = 0
	e.speed = 250
	add_child(e)


func _on_pause_menu_pressed():
	if get_tree().paused:
		$Buttons/pause_menu/pauseBtt.animation = "pause"
		get_tree().paused = false
		$Buttons/pause_menu/home.hide()
		$Buttons/pause_menu/sfx.hide()
	else:
		$Buttons/pause_menu/pauseBtt.animation = "play"
		get_tree().paused = true
		$Buttons/pause_menu/home.show()
		$Buttons/pause_menu/sfx.show()


func _on_home_pressed():
	$Buttons/pause_menu/home/Button_yes.show()
	$Buttons/pause_menu/home/Button_no.show()


func _on_Button_yes_pressed():
	var Main = load("res://Scenes/Main.tscn")
	var main = Main.instance()
	get_tree().paused = false
	Singleton.lifes = 3
	Singleton.score = 0
	Singleton.powers.resize(0)
	get_tree().get_nodes_in_group("player")[0].queue_free()
	get_parent().add_child(main)
	queue_free()


func _on_Button_no_pressed():
	$Buttons/pause_menu/home/Button_yes.hide()
	$Buttons/pause_menu/home/Button_no.hide()


func _on_sfx_pressed():
	if Singleton.sfx:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),true)
		$Buttons/pause_menu/sfx/sfx.animation = "sfx_off"
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),false)
		$Buttons/pause_menu/sfx/sfx.animation = "sfx_on"
	Singleton.sfx = !Singleton.sfx
