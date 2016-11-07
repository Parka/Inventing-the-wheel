
extends Camera2D

# member variables here, example:
# var a=2
# var b="textvar"

onready var ball = get_tree().get_current_scene().find_node("Ball")


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	make_current()

func _process(delta):
	set_pos( ball.get_pos())
