extends Area2D
var power = 0

#-----------------------------------------------------------------------------------------------------
func _ready():
	if power != 4:
		$Dissapear.start()
	match power:
		0:
			queue_free()
		1:
			$AnimatedSprite.animation = "stair"
		2:
			$AnimatedSprite.animation = "shield"
		3:
			$AnimatedSprite.animation = "rocket"
		4:
			$AnimatedSprite.animation = "double_shoot"
	
	Singleton.last_powers.push_front(power)
	if Singleton.last_powers.size() > 3:
		Singleton.last_powers.pop_back()
#-----------------------------------------------------------------------------------------------------
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
			3:
				Singleton.powers.push_front(3)
	if power == 4:
		$sfx_taken.play()
		Singleton.boss = false
		
	
#-----------------------------------------------------------------------------------------------------
func _on_sfx_taken_finished():
	queue_free()
	
#-----------------------------------------------------------------------------------------------------
func _on_Dissapear_timeout():
	queue_free()
	
#-----------------------------------------------------------------------------------------------------
