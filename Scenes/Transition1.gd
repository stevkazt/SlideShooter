extends Node2D


func _on_AnimationPlayer_animation_finished(_anim_name):
	get_tree().paused = true
	
#	var BG2 = load("res://Scenes/Background2.tscn")
#	var background2 = BG2.instance()
#	get_parent().get_node("Stage0").queue_free()
#	Singleton.update = false
#	Singleton.lifes = 3
#	get_tree().get_nodes_in_group("player")[0].can_get_damage = true
#	queue_free()
	
	
