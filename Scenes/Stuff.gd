extends Node2D

# 2 mid meteors -> meteor_mid_x [0 1]
# 4 big meteors -> meteor_big_x [2 3 4 5]

var type = 0 # 0 = meteor_mid_0
var clock = true

func _start(_pivot,_stuff_position,_type):
	type = _type
	position = _pivot
	$Meteor.position = _stuff_position
	if -_stuff_position.x < 650:
		clock = false
	match type:
		0:
			$Meteor/Sprite.animation = "meteor_mid_0"
		1:
			$Meteor/Sprite.animation = "meteor_mid_1"
		2:
			$Meteor/Sprite.animation = "meteor_big_0"
			$Meteor/CollisionShape2D.scale = Vector2(2,2)
		3:
			$Meteor/Sprite.animation = "meteor_big_1"
			$Meteor/CollisionShape2D.scale = Vector2(2,2)
		4:
			$Meteor/Sprite.animation = "meteor_big_2"
			$Meteor/CollisionShape2D.scale = Vector2(2,2)
		5:
			$Meteor/Sprite.animation = "meteor_big_3"
			$Meteor/CollisionShape2D.scale = Vector2(2,2)

func _process(delta):
	if clock:
		rotation += delta*.6
	else:
		rotation += -delta*1.2
	$Meteor.rotation += delta
	



func _on_Meteor_area_entered(area):
	if !area.get_collision_layer_bit(1):
		if type <= 2 :
			Singleton.score += 3
		else:
			Singleton.score += 1
		queue_free()


func _on_VisibilityNotifier2D_screen_entered():
	$Meteor/CollisionShape2D.disabled = false


func _on_VisibilityNotifier2D_screen_exited():
	$Meteor/CollisionShape2D.disabled = true
	
