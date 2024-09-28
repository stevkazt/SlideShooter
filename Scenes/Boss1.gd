extends Area2D


@export var bullet : PackedScene

var screensize
var set_pos = Vector2()
var target = null
var laser_count = 0
var missile_counter = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	target = get_tree().get_nodes_in_group("player")[0]
	screensize = get_viewport_rect().size
	position = Vector2(randf_range(0,screensize.x),screensize.y)
	set_pos = Vector2(randf_range(100,screensize.x-100),screensize.y-200)

func _process(delta):
	if Singleton.score >2000:
		queue_free()
	if Singleton.score > 1500:
		position = position.lerp(Vector2(screensize.x/2,screensize.y/2), delta*0.5)
		if Singleton.score > 1540:
			$Laser.show()
			#$AnimatedSprite.animation = "laser"
			$Laser/CollisionShape2D.disabled = false
	else:
		if $PosTimer.is_stopped():
			$PosTimer.wait_time = randf_range(1,2)
			$PosTimer.start()
			
		position = position.lerp(set_pos, delta*0.5)
	var target_dir = (target.global_position - global_position).normalized()
	var current_dir = Vector2(1, 0).rotated(self.global_rotation)
	self.global_rotation = current_dir.lerp(target_dir, delta*2).angle()
	


func _on_Boss1_area_entered(area):
	if area.get_collision_layer_bit(0) or area.get_collision_layer_bit(5):
		Singleton.score += 5



func _on_Timer_timeout():
	set_pos = Vector2(randf_range(100,screensize.x-100),screensize.y-200)


func _on_MissileTimer_timeout():
	var b = bullet.instance()
	b.team = 2
	b.scale = Vector2(2,2)
	get_parent().add_child(b)
	b.start($Position2D2.global_position,Vector2(1, 0).rotated($Position2D.global_rotation),1,2)
	$Laser2Timer.start()
	laser_count += 1
	
	if laser_count > 5:
		$MissilesTimer.start()
		missile_counter = 0
		laser_count = 0
	

func _on_Laser2Timer_timeout():
	var b = bullet.instance()
	b.team = 2
	b.scale = Vector2(2,2)
	get_parent().add_child(b)
	b.start($Position2D3.global_position,Vector2(1, 0).rotated($Position2D.global_rotation),1,2)



func _on_MissilesTimer_timeout():
	missile_counter += 1
	if missile_counter < 3:
		$MissilesTimer.start()
		var b = bullet.instance()
		b.team = 2
		get_parent().add_child(b)
		b.start($Position2D2.global_position,Vector2(1, 0).rotated($Position2D.global_rotation),2,2)
		
