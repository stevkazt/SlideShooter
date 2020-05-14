extends Area2D

export (int) var speed
var team = 1
var type =1
#export (int) var damage
var screensize
var velocity = Vector2()
var target
var missile_side
var rocketlaunch

# type 1 = laser
# type 2 = missile


#-----------------------------------------------------------------------------------------------------
func start(_position, _direction, _type,_team):
	screensize = get_viewport_rect().size
	type = _type
	team = _team
	
	#----------- Player Team ----------------------------------------------------------------------
	if team == 1:
		if type == 1:
			$sfx_laser_player.play()
		if type == 2:
			$CollisionShape2D.scale = Vector2(2,2)
			rocketlaunch = false
			$Sprite.play("launch_missile")
			set_collision_layer_bit(8,true)
			var enemies =  get_tree().get_nodes_in_group("enemy")
			var types : Array
			for i in range(enemies.size()):
				types.append(enemies[i].type)
			if types.size() > 0:
				target = enemies[types.rfind(types.max())]
	#----------- Enemy Team -----------------------------------------------------------------------
	if team == 2:
		set_collision_layer_bit(5,false)
		if type == 1:
			$sfx_laser_enemy.play()
			$Sprite.animation = "enemy"
			set_collision_mask_bit(0,true)
		if type == 2:
			$CollisionShape2D.scale = Vector2(2,2)
			rocketlaunch = false
			$Sprite.animation = "missile"
			set_collision_layer_bit(9,true)
			target = get_tree().get_nodes_in_group("player")[0]
			missile_side  = randi()%2+1
	#----------- Default Movement -----------------------------------------------------------------
	position = _position
	rotation = _direction.angle()
	velocity = _direction * speed
	
#-----------------------------------------------------------------------------------------------------
func _process(delta):
	if type == 2:
		missile_process(delta)
	else:
		position += velocity * delta
	
#-----------------------------------------------------------------------------------------------------
func missile_process(delta):
	#----------------------------------------------------------------------------------------------
	if team == 1:
		if weakref(target).get_ref():
			velocity =  (target.global_position - global_position).normalized() * 600
			position += velocity* delta
			var target_dir = (target.global_position - global_position).normalized()
			var current_dir = Vector2(1, 0).rotated(self.global_rotation)
			self.global_rotation = current_dir.linear_interpolate(target_dir, delta*10).angle()
		else:
			position = Vector2()
			$Sprite.play("explode")
			
	#----------------------------------------------------------------------------------------------
	if team == 2:
		if position.x > 70 and position.x < 650 and !rocketlaunch: 
			if missile_side == 1:
				position = position.linear_interpolate(Vector2(50,screensize.y/2), delta*0.8)
			if missile_side == 2:
				position = position.linear_interpolate(Vector2(670,screensize.y/2), delta*0.8)
				
			var target_dir = (target.global_position - global_position).normalized()
			var current_dir = Vector2(1, 0).rotated(self.global_rotation)
			self.global_rotation = current_dir.linear_interpolate(target_dir, delta*10).angle()
			velocity =  (target.global_position - global_position).normalized() * 600
		else:
			if !rocketlaunch:
				rocketlaunch = true
				$Sprite.play("launch_missile")
			position += velocity * delta
	
#-----------------------------------------------------------------------------------------------------
func _on_Bullet_area_entered(area):
	if team == 1 and (area.get_collision_layer_bit(2) or area.get_collision_layer_bit(9)):
		if type ==1:
			pass
		velocity = Vector2()
		$CollisionShape2D.queue_free()
		$Sprite.play("explode")
	if team == 2 and (area.get_collision_layer_bit(0) or area.get_collision_layer_bit(5)):
		scale = Vector2(1,1)
		velocity = Vector2()
		$CollisionShape2D.queue_free()
		$Sprite.play("explodeenemy")
	
#-----------------------------------------------------------------------------------------------------
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	
#-----------------------------------------------------------------------------------------------------
func _on_Sprite_animation_finished():
	if $Sprite.animation == "explode" or $Sprite.animation == "explodeenemy":
		queue_free()
	
#-----------------------------------------------------------------------------------------------------


