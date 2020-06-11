extends Control


var screensize
var settings = false


func _ready():
	screensize =  get_viewport_rect().size
	randomize()
	$Screen.rect_size.y = screensize.y
	$Screen/Down.rect_global_position = Vector2(0,screensize.y-130)
	
	if !Singleton.sfx:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),true)
		$Screen/Down/Settings/sfx/sfx.animation = "sfx_off"

	
func _process(_delta):
	$ParallaxBackground/ParallaxLayer.motion_offset.y += 1


func _on_sfx_pressed():
	if Singleton.sfx:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),true)
		$Screen/Down/Settings/sfx/sfx.animation = "sfx_off"
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),false)
		$Screen/Down/Settings/sfx/sfx.animation = "sfx_on"
	Singleton.sfx = !Singleton.sfx


func _on_Settings_pressed():
	if !settings:
		$Screen/Down/Store.hide()
		$Screen/Down/home.hide()
		$Screen/Down/about.hide()
		$Screen/Down/Settings/sfx.show()
	else:
		$Screen/Down/Store.show()
		$Screen/Down/home.show()
		$Screen/Down/about.show()
		$Screen/Down/Settings/sfx.hide()
	settings = !settings


func _on_home_pressed():
	var Main = load("res://Scenes/Main.tscn")
	var main = Main.instance()
	get_parent().add_child(main)
	queue_free()
	

func _on_Store_pressed():
	var Store = load("res://Scenes/Store.tscn")
	var store = Store.instance()
	get_parent().add_child(store)
	queue_free()

	var TPowers = load("res://Scenes/Tuto_Powers.tscn")
	var tpowers= TPowers.instance()
	get_parent().add_child(tpowers)
	queue_free()


func _on_tutorials_pressed():
	var Tutorials = load("res://Scenes/Tutorials.tscn")
	var tutos = Tutorials.instance()
	get_parent().add_child(tutos)
	queue_free()
