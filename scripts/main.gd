extends Node2D

var file
var map = []
var map_size_x = 0
var map_size_y = 0
var tile_size = 32
var mouse_x = 0
var mouse_y = 0

var p_dirt = load("res://scenes/tiles/dirt.xml")
var p_water = load("res://scenes/tiles/water.xml")

var p_unit_1 = load("res://scenes/units/unit_1.xml")

func _ready():
	draw_tiles()
	#OS.set_window_maximized(true)
	
	#add initial units
	var unit = p_unit_1.instance()
	unit.cell = [0,0]
	add_child(unit)
	
	#set camera sizes
	get_node("camera").set_limit(MARGIN_RIGHT, map_size_x*tile_size)
	get_node("camera").set_limit(MARGIN_BOTTOM, map_size_y*tile_size)
	
	set_process_input(true)
	
func draw_tiles():
	var tile
	file = File.new()
	file.open("res://maps/map_2.csv",1)
	map_size_x = file.get_csv_line().size()
	
	#FIX this one pls
	file.open("res://maps/map_2.csv",1)
	map_size_y = file.get_as_text().split(",").size()/map_size_x+1
	
	for i in range(map_size_y):
		file.seek(map_size_x*i*2)
		map.append(file.get_csv_line())
	
	for y in range(map_size_y):
		for x in range(map_size_x):
			if map[y][x] == "0":
				tile = p_dirt.instance()
			else:
				tile = p_water.instance()
			
			tile.set_pos(Vector2(x*tile_size+16,y*tile_size+16))
			add_child(tile)
			
func _input(event):
	if event.is_pressed():
		mouse_x = floor(event.pos[0]/tile_size)
		mouse_y = floor(event.pos[1]/tile_size)
		print("mouse click cell: ",mouse_x,",",mouse_y)
		for unit in get_tree().get_nodes_in_group("units"):
			print("moveme")
	else:
		if event.pos.x > OS.get_window_size().x-tile_size/2 && !event.is_echo():
			get_node("camera").set_offset(Vector2(get_node("camera").get_offset()[0]+tile_size,get_node("camera").get_offset()[1]))
		elif event.pos.x < tile_size/2 && !event.is_echo():
			get_node("camera").set_offset(Vector2(get_node("camera").get_offset()[0]-tile_size,get_node("camera").get_offset()[1]))
		elif event.pos.y > OS.get_window_size().y-tile_size/2 && !event.is_echo():
			get_node("camera").set_offset(Vector2(get_node("camera").get_offset()[0],get_node("camera").get_offset()[1]+tile_size))
		elif event.pos.y < tile_size/2 && !event.is_echo():
			get_node("camera").set_offset(Vector2(get_node("camera").get_offset()[0],get_node("camera").get_offset()[1]-tile_size))