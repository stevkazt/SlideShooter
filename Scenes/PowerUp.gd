extends Area2D
var type = 0


func _ready():
	$Dissapear.start()
	match type:
		0:
			queue_free()
		1:
			$AnimatedSprite.animation = "stair"
		2:
			$AnimatedSprite.animation = "shield"

func _on_PowerUp_area_entered(_area):
	Singleton.powers.available = true
	Singleton.powers.type = type
	$CollisionShape2D.queue_free()
	$sfx_taken.play()
	hide()

func _on_sfx_taken_finished():
	queue_free()

func _on_Dissapear_timeout():
	queue_free()
