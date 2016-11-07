extends Node2D

var TODO = """
TODO:
	Change weight based in area. (?)
	Clearly define states of the game (State machine?)
	Define roll end.
	Clear score in position 0
	Fix half assed cuts
	---
	Make cut interaction challenging and fun.
		ACCELEROMETER!
	---
	Add basic:
		SFX.
	---
	Adapt and test for mobile.
	
"""

# member variables here, example:
# var a=2
# var b="textvar"
var e				# Mouse click event
var r				# Mouse release event
var clicks = Vector2Array()
var hits = Vector2Array()
var near = Vector2Array()
var nodes = Vector2Array()
var initial_x = 0

onready var cam = get_tree().get_current_scene().find_node("Camera")

onready var ball = get_tree().get_current_scene().find_node("Ball")
onready var base = get_tree().get_current_scene().find_node("Base")
onready var ray = get_tree().get_current_scene().find_node("ray")
onready var poly = get_tree().get_current_scene().find_node("poly")
onready var Poly = preload('poly.gd') 
onready var txt = get_tree().get_current_scene().find_node("txt")


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	set_fixed_process(true)
	
	poly.recenter() #Fixes bug with polygon upon restart
	
	for n in poly.get_polygon():
		nodes.push_back(n+poly.get_global_pos())
	
func _input(event):
	if ball.get_mode() == RigidBody2D.MODE_RIGID:
		return
	if event.type != InputEvent.MOUSE_BUTTON:
		return
	
	if event.is_pressed():
		e = event
	else:
		r = event


func _fixed_process(delta):
	
	if ball.get_mode() == RigidBody2D.MODE_RIGID:
		txt.set_text(str(round(ball.get_pos().x)-initial_x))
	else:
		initial_x = round(ball.get_pos().x)

	if e != null: update()	#To update the line
	if r == null:
		return
	var p = get_viewport_transform().affine_inverse() * e.pos
	var q = get_viewport_transform().affine_inverse() * r.pos
	
	e = null
	r = null
	
	var col = get_collision_points(p, q)
	
	if col == null: return
	
	var new_polys = split_poly(col)
	
	hits.append_array(col)
	clicks.push_back(p)
	update()

func split_poly(points):
	
	var new_poly1 = Vector2Array()
	var new_poly2 = Vector2Array()
	
	var p1 = poly.add_point_to_poly(points[0])
	var p2 = poly.add_point_to_poly(points[1])
	
	var id1 = Array(poly.get_polygon()).find(p1)
	var id2 = Array(poly.get_polygon()).find(p2)
	var idx
	var idy
	
	if id1<id2:
		idx = id1
		idy = id2
	else:
		idx = id2
		idy = id1
		
	var polygon = poly.get_polygon()
	var size = polygon.size()
	for x in range(size):
		if range(idx,idy+1).has(x):
			new_poly1.push_back(polygon[x])
		if range(idx+1).has(x) or range(idy,size).has(x):
			new_poly2.push_back(polygon[x])
	
	if Poly.get_area(new_poly1) > Poly.get_area(new_poly2):
		poly.set_polygon(new_poly1)
	else:
		poly.set_polygon(new_poly2)
		
	poly.recenter()
	
	for n in poly.get_polygon():
		nodes.push_back(n+poly.get_global_pos())

func get_collision_points(point1,point2):
	var space_state = get_world_2d().get_direct_space_state()
	var collision_points = Vector2Array()
	var p1 = point1
	var p2 = point2
	var collision1 = space_state.intersect_ray(p1,p2,[],2)
	var collision2 = space_state.intersect_ray(p2,p1,[],2)
	
	if collision1.empty(): return
	if (collision1.position - collision2.position).length() < 5: return

	collision_points.push_back(collision1.position)
	collision_points.push_back(collision2.position)
	
	return collision_points

func _draw():
	
	### Debug drawing ###
	return
	if !OS.is_debug_build(): 
		return
	if e != null:
		var p = get_viewport_transform().affine_inverse() * e.pos
		var q = get_global_mouse_pos()
		draw_line(p,q,Color(1,0,0,.6),3)
	
	
	for c in clicks:
		draw_circle( c,5,Color(0,0,1,.4))
		
	for h in hits:
		pass
		# draw_circle( h,5,Color(0,1,0,.4))
	
	for x in near:
		draw_circle( x,5,Color(1,0,1,.4))
		
	for n in nodes:
		pass
		draw_circle( n,5,Color(0,1,1,.4))

func _on_Button_down_pressed():
	ball.set_mode(RigidBody2D.MODE_RIGID)
	ball.set_sleeping(false) 


func _on_Button_restart_pressed(): 
	get_tree().reload_current_scene()

func _on_ludogramming_pressed():
	print("goHome!")
	OS.shell_open("https://ludogramming.itch.io/")
