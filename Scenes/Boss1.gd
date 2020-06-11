extends Area2D


export (PackedScene) var bullet 
export (PackedScene) var minions

var screensize
var set_pos = Vector2()
var target = null
var laser_count = 0
var missile_counter = 0
var type = 10
var can_get_damage = true
var minions_count = 0
var part = 0


#-----------------------------------------------------------------------------------------------------
func _ready():
	target = get_tree().get_nodes_in_group("player")[0]
	screensize = get_viewport_rect().size
	position = Vector2(360,screensize.y)
	set_pos = Vector2(360,screensize.y-200)
	
#-----------------------------------------------------------------------------------------------------
func _process(delta):
		
	var target_dir = (target.global_position - global_position).normalized()
	var current_dir = Vector2(1, 0).rotated(self.global_rotation)
	
	if Singleton.score > 1100 and part == 0:
		target_dir = Vector2(0,1)
		if  can_get_damage:
			$ShooterTimer.start()
			$Laser1Timer.stop()
			can_get_damage = false
			set_pos = Vector2(360,screensize.y+200)
		
	if Singleton.score > 1200 and part == 1:
		target_dir = Vector2(0,-1)
		if  can_get_damage:
			$AnimatedSprite.animation = "damage"
			$ShooterTimer.start()
			$Laser1Timer.stop()
			can_get_damage = false
			set_pos = Vector2(360,-200)
			
	if Singleton.score > 1300 and part == 2:
		target_dir = Vector2(1,0)
		if  can_get_damage:
			$ShooterTimer.start()
			$Laser1Timer.stop()
			can_get_damage = false
			set_pos = Vector2(920,screensize.y/2)
	
	if Singleton.score > 1400 and part == 3:
		target_dir = Vector2(-1,0)
		if  can_get_damage:
			$ShooterTimer.start()
			$Laser1Timer.stop()
			can_get_damage = false
			set_pos = Vector2(-200,screensize.y/2)
			
	if Singleton.score > 1450 and can_get_damage:
		set_pos = target.position
		
	if Singleton.score > 1600 and can_get_damage:
		set_pos = Vector2(screensize.x/2,screensize.y/2)
		if Singleton.score > 1680:
			$Laser.show()
			$AnimatedSprite.animation = "laser"
			$Laser/CollisionShape2D.disabled = false
	
	if Singleton.score > 2000:
		$Mini.global_position = $Mini.global_position.linear_interpolate(Vector2(400,-200), delta*.4)
		$Mini.global_rotation_degrees = -180 
	
	position = position.linear_interpolate(set_pos, delta*0.5)
	if can_get_damage:
		self.global_rotation = current_dir.linear_interpolate(target_dir, delta*2).angle()
	
#-----------------------------------------------------------------------------------------------------
func _on_Boss1_area_entered(area):
	if area.get_collision_layer_bit(0) or area.get_collision_layer_bit(5) and can_get_damage:
		Singleton.score += 4
		if Singleton.score >2000:
			$sfx_explode.play()
			$FinalTimer.start()
			$Laser.hide()
			$AnimatedSprite.animation = "explode"
			call_deferred("$CollisionShape2D.disabled","true")
			$MissilesTimer.stop()
			$Laser1Timer.stop()
			$Laser2Timer.stop()
			can_get_damage = false
			$Mini.show()
	
#-----------------------------------------------------------------------------------------------------
func _on_Timer_timeout():
	set_pos = Vector2(rand_range(100,screensize.x-100),screensize.y-200)
	
#-----------------------------------------------------------------------------------------------------
func _on_Laser1Timer_timeout():
	var b = bullet.instance()
	b.team = 2
	b.scale = Vector2(2,2)
	get_parent().add_child(b)
	b.start($Position2D2.global_position,Vector2(1, 0).rotated($Position2D.global_rotation),1,2)
	$Laser2Timer.start()
	laser_count += 1
	
	if laser_count > 5 and can_get_damage:
		$MissilesTimer.start()
		missile_counter = 0
		laser_count = 0
	
#-----------------------------------------------------------------------------------------------------
func _on_Laser2Timer_timeout():
	var b = bullet.instance()
	b.team = 2
	b.scale = Vector2(2,2)
	get_parent().add_child(b)
	b.start($Position2D3.global_position,Vector2(1, 0).rotated($Position2D.global_rotation),1,2)
	
#-----------------------------------------------------------------------------------------------------
func _on_MissilesTimer_timeout():
	missile_counter += 1
	if missile_counter < 3:
		$MissilesTimer.start()
		var b = bullet.instance()
		b.team = 2
		get_parent().add_child(b)
		b.start($Position2D2.global_position,Vector2(1, 0).rotated($Position2D.global_rotation),2,2)
	
#-----------------------------------------------------------------------------------------------------

func _on_ShooterTimer_timeout():
	if minions_count <= 5:
		var m = minions.instance()
		m.ninja_sprite = 2
		m.type = 0
		m.can_get_damage = false
		get_parent().add_child(m)
		m = minions.instance()
		m.ninja_sprite = 2
		m.type = 0
		m.can_get_damage = false
		get_parent().add_child(m)
		m = minions.instance()
		m.type = 1
		m.can_get_damage = false
		get_parent().add_child(m)
		minions_count += 1
	else:
		if part == 0:
			position = Vector2(360,-200)
			set_pos = Vector2(360,200)
		if part == 1:
			position = Vector2(920,screensize.y/2)
			set_pos = Vector2(520,screensize.y/2)
		if part == 2:
			position = Vector2(-200,screensize.y/2)
			set_pos = Vector2(200,screensize.y/2)
		if part == 3:
			position = Vector2(360,screensize.y+200)
			set_pos = Vector2(360,screensize.y-200)
		$ShooterTimer.stop()
		$Laser1Timer.start()
		can_get_damage = true
		part += 1
		minions_count = 0 



func _on_FinalTimer_timeout():
	var PowerUp = load("res://Scenes/PowerUp.tscn")
	var p = PowerUp.instance()
	p.power = 4
	get_parent().add_child(p)
	p.position = Vector2(screensize.x/2,screensize.y/2)
	queue_free()
