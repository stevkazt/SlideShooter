extends Node2D

@export var Enemy:PackedScene
@export var PLAYER:PackedScene
@export var PowerUp:PackedScene
@export var Boss1:PackedScene

var player
var score_file = "user://highscore.txt"
var higscore = 0
var screensize
var Icons = [0,"stair","shield","rocket"]


# Called when the node enters the scene tree for the first time.
func _ready():
	
	#testing
	#
	randomize()
	if !Singleton.sfx:
		$Buttons/pause_menu/sfx/sfx.animation = "sfx_off"
	screensize =  get_viewport_rect().size
	$Buttons.global_position = Vector2(screensize.x-110,screensize.y-110)
	player =  PLAYER.instantiate()
	add_child(player)
	player.position = Vector2(screensize.x/2,900)

func _process(_delta):
	if Singleton.powers.available and $Powers.hidden:
		$Powers/AnimatedSprite.animation = Icons[Singleton.powers.type]
		$Powers.show()
	else:
		$Powers.hide()
	
	if Singleton.lifes == 0 and $GameOverTimer.is_stopped():
		get_tree().paused = true
		check_highscore()
		$GameOverTimer.start()
		
	if Singleton.score > 1000 and Singleton.boss:
		Singleton.boss = false
	if Singleton.score > 500 and Singleton.score < 600 and !Singleton.boss:# 1000 - 1100
		Singleton.boss = true
		$ShooterTimer.stop()
		$ninjaSpawn.stop()
		var boss1 = Boss1.instantiate()
		add_child(boss1)
		
	if !Singleton.boss and $ninjaSpawn.is_stopped():
		$ninjaSpawn.start()
		
	$Score.text = str(Singleton.score)
	if Singleton.lifes < 3:
		$Lifes/Life3.hide()
		if Singleton.lifes < 2:
			$Lifes/Life2.hide()
			if Singleton.lifes < 1:
				$Lifes/Life1.hide()
	
	if Singleton.lifes == 3:
		$Lifes.add_theme_color_override("font_color",Color(0,1,0,1))
	elif Singleton.lifes == 2:
		$Lifes.add_theme_color_override("font_color",Color("#ffb300"))
	elif Singleton.lifes == 1:
		$Lifes.add_theme_color_override("font_color",Color(1,0,0,1))
	#Empieza shooter
	if Singleton.score > 100 and $ShooterTimer.is_stopped() and !Singleton.boss:
		$ShooterTimer.start()
	#empiezan power ups
	if Singleton.score > 10 and $PowerUpTimer.is_stopped():#200
		$PowerUpTimer.start()
	
func _on_EnemySpawn_timeout():
	var e = Enemy.instantiate()
	e.type = 0
	add_child(e)

func _on_GameOverTimer_timeout():
	update_highscore()
	var Main = load("res://Scenes/Main.tscn")
	var main = Main.instantiate()
	get_tree().paused = false
	Singleton.lifes = 3
	Singleton.score = 0
	Singleton.powers.available = 0
	Singleton.boss = false
	get_parent().add_child(main)
	queue_free()

func update_highscore():
	if Singleton.score > int(FileAccess.open(score_file,FileAccess.READ).get_as_text()):
		var f = FileAccess.open(score_file,FileAccess.WRITE)
		f.store_string(str(Singleton.score))

func check_highscore():
	if FileAccess.file_exists(score_file):
		var f = FileAccess.open(score_file,FileAccess.READ)
		var content = f.get_as_text()
		higscore = int(content)

func _on_ShooterTimer_timeout():
	var e = Enemy.instantiate()
	e.type = 1
	add_child(e)

func _on_PowerUpTimer_timeout():
		# This code instantite a new power up
		randomize()
		var power = PowerUp.instantiate()
		var distribution = [1,1,1,1,1,1,1,1,2,2,2,2]
		var rand_position = randi()%12+0
		power.type = distribution[rand_position]
		add_child(power)
		power.position = Vector2(randf_range(150,600),randf_range(400,1120))

func _on_sfx_pressed():
	if Singleton.sfx:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),true)
		$Buttons/pause_menu/sfx/sfx.animation = "sfx_off"
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),false)
		$Buttons/pause_menu/sfx/sfx.animation = "sfx_on"
	Singleton.sfx = !Singleton.sfx

func _on_Button_yes_pressed():
	var Main = load("res://Scenes/Main.tscn")
	var main = Main.instantiate()
	get_tree().paused = false
	Singleton.lifes = 3
	Singleton.score = 0
	Singleton.boss = false
	get_parent().add_child(main)
	queue_free()

func _on_Button_no_pressed():
	$Buttons/pause_menu/home/Button_yes.hide()
	$Buttons/pause_menu/home/Button_no.hide()

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
	$Buttons/pause_menu/home/Button_no.show()
	$Buttons/pause_menu/home/Button_yes.show()
