extends Area2D

@export var speed: int
#@export var damage: int

var velocity = Vector2()
var dir = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	position = Vector2(randf_range(50,670),0)

	var objetive = Vector2(randf_range(position.x-50,position.x+50),1280)
	dir = (objetive-position).normalized()
	
func _process(delta):
	velocity = dir*speed
	rotation = dir.angle()
	position += velocity * delta

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()


func _on_Timer_timeout():
	speed += 20
