extends Sprite
var screensize
export (PackedScene) var Stuff

func _ready():
	screensize = get_viewport_rect().size
	position = Vector2(-300,960)
	
func _process(delta):
	rotation += delta*.1
	if Singleton.score > 3000 and $StuffTimer.is_stopped(): 
		$StuffTimer.start()


func _on_StuffTimer_timeout():
	var stuff_count = get_tree().get_nodes_in_group("stuff")
	if stuff_count.size()<50:
		var set_x = randi()%1000+280
		var type = randi()%6+0
		var stuff = Stuff.instance()
		get_parent().call_deferred("add_child",stuff)
		stuff._start(position,Vector2(-set_x,0),type)
