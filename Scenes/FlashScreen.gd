extends Node2D


var screensize


func _ready():
	screensize =  get_viewport_rect().size
	position = Vector2(screensize.x/2,screensize.y/2)


func _on_Timer_timeout():
	$AnimatedSprite.play("white")
	$Timer2.start()


func _on_Timer2_timeout():
	queue_free()
