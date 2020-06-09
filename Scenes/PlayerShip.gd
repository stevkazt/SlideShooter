extends Area2D


var target = null
var dis : Array
var enemytypes : Array


var drag 
var dragging
var s_size
var can_get_damage = !true
var taps = 0
var shields_number = 0
var shield = false
var lost_shield_played = false
var double_shoot = false
var mov_modifier = 1

export (PackedScene) var Bullet
export (PackedScene) var FlashScreen

#-----------------------------------------------------------------------------------------------------
func _ready():
	s_size = get_viewport_rect().size
	Singleton.score = 950
	#Singleton.lifes = 2
	
#-----------------------------------------------------------------------------------------------------
func _process(delta):
	if $LaserTimer.is_stopped() and position != Vector2(s_size.x/2,s_size.y/2) and !Singleton.update:
		$LaserTimer.start()
	
	if shield:
		_powerupShieldprocess()	
	#--------------- Rotacion y movimiento -------------------------------------------------------
	if drag and dragging:
		position += drag*mov_modifier
		position.x = clamp(position.x,50,s_size.x-50)
		position.y = clamp(position.y,100,s_size.y-150)

	who_to()
	var target_dir
	var current_dir = Vector2(1, 0).rotated(self.global_rotation)
	if target:
		target_dir = (target.global_position - global_position).normalized()
		self.global_rotation = current_dir.linear_interpolate(target_dir, delta*10*mov_modifier).angle()
	if Singleton.update:
		target_dir = Vector2(0,-1)
		self.global_rotation = current_dir.linear_interpolate(target_dir, delta*4).angle()
		self.global_position = global_position.linear_interpolate(Vector2(360,1000),delta)
	
#-----------------------------------------------------------------------------------------------------
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if Singleton.powers.size() > 0:
				taps += 1
				$TapTimer.start()
				if taps == 2 and event.position.y < s_size.y-200:
					match Singleton.powers[0]:
						1:
							_powerupStair()
						2:
							_powerupShield()
						3:
							_powerupRocket()
					Singleton.powers.remove(0)
					taps = 0
			dragging = true
		elif event.button_index == BUTTON_LEFT and !event.pressed:
			dragging = false
	if event is InputEventScreenDrag:
		drag = event.relative
	
#-----------------------------------------------------------------------------------------------------
func who_to():
	var enemies_in_area = $Area2D.get_overlapping_areas()
	enemytypes = Array()
	if enemies_in_area.size() > 0:
		dis = Array()
		for i in range(0, enemies_in_area.size()):
			if enemies_in_area[i].get_collision_layer_bit(3):
				var meteor = enemies_in_area[i].get_child(0)
				dis.append(position.distance_to(meteor.global_position))
			else:
				dis.append(position.distance_to(enemies_in_area[i].position))
			var closest_enemy_index = dis.rfind(dis.min())
			target = enemies_in_area[closest_enemy_index]
			
	else:
		target = null
	
#-----------------------------------------------------------------------------------------------------
func _on_LaserTimer_timeout():
	if double_shoot:
		var dir = Vector2(1, 0).rotated($Position2D2.global_rotation)
		var b = Bullet.instance()
		get_parent().add_child(b)
		b.start($Position2D2.global_position, dir,1,1)
		dir = Vector2(1, 0).rotated($Position2D3.global_rotation)
		b = Bullet.instance()
		get_parent().add_child(b)
		b.start($Position2D3.global_position, dir,1,1)
	else:
		var dir = Vector2(1, 0).rotated($Position2D.global_rotation)
		var b = Bullet.instance()
		get_parent().add_child(b)
		b.start($Position2D.global_position, dir,1,1)
	
#-----------------------------------------------------------------------------------------------------
func _powerupStair():
	var b = Bullet.instance()
	for i in range(18):
		get_parent().add_child(b)
		b.start(global_position,Vector2(1,0).rotated(deg2rad(20*i)),1,1)
		b = Bullet.instance()
	$sfx_stair.play()
	
#-----------------------------------------------------------------------------------------------------
func _powerupShield():
	$sfx_shielup.play()
	can_get_damage = false
	shields_number = 3
	shield = true
	
