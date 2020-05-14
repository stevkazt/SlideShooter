extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _on_AnimationPlayer_animation_finished(anim_name):
	var BG2 = load("res://Scenes/Background2.tscn")
	var background2 = BG2.instance()
	get_parent().get_node("BG").add_child(background2)
	Singleton.update = false
	Singleton.lifes = 3
	#get_tree().get_nodes_in_group("player")[0].can_get_damage = true
	queue_free()
	
	
