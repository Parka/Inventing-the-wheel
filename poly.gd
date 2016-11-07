extends CollisionPolygon2D

onready var graph = get_tree().get_current_scene().find_node("graph")

func _ready():
	graph.set_polygon(get_polygon())
	
func add_point_to_poly(point):
	var p = get_polygon()
	p.append(p[0])
	var index
	var nearest
	for i in range(p.size()-1):
		var c = get_point_to_segment_distance(p[i],p[i+1],point-get_global_pos())
		if nearest == null || c < nearest: 
			nearest = c
			index = i
	p.insert(index+1, point - get_global_pos())
	p.remove(p.size()-1)
	set_polygon(p)
	return p[index+1]

func get_point_to_segment_distance(p,q,point):
	return Geometry.get_closest_points_between_segments_2d(p,q,point,point)[0].distance_to(point)

#get own area
var area setget ,_get_area

func _get_area():
	return get_area(get_polygon()) 

static func get_area(poly):
	poly.push_back(poly[0]) #close the poly
	var area = 0
	var p1
	var p2
	
	for id in range(0,poly.size()-1):
		p1 = poly[id]
		p2 = poly[id+1]
		area += (p1.x * p2.y) - (p2.x * p1.y)
	area = abs(area/2)
	return area
	
func recenter():
	var poly = get_polygon()
	poly.push_back(poly[0])
	
	var a = self.area
	var cx = 0
	var cy = 0
	
	for x in range(poly.size()-1):
		var p1 = poly[x]
		var p2 = poly[x+1]
		cx += (p1.x+p2.x)*(p1.x*p2.y-p2.x*p1.y)
		cy += (p1.y+p2.y)*(p1.x*p2.y-p2.x*p1.y)
		
	cx = cx / (6*a)
	cy = cy / (6*a)
	
	for id in range(poly.size()):
		var p = poly[id]
		p.x -= cx
		p.y -= cy
		poly[id] = p
	
	poly.resize(poly.size()-1)
	
	set_polygon(poly)
	graph.set_polygon(get_polygon())
	
	get_parent().get_shape(0).set_point_cloud(poly)
	
	get_parent().set_pos(get_parent().get_pos() + Vector2(cx,cy))