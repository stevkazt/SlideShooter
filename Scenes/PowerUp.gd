extends Area2D
var power = 0


func _ready():
	$Dissapear.start()
	match power:
		0:
			queue_free()
		1:
			$AnimatedSprite.animation = "stair"
		2:
			$AnimatedSprite.animation = "shield"
		

func _on_PowerUp_area_entered(_area):
	if Singleton.powers.size()<3:
		$CollisionShape2D.queue_free()
		$sfx_taken.play()
		hide()
		match power:
			1:
				Singleton.powers.push_front(1)
			2:
				Singleton.powers.push_front(2)
			2:
				Singleton.powers.push_front(3)


func _on_sfx_taken_finished():
	queue_free()


func _on_Dissapear_timeout():
	queue_free()
