extends Area2D

@export var speed:int
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

func start(_position, _direction, _type,_team):
	screensize = get_viewport_rect().size
	type = _type
	team = _team
	if team == 2:
		$sfx_laser_enemy.play()
		$Sprite.animation = "enemy"
		collision_layer = 0b1000000
		collision_mask = 0b1
	if type == 2:
		rocketlaunch = false
		$Sprite.animation = "missile"
		target = get_tree().get_nodes_in_group("player")[0]
		missile_side  = randi()%2+1
		
	$sfx_laser_player.play()
	position = _position
	rotation = _direction.angle()
	velocity = _direction * speed

func _process(delta):
	if type == 2:
		missile_process(delta)
	else:
		position += velocity * delta

func missile_process(delta):
	if position.x > 70 and position.x < 650 and !rocketlaunch: 
		if missile_side == 1:
			position = position.lerp(Vector2(50,screensize.y/2), delta*0.8)
		if missile_side == 2:
			position = position.lerp(Vector2(670,screensize.y/2), delta*0.8)
		var target_dir = (target.global_position - global_position).normalized()
		var current_dir = Vector2(1, 0).rotated(self.global_rotation)
		self.global_rotation = current_dir.lerp(target_dir, delta*10).angle()
		velocity =  (target.global_position - global_position).normalized() *600
		
	else:
		if !$Sprite.is_playing():
			$Sprite.animation = "launch_missile"
			speed = 100
		rocketlaunch = true
		position += velocity* delta

func explode():
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Bullet_area_entered(_area):
	if team == 1:
		velocity = Vector2()
		$CollisionShape2D.queue_free()
		$Sprite.play("explode")
	if team == 2:
		velocity = Vector2()
		$CollisionShape2D.queue_free()
		self.scale = Vector2(1,1)
		$Sprite.play("explode")

func _on_Sprite_animation_finished():
	queue_free()
