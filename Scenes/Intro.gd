extends Control


func _on_Timer_timeout():
	var Main = load("res://Scenes/Main.tscn")
	var main = Main.instance()
	get_tree().paused = false
	add_child(main)
	queue_free()
