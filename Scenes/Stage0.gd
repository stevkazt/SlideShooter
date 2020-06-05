extends Node2D

export (PackedScene) var Enemy
export (PackedScene) var PLAYER
export (PackedScene) var PowerUp
export (PackedScene) var Boss1

var player
var score_file = "user://highscore.gd"
var highscore = 0
var screensize
var Icons = [0,"stair","shield","rocket"]
var ninja_speed = 200
var ninja_sprite = 0
var gfp = false # game flow pause
#var ninjas = 0 # count for paths of ninjas


#-----------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	if !Singleton.sfx:
		$Buttons/pause_menu/sfx/sfx.animation = "sfx_off"
	screensize =  get_viewport_rect().size
	$Buttons.rect_global_position = Vector2(0,screensize.y-130)
	#----------------------------------------------------------------------------------------------
	player =  PLAYER.instance()
	get_parent().add_child(player)
	player.position = Vector2(screensize.x/2,screensize.y/2)
	
#-----------------------------------------------------------------------------------------------------
func _process(_delta):
	$BG/ParallaxBackground/ParallaxLayer.motion_offset.y += 3
	$Score.text = str(Singleton.score)
	#------------------------ Game Flow -----------------------------------------------------------
	if Singleton.score > 1000 and Singleton.score < 1100 and !gfp:
		gfp = true
		var boss1 = Boss1.instance()
		add_child(boss1)
	#----------------------------------------------------------------------------------------------
	if Singleton.score > 2000 and gfp:
		var p = PowerUp.instance()
		p.power = 4
		add_child(p)
		p.position = Vector2(screensize.x/2,screensize.y/2)
		gfp = false
	#-------------------------- Actualizaciones de pantalla ---------------------------------------
	update_lifes()
	update_power_icons()
	
#-----------------------------------------------------------------------------------------------------
func update_lifes():
	if Singleton.lifes == 3:
		$Lifes/Life3.show()
		$Lifes/Life2.show()
		$Lifes/Life1.show()
	if Singleton.lifes == 2:
		$Lifes/Life3.hide()
		$Lifes/Life2.show()
		$Lifes/Life1.show()
	if Singleton.lifes == 1:
		$Lifes/Life2.hide()
		$Lifes/Life2.hide()
		$Lifes/Life1.show()
	if Singleton.lifes == 0:
		check_highscore()
		$GameOverTimer.start()
		get_tree().paused = true
	
#-----------------------------------------------------------------------------------------------------
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
	
#-----------------------------------------------------------------------------------------------------
func _on_ninjaSpawn_timeout():
	if Singleton.score > 100:
		$ninjaSpawn.wait_time = 0.9
	if Singleton.score > 200:
		$ninjaSpawn.wait_time = 0.85
	if Singleton.score > 300:
		$ninjaSpawn.wait_time = 0.80
		ninja_speed = 250
		ninja_sprite = 1
	if Singleton.score > 400:
		$ninjaSpawn.wait_time = 0.75
	if Singleton.score > 500:
		$ninjaSpawn.wait_time = 0.725
	if Singleton.score > 600:
		$ninjaSpawn.wait_time = 0.7
		ninja_speed = 290
		ninja_sprite = 2
	if Singleton.score > 800:
		$ninjaSpawn.wait_time = 0.675
	
	if !gfp:
		var e = Enemy.instance()
		e.ninja_sprite = ninja_sprite
		e.type = 0
		e.speed = ninja_speed 
		add_child(e)
	
#-----------------------------------------------------------------------------------------------------
func _on_ShooterTimer_timeout():
	if !gfp and Singleton.score > 300:
		var e = Enemy.instance()
		e.type = 1
		add_child(e)
	
#-----------------------------------------------------------------------------------------------------
func _on_PowerUpTimer_timeout():
	if Singleton.score > 200:
		randomize()
		var p = PowerUp.instance()
		var pa = [1,1,1,1,1,1,1,2,2,2]
		var b = randi()%10+0
		p.power = pa[b]
		add_child(p)
		p.position = Vector2(rand_range(150,600),rand_range(400,1120))
	
#-----------------------------------------------------------------------------------------------------
func check_highscore():
	var f = File.new()
	if f.file_exists(score_file):
		f.open(score_file,File.READ)
		var content = f.get_as_text()
		highscore = int(content)
		f.close()
		if highscore < Singleton.score:
			update_highscore()
	else:
		f.open(score_file,File.WRITE)
		f.store_string(str(Singleton.score))
		f.close()
	
#-----------------------------------------------------------------------------------------------------
func update_highscore():
	var f = File.new()
	f.open(score_file,File.WRITE)
	f.store_string(str(Singleton.score))
	f.close()
	
#-----------------------------------------------------------------------------------------------------
func _on_GameOverTimer_timeout():
	var Main = load("res://Scenes/Main.tscn")
	var main = Main.instance()
	get_tree().paused = false
	Singleton.lifes = 3
	Singleton.score = 0
	get_tree().get_nodes_in_group("player")[0].queue_free()
	get_parent().add_child(main)
	queue_free()
	
#-----------------------------------------------------------------------------------------------------
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






