extends Sprite
var screensize

func _ready():
	screensize = get_viewport_rect().size
	position = Vector2(0,500)

func _process(delta):
	rotation += delta*.2
	position = Vector2(-300,960)
