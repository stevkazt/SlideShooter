extends Node2D

export (PackedScene) var Enemy
export (PackedScene) var PLAYER
export (PackedScene) var PowerUp

var player
var screensize
var Icons = [0,"stair","shield","rocket"]

func _ready():
	$Music_Green.play()
	Singleton._start()
	randomize()
	if !Singleton.sfx:
		$Buttons/pause_menu/sfx/sfx.animation = "sfx_off"
		
	screensize =  get_viewport_rect().size
	$Buttons.rect_global_position = Vector2(0,screensize.y-130)
	#----------------------------------------------------------------------------------------------
	player =  PLAYER.instance()
	add_child(player)
	player.position = Vector2(screensize.x/2,screensize.y/2)

func _process(delta):
	$BG/ParallaxBackground/ParallaxLayer.motion_offset.y += 3
	update_power_icons()

func update_power_icons():
	if Singleton.powers.size() > 0:
		$Buttons/Powers/Power1/AnimatedSprite.animation = Icons[Singleton.powers[0]]
		$Buttons/Powers/Power1.show()
		if Singleton.powers.size() > 1:
			$Buttons/Powers/Power2/AnimatedSprite2.animation = Icons[Singleton.powers[1]]
			$Buttons/Powers/Power2.show()
			if Singleton.powers.size() > 2:
				$Buttons/Powers/Power3/AnimatedSprite3.animation = Icons[Singleton.powers[2]]
				$Buttons/Powers/Power3.show()
			else:
				$Buttons/Powers/Power3.hide()
		else:
			$Buttons/Powers/Power2.hide()
			$Buttons/Powers/Power3.hide()
	else:
		$Buttons/Powers/Power1.hide()
		$Buttons/Powers/Power2.hide()
		$Buttons/Powers/Power3.hide()
	

func _on_ShooterTimer_timeout():
	var e = Enemy.instance()
	e.type = 1
	add_child(e)
	
func _on_PowerUpTimer_timeout():
	Singleton.lifes = 3
	randomize()
	var p = PowerUp.instance()
	var b = randi()%2+1
	print(b)
	if !Singleton.powers.has(2):
		p.power = b
	else:
		p.power = 1
	add_child(p)
	p.position = Vector2(rand_range(150,600),rand_range(400,1120))
	
	
func _on_Power2_pressed():
	if Singleton.powers.size() >= 2:
		var p0 = Singleton.powers[0]
		var p1 = Singleton.powers[1]
		Singleton.powers[0] = p1
		Singleton.powers[1] = p0
	
#-----------------------------------------------------------------------------------------------------
func _on_Power3_pressed():
	if Singleton.powers.size() == 3:
		var p0 = Singleton.powers[0]
		var p1 = Singleton.powers[1]
		var p2 = Singleton.powers[2]
		Singleton.powers[0] = p2
		Singleton.powers[1] = p0
		Singleton.powers[2] = p1
	
#-----------------------------------------------------------------------------------------------------
func _on_pause_pressed():
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
	
#-----------------------------------------------------------------------------------------------------
func _on_home_pressed():
	$Buttons/pause_menu/home/Button_yes.show()
	$Buttons/pause_menu/home/Button_no.show()
	
#-----------------------------------------------------------------------------------------------------
func _on_Button_yes_pressed():
	var Main = load("res://Scenes/Main.tscn")
	var main = Main.instance()
	get_tree().paused = false
	Singleton.lifes = 3
	Singleton.score = 0
	Singleton.powers.resize(0)
	get_tree().get_nodes_in_group("player")[0].queue_free()
	
	var transitions = get_tree().get_nodes_in_group("transition")
	if transitions.size() > 0:
		transitions[0].queue_free()
	
	get_parent().add_child(main)
	queue_free()
	
#-----------------------------------------------------------------------------------------------------
func _on_Button_no_pressed():
	$Buttons/pause_menu/home/Button_yes.hide()
	$Buttons/pause_menu/home/Button_no.hide()
	
#-----------------------------------------------------------------------------------------------------
func _on_sfx_pressed():
	if Singleton.sfx:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),true)
		$Buttons/pause_menu/sfx/sfx.animation = "sfx_off"
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),false)
		$Buttons/pause_menu/sfx/sfx.animation = "sfx_on"
	Singleton.sfx = !Singleton.sfx
	
#-----------------------------------------------------------------------------------------------------

