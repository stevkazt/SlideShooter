extends Area2D


export (PackedScene) var bullet
var speed = 300
var velocity = Vector2()
var dir = Vector2()
var type = 0
var target = null
var set_pos = Vector2()
var screensize
var can_get_damage = true
var ninja_sprite = 0# Green: 0, Orange:1, Red: 2


func _ready():
	screensize = get_viewport_rect().size
	target = get_tree().get_nodes_in_group("player")[0]
	randomize()
	if type == 0:
		_ninja()
	if type == 1:
		_shooter()
	if type == 2:
		_ufo()
	
#----------------------------------------------------------------------------------------------------
func _process(delta):
	if type == 0:
		_ninja_process(delta)
	if type == 1:
		_shooter_process(delta)
	if type == 2:
		_ufo_process(delta)
	
#----------------------------------------------------------------------------------------------------
func _ninja():
	var side = randi()%4+1
	match ninja_sprite:
		0:
			$Sprite.animation = "NinjaGreen"
		1:
			$Sprite.animation = "NinjaOrange"
		2:
			$Sprite.animation = "NinjaRed"
	match side:
		1:
			position = Vector2(rand_range(0,screensize.x),0)
		2:
			position = Vector2(screensize.x,rand_range(0,screensize.y))
		3:
			position = Vector2(rand_range(0,screensize.x),screensize.y)
		4:
			position = Vector2(0,rand_range(0,screensize.y))
	
#----------------------------------------------------------------------------------------------------
func _ninja_process(delta):
	var playerpos = target.position
	if $sfx_explode.playing:
		dir = Vector2()
	else:
		dir = (playerpos-position).normalized()
	velocity = dir*speed
	rotation = dir.angle()
	position += velocity * delta
	
#----------------------------------------------------------------------------------------------------
func _shooter():
	$Sprite.animation = "shooter_orange"
	var sides = 3
	if Singleton.score > 400:
		sides = 4
	var side = randi()%sides+1
	match side:
		1:
			position = Vector2(rand_range(0,screensize.x),0)
			set_pos = Vector2(rand_range(100,screensize.x-100),200)
		2:
			position = Vector2(screensize.x,rand_range(0,screensize.y))
			set_pos = Vector2(screensize.x-100,rand_range(100,screensize.y-100))
		3:
			position = Vector2(0,rand_range(0,screensize.y))
			set_pos = Vector2(100,rand_range(100,screensize.y-100))
		4:
			position = Vector2(rand_range(0,screensize.x),screensize.y)
			set_pos = Vector2(rand_range(100,screensize.x-100),screensize.y-200)
	
#----------------------------------------------------------------------------------------------------
func _shooter_process(delta):
	position = position.linear_interpolate(set_pos, delta*0.5)
	var target_dir = (target.global_position - global_position).normalized()
	var current_dir = Vector2(1, 0).rotated(self.global_rotation)
	self.global_rotation = current_dir.linear_interpolate(target_dir, delta*2).angle()
	
#----------------------------------------------------------------------------------------------------
func _ufo():
	$Sprite.animation = "ufo"
	var side = randi()%4+1
	match side:
		1:
			position = Vector2(rand_range(0,screensize.x),0)
			set_pos = Vector2(rand_range(100,screensize.x-100),200)
		2:
			position = Vector2(screensize.x,rand_range(0,screensize.y))
			set_pos = Vector2(screensize.x-100,rand_range(100,screensize.y-100))
		3:
			position = Vector2(0,rand_range(0,screensize.y))
			set_pos = Vector2(100,rand_range(100,screensize.y-100))
		4:
			position = Vector2(rand_range(0,screensize.x),screensize.y)
			set_pos = Vector2(rand_range(100,screensize.x-100),screensize.y-200)
	
#----------------------------------------------------------------------------------------------------
func _ufo_process(delta):
	position = position.linear_interpolate(set_pos, delta*0.5)
	
#----------------------------------------------------------------------------------------------------
func _on_Enemy_area_entered(area):
	if area.get_collision_layer_bit(0) or area.get_collision_layer_bit(5):
		match type:
			0:
				if can_get_damage:
					Singleton.score += 4
			1:
				if can_get_damage:
					Singleton.score += 6
			3:
				Singleton.score += 15
		speed = 0
		$ShootTimer.stop()
		$CollisionShape2D.queue_free()
		$sfx_explode.play()
		$Sprite.play("explode")
		$Sprite.scale = Vector2(.7,.7)
	
#----------------------------------------------------------------------------------------------------
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
	
#----------------------------------------------------------------------------------------------------
func _on_ShootTimer_timeout():
	if type ==1:
		var b = bullet.instance()
		get_parent().add_child(b)
		b.start($Position2D.global_position,Vector2(1, 0).rotated($Position2D.global_rotation),1,2)
	if type == 2:
		var b = bullet.instance()
		for i in range(12):
			get_parent().add_child(b)
			b.start(global_position,Vector2(1,0).rotated(deg2rad(30*i)),1,2)
			b = bullet.instance()
	
#----------------------------------------------------------------------------------------------------
func _on_sfx_explode_finished():
	queue_free()
	
#----------------------------------------------------------------------------------------------------
