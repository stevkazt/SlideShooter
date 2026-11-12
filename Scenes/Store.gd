extends Control


@export var Asteroid: PackedScene



var screensize
var settings = false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	screensize =  get_viewport_rect().size
	randomize()
	$Screen.size.y = screensize.y
	$Screen/Down.global_position = Vector2(0,screensize.y-130)
	
	if !Singleton.sfx:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),true)
		$Screen/Down/Settings/sfx/sfx.animation = "sfx_off"

	
func _process(_delta):
	$AsteroidTimer.wait_time = randf_range(.5,2)
	$ParallaxBackground/ParallaxLayer.motion_offset.y += 1


func _on_AsteroidTimer_timeout():
	if get_tree().get_nodes_in_group("asteroids").size() < 20:
		var ast = Asteroid.instantiate()
		add_child(ast)


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
		$Screen/Down/home.hide()
		$Screen/Down/tutorials.hide()
		$Screen/Down/about.hide()
		$Screen/Down/Settings/sfx.show()
	else:
		$Screen/Down/home.show()
		$Screen/Down/tutorials.show()
		$Screen/Down/about.show()
		$Screen/Down/Settings/sfx.hide()
	settings = !settings


func _on_tutorial_pressed():
	var Tutorials = load("res://Scenes/Tutorials.tscn")
	var tutos = Tutorials.instantiate()
	get_parent().add_child(tutos)
	queue_free()

	


func _on_home_pressed():
	var Main = load("res://Scenes/Main.tscn")
	var main = Main.instantiate()
	get_parent().add_child(main)
	queue_free()
