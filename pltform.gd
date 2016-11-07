extends CollisionPolygon2D

# member variables here, example:
# var a=2
# var b="textvar"
onready var graph = get_tree().get_current_scene().find_node("graph1")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	graph.set_polygon(get_polygon())
	pass


