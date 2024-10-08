extends Area2D

var target = null
var dis : Array
var enemytypes : Array

var drag 
var dragging
var screensize
var can_get_damage = true
var taps = 0
var shields_number = 0
var shield = false
var lost_shield_played = false

@export var Bullet: PackedScene

func _ready():
	#can_get_damage = false
	screensize = get_viewport_rect().size

func _process(delta):
	if shield:
		_powerupShieldprocess()
	var enemies_in_area = $Area2D.get_overlapping_areas()
	if drag and dragging:
		position += drag
		position.x = clamp(position.x,0,screensize.x)
		position.y = clamp(position.y,0,screensize.y)
	who_to(enemies_in_area)
	if target:
		var target_dir = (target.global_position - global_position).normalized()
		var current_dir = Vector2(1, 0).rotated(self.global_rotation)
		self.global_rotation = current_dir.lerp(target_dir, delta*10).angle()

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if Singleton.powers.available:
				taps += 1
				$TapTimer.start()
				if taps == 2:
					match Singleton.powers.type:
						1:
							_powerupStair()
						2:
							if !shield:
								_powerupShield()
					Singleton.powers.available = false
					taps = 0
			dragging = true
		elif !event.pressed:
			dragging = false
	if event is InputEventScreenDrag:
		drag = event.relative

func who_to(enemies_in_area):
	enemytypes = Array()
	if enemies_in_area.size() > 0:
		dis = Array()
		for i in range(0, enemies_in_area.size()):
			dis.append(position.distance_to(enemies_in_area[i].position))
			var closest_enemy_index = dis.rfind(dis.min())
			target = enemies_in_area[closest_enemy_index]
	else:
		target = null

func _on_Timer_timeout():
	var dir = Vector2(1, 0).rotated($Position2D.global_rotation)
	var b = Bullet.instantiate()
	get_parent().add_child(b)
	b.start($Position2D.global_position, dir,1,1)

func _powerupStair():
		var b = Bullet.instantiate()
		$sfx_stair.play()
		get_parent().add_child(b)
		b.start(self.global_position, Vector2(1,0),1,1)
		b = Bullet.instantiate()
		get_parent().add_child(b)
		b.start(self.global_position, Vector2(-1,0),1,1)
		b = Bullet.instantiate()
		get_parent().add_child(b)
		b.start(self.global_position, Vector2(0,1),1,1)
		b = Bullet.instantiate()
		get_parent().add_child(b)
		b.start(self.global_position, Vector2(0,-1),1,1)
		b = Bullet.instantiate()
		get_parent().add_child(b)
		b.start(self.global_position, Vector2(1,1).normalized(),1,1)
		b = Bullet.instantiate()
		get_parent().add_child(b)
		b.start(self.global_position, Vector2(-1,1).normalized(),1,1)
		b = Bullet.instantiate()
		get_parent().add_child(b)
		b.start(self.global_position, Vector2(-1,-1).normalized(),1,1)
		b = Bullet.instantiate()
		get_parent().add_child(b)
		b.start(self.global_position, Vector2(1,-1).normalized(),1,1)
		b = Bullet.instantiate()
		get_parent().add_child(b)
		b.start(self.global_position, Vector2(1,-2).normalized(),1,1)
		b = Bullet.instantiate()
		get_parent().add_child(b)
		b.start(self.global_position, Vector2(2,-1).normalized(),1,1)
		b = Bullet.instantiate()
		get_parent().add_child(b)
		b.start(self.global_position, Vector2(2,1).normalized(),1,1)
		b = Bullet.instantiate()
		get_parent().add_child(b)
		b.start(self.global_position, Vector2(1,2).normalized(),1,1)
		b = Bullet.instantiate()
		get_parent().add_child(b)
		b.start(self.global_position, Vector2(-1,2).normalized(),1,1)
		b = Bullet.instantiate()
		get_parent().add_child(b)
		b.start(self.global_position, Vector2(-2,1).normalized(),1,1)
		b = Bullet.instantiate()
		get_parent().add_child(b)
		b.start(self.global_position, Vector2(-2,-1).normalized(),1,1)
		b = Bullet.instantiate()
		get_parent().add_child(b)
		b.start(self.global_position, Vector2(-1,-2).normalized(),1,1)

func _powerupShield():
	if !shield: 
		$sfx_shielup.play()
		can_get_damage = false
		shields_number = 3
		shield = true

func _powerupShieldprocess():
	if shields_number == 3:
		$Sprite.animation = "PowerShield"
		$Sprite.stop()
		$Sprite.set_frame(0)
	if shields_number == 2:
		if !$sfx_lost_shield.playing  and !lost_shield_played:
			$sfx_lost_shield.play()
		$Sprite.animation = "PowerShield"
		$Sprite.stop()
		$Sprite.set_frame(1)
	if shields_number == 1 :
		if !$sfx_lost_shield.playing and !lost_shield_played:
			$sfx_lost_shield.play()
		$Sprite.animation = "PowerShield"
		$Sprite.stop()
		$Sprite.set_frame(2)
	if shields_number == 0:
		if !$sfx_lost_shield.playing  and !lost_shield_played:
			$sfx_lost_shield.play()
		$Sprite.animation = "default"
		shield = false
		can_get_damage = true

func _on_PlayerShip_area_entered(_area):
	if shield:
		shields_number=0
		lost_shield_played = false

	elif can_get_damage: 
		can_get_damage = false
		$sfx_shielup.play()
		$Sprite.play("shield")
		$LifeTimer.start()
		Singleton.lifes -= 1
		if Singleton.lifes == 0:
			Singleton.powers.available = false
			$Sprite.play("explode")
			$sfx_lose.play()

func _on_LifeTimer_timeout():
	$Sprite.play("default")
	can_get_damage = true
	$sfx_shielup.stop()
	$sfx_shielddown.play()

func _on_TapTimer_timeout():
	taps = 0

func _on_sfx_lost_shield_finished():
	lost_shield_played = true
