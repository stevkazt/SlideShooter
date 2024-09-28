extends Node2D

@export var Enemy:PackedScene
@export var PLAYER:PackedScene
@export var PowerUp:PackedScene
@export var Boss1:PackedScene

var player
var score_file = "user://highscore"
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
	$Buttons.global_position = Vector2(0,screensize.y-130)
	player =  PLAYER.instantiate()
	add_child(player)
	player.position = Vector2(360,900)



func _process(_delta):
	if Singleton.score > 2000 and Singleton.boss:
		Singleton.boss = false
	if Singleton.score > 1000 and Singleton.score < 1100 and !Singleton.boss:
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
	if Singleton.score > 200 and $PowerUpTimer.is_stopped():
		$PowerUpTimer.start()
	if Singleton.lifes == 0:
		check_highscore()
		$GameOverTimer.start()
		get_tree().paused = true
		




func _on_EnemySpawn_timeout():
	var e = Enemy.instantiate()
	e.type = 0
	add_child(e)
	


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



func _on_GameOverTimer_timeout():
	var Main = load("res://Scenes/Main.tscn")
	var main = Main.instantiate()
	get_tree().paused = false
	Singleton.lifes = 3
	Singleton.score = 0
	Singleton.boss = false
	get_parent().add_child(main)
	queue_free()

func update_highscore():
	var f = FileAccess.open(score_file,FileAccess.WRITE)
	f.store_string(str(Singleton.score))
	f.close()
	

func check_highscore():
	if FileAccess.file_exists(score_file):
		var f = FileAccess.open(score_file,FileAccess.READ)
		var content = f.get_as_text()
		higscore = int(content)
		f.close()
		

func _on_ShooterTimer_timeout():
	var e = Enemy.instantiate()
	e.type = 1
	add_child(e)


func _on_PowerUpTimer_timeout():
		randomize()
		var p = PowerUp.instantiate()
		var a = [1,1,1,1,1,1,1,1,2,2,2,2]
		var b = randi()%12+0
		p.power = a[b]
		add_child(p)
		p.position = Vector2(randf_range(150,600),randf_range(400,1120))




func _on_Power2_pressed():
	if Singleton.powers.size() >= 2:
		var p0 = Singleton.powers[0]
		var p1 = Singleton.powers[1]
		Singleton.powers[0] = p1
		Singleton.powers[1] = p0
	
func _on_Power3_pressed():
	if Singleton.powers.size() == 3:
		var p0 = Singleton.powers[0]
		var p1 = Singleton.powers[1]
		var p2 = Singleton.powers[2]
		Singleton.powers[0] = p2
		Singleton.powers[1] = p0
		Singleton.powers[2] = p1


func _on_home_pressed():
	$Buttons/pause_menu/home/Button_yes.show()
	$Buttons/pause_menu/home/Button_no.show()

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
	Singleton.powers.resize(0)
	Singleton.boss = false
	get_parent().add_child(main)
	queue_free()


func _on_Button_no_pressed():
	$Buttons/pause_menu/home/Button_yes.hide()
	$Buttons/pause_menu/home/Button_no.hide()