#-----------------------------------------------------------------------------------------------------
func _powerupShieldprocess():
	if double_shoot:
		$Sprite.animation = "PowerShield2"
	else:
		$Sprite.animation = "PowerShield"
		
	if shields_number == 3:
		$Sprite.stop()
		$Sprite.set_frame(0)
	if shields_number == 2:
		if !$sfx_lost_shield.playing  and !lost_shield_played:
			$sfx_lost_shield.play()
		$Sprite.stop()
		$Sprite.set_frame(1)
	if shields_number == 1 :
		if !$sfx_lost_shield.playing and !lost_shield_played:
			$sfx_lost_shield.play()
		$Sprite.stop()
		$Sprite.set_frame(2)
	if shields_number == 0:
		if !$sfx_lost_shield.playing  and !lost_shield_played:
			$sfx_lost_shield.play()
		if double_shoot:
			$Sprite.animation = "Player2"
		else:
			$Sprite.animation = "default"
		shield = false
		can_get_damage = true
	
#-----------------------------------------------------------------------------------------------------
func _powerupRocket():
	var b = Bullet.instance()
	b.team = 2
	get_parent().add_child(b)
	b.start($Position2D.global_position,Vector2(1, 0).rotated($Position2D.global_rotation),2,1)
	
#-----------------------------------------------------------------------------------------------------
func _on_PlayerShip_area_entered(area):
	# ----------------------- BOSS SHIELD ----------------------
	if shield and area.get_collision_layer_bit(7):
		shields_number=0
		lost_shield_played = false
	# ------------------------ BOSS LASER -----------------------
	if can_get_damage and area.get_collision_layer_bit(7): 
		Singleton.lifes = 0
		$Sprite.play("explode")
		$sfx_lose.play()
		Singleton.powers.resize(0)
	# ------------------------------ SHIELD ------------------
	elif shield and !area.get_collision_layer_bit(4):
		shields_number-=1
		lost_shield_played = false
	# ----------------------- NORMAL ENEMY ----------------------
	elif can_get_damage and !area.get_collision_layer_bit(4): 
		#Input.vibrate_handheld(500)
		if !Singleton.update:
			can_get_damage = false
			$sfx_shielup.play()
			
		if double_shoot:
			$Sprite.play("Player2Shield")
		else:
			$Sprite.play("shield")
			
		$LifeTimer.start()
		Singleton.lifes -= 1
		if Singleton.lifes == 0:
			Singleton.powers.resize(0)
			$Sprite.play("explode")
			$sfx_lose.play()
	# --------------------- UPGRADE 1 ----------------------
	if area.get_collision_layer_bit(4):
		if area.power == 4:
			var flash = FlashScreen.instance()
			get_parent().add_child(flash)
			Singleton.update = true
			can_get_damage = false
			$UpdateTimer.start()
			$Sprite.play("upgrade1")
	
#-----------------------------------------------------------------------------------------------------
func _on_LifeTimer_timeout():
	if double_shoot:
		$Sprite.play("Player2")
	else:
		$Sprite.play("default")
		
	if Singleton.update:
		pass
	else:
		can_get_damage = true
	$sfx_shielup.stop()
	$sfx_shielddown.play()
	
#-----------------------------------------------------------------------------------------------------
func _on_TapTimer_timeout():
	taps = 0
	
#-----------------------------------------------------------------------------------------------------
func _on_sfx_lost_shield_finished():
	lost_shield_played = true
	
#-----------------------------------------------------------------------------------------------------
func _on_UpdateTimer_timeout():
	var enemies = get_tree().get_nodes_in_group("enemy")
	for i in range(enemies.size()):
		if enemies[i]:
			enemies[i].queue_free()
	var Transition = load("res://Scenes/Transition1.tscn")
	var transition = Transition.instance()
	get_parent().add_child(transition)
	Singleton.update = true
	$LaserTimer.stop()
	$Sprite.animation = "Player2"
	$CollisionShape2D.scale = Vector2(1.2,1.2)
	double_shoot = true
	Singleton.update = true
	# For Demo
	$LaserTimer.stop()
