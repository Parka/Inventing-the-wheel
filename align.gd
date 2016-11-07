
extends CanvasLayer

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	var width = OS.get_window_size().width
	var height = OS.get_window_size().height
	for x in get_children():
		var pos = x.get_pos()
		var rect = x.get_item_rect().size
		if x.get_name() == "ludogramming":
			pos.y = height - 1.5 * rect.height * x.get_scale().y
		x.set_pos(Vector2(width - 1.2 * rect.width * x.get_scale().x,pos.y))