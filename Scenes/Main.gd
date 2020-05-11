extends Control

export (PackedScene) var Game 
export (PackedScene) var Tutorials
export (PackedScene) var Store

var score_file = "user://highscore"
var higscore = 0
var screensize
var settings = false
	
#--------------------------------
func _ready():
	screensize =  get_viewport_rect().size
	randomize()
	load_score()
	$Screen.rect_size.y = screensize.y
	$Screen/Up.rect_size.y = (screensize.y/2)+160
	$Screen/Down.rect_global_position = Vector2(0,screensize.y-130)

	if !Singleton.sfx:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),true)
		$Screen/Down/Settings/sfx/sfx.animation = "sfx_off"
	
#--------------------------------
func load_score():
	var f = File.new()
	if f.file_exists(score_file):
		f.open(score_file,File.READ)
		var content = f.get_as_text()
		higscore = int(content)
		f.close()
		$Screen/Up/HighScore.text = str(higscore)
	
#--------------------------------
func _process(_delta):
	pass
	#$ParallaxBackground/ParallaxLayer.motion_offset.y += 1
	
#---------------------------------
func _on_Button_pressed():
	var game = Game.instance()
	get_parent().add_child(game)
	$Screen.hide()
	queue_free()
	
#--------------------------------
func _on_sfx_pressed():
	if Singleton.sfx:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),true)
		$Screen/Down/Settings/sfx/sfx.animation = "sfx_off"
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),false)
		$Screen/Down/Settings/sfx/sfx.animation = "sfx_on"
	Singleton.sfx = !Singleton.sfx
	
#--------------------------------
func _on_Settings_pressed():
	if !settings:
		$Screen/Down/Store.hide()
		$Screen/Down/tutorial.hide()
		$Screen/Down/about.hide()
		$Screen/Down/Settings/sfx.show()
	else:
		$Screen/Down/Store.show()
		$Screen/Down/tutorial.show()
		$Screen/Down/about.show()
		$Screen/Down/Settings/sfx.hide()
	settings = !settings
	
#--------------------------------
func _on_tutorial_pressed():
	var tutos = Tutorials.instance()
	get_parent().add_child(tutos)
	queue_free()
	
#--------------------------------
func _on_Store_pressed():
	var store = Store.instance()
	get_parent().add_child(store)
	queue_free()
