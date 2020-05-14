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



#-----------------------------------------------------------------------------------------------------
func _ready():
	randomize()
	if !Singleton.sfx:
		$Buttons/pause_menu/sfx/sfx.animation = "sfx_off"
	screensize =  get_viewport_rect().size
	$Buttons.rect_global_position = Vector2(0,screensize.y-130)
	#----------------------------------------------------------------------------------------------
	player =  PLAYER.instance()
	add_child(player)
	player.position = Vector2(screensize.x/2,screensize.y/2)
	
#-----------------------------------------------------------------------------------------------------
func _process(_delta):
	$BG/ParallaxBackground/ParallaxLayer.motion_offset.y += 3
	$Score.text = str(Singleton.score)
	
	#------------------------ Game Flow -----------------------------------------------------------
	if Singleton.score > 100 and $ShooterTimer.is_stopped() and !Singleton.boss and !Singleton.update:
		$ShooterTimer.start()
	elif Singleton.update:
		$ShooterTimer.stop()
	#----------------------------------------------------------------------------------------------
	if Singleton.score > 200 and $PowerUpTimer.is_stopped():
		$PowerUpTimer.start()
	#----------------------------------------------------------------------------------------------
	if Singleton.score > 1000 and Singleton.score < 1100 and !Singleton.boss:
		Singleton.boss = true
		$ShooterTimer.stop()
		$ninjaSpawn.stop()
		var boss1 = Boss1.instance()
		add_child(boss1)
	#----------------------------------------------------------------------------------------------
	if Singleton.score > 2000 and Singleton.boss:
		var p = PowerUp.instance()
		p.power = 4
		add_child(p)
		p.position = Vector2(screensize.x/2,screensize.y/2)
		Singleton.boss = false
		if $ninjaSpawn.wait_time == 0.7:
			$ninjaSpawn.wait_time = 1.2
		if $ShooterTimer.wait_time == 6:
			$ShooterTimer.wait_time = 4
	#----------------------------------------------------------------------------------------------
	if !Singleton.boss and $ninjaSpawn.is_stopped() and !Singleton.update:
		$ninjaSpawn.start()
	elif Singleton.update:
		$ninjaSpawn.stop()
	#----------------------------------------------------------------------------------------------
	if Singleton.lifes == 0:
		check_highscore()
		$GameOverTimer.start()
		get_tree().paused = true
	#-------------------------- Actualizaciones de pantalla ---------------------------------------
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
	#----------------------------------------------------------------------------------------------
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
	var e = Enemy.instance()
	e.type = 0
	add_child(e)
	
#-----------------------------------------------------------------------------------------------------
func _on_ShooterTimer_timeout():
	var choose = 2
	if Singleton.score > 2000:
		choose = randi()%2+1
	var e = Enemy.instance()
	e.type = choose
	add_child(e)
	
#-----------------------------------------------------------------------------------------------------
func _on_PowerUpTimer_timeout():
	randomize()
	var p = PowerUp.instance()
	var a = [1,1,1,1,1,1,2,2,3,3]
	var b
	var range_ = 8

	if Singleton.score > 2000:
		range_ = 10 # Genera numeros de 0 a 9


	b = randi()%range_+0
	p.power = a[b]
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
	Singleton.boss = false
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
	Singleton.boss = false
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



