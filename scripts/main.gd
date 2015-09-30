extends Node2D

var file
var map = []
var map_size_x = 0
var map_size_y = 0
var tile_size = 32
var mouse_x = 0
var mouse_y = 0

var gui_elm_pos_x = 0
var gui_elm_pos_y = 0
var gui_click = false

var p_dirt = preload("res://scenes/tiles/dirt.xml")
var p_water = preload("res://scenes/tiles/water.xml")
var p_unit_1 = preload("res://scenes/units/unit_1.xml")
var pathFinder = preload("res://scripts/pathFinder.gd").new()

var command = ""

func _ready():
	draw_tiles()
	#OS.set_window_maximized(true)
	
	gui_show(false)
	
	#add initial units
	add_unit(10,3)
	add_unit(7,4)
	add_unit(7,8)
	
	#set camera sizes
	get_node("camera").set_limit(MARGIN_RIGHT, map_size_x*tile_size)
	get_node("camera").set_limit(MARGIN_BOTTOM, map_size_y*tile_size)
	
	set_process_input(true)
	get_tree().connect("screen_resized", self, "window_resized")
	get_node("gui").set_offset(Vector2(OS.get_window_size().x-214,20))
	
func gui_show(arg):
	if arg:
		for child in get_node("gui").get_children():
			child.show()
	else:
		for child in get_node("gui").get_children():
			child.hide()
	
func window_resized():
	get_node("gui").set_offset(Vector2(OS.get_window_size().x-214,20))

func add_unit(x,y):
	var unit = p_unit_1.instance()
	unit.cell = [x,y]
	add_child(unit)
	
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

func px_to_cell(mouse_pos):
	mouse_x = floor((get_node("camera").get_offset()[0]+mouse_pos[0])/tile_size)
	mouse_y = floor((get_node("camera").get_offset()[1]+mouse_pos[1])/tile_size)
	print("mouse click cell: ",mouse_x,",",mouse_y)

func _input(event):
	if event.type == InputEvent.MOUSE_BUTTON && event.button_index == 2:
		px_to_cell(event.pos)
		for unit in get_tree().get_nodes_in_group("units"):
			if unit.selected:
				var path = pathFinder.findPathInMap(map, unit.cell, [mouse_x, mouse_y])
				if path != null:
					unit.walk = path
					
	elif event.type == InputEvent.MOUSE_BUTTON && event.button_index == 1:
		if command == "move":
			px_to_cell(event.pos)
			for unit in get_tree().get_nodes_in_group("units"):
				if unit.selected:
					var path = pathFinder.findPathInMap(map, unit.cell, [mouse_x, mouse_y])
					if path != null:
						unit.walk = path
			command = ""
			
		else:
			#check click on GUI, if not, hide GUI
			if !Input.is_action_pressed("btn_l_ctrl"):
				gui_click = false
				for element in get_node("gui").get_children():
					gui_elm_pos_x = get_node("gui").get_offset().x+element.get_pos().x
					gui_elm_pos_y = get_node("gui").get_offset().y+element.get_pos().y
					if int(event.pos.x) in range(gui_elm_pos_x,gui_elm_pos_x+46)  && int(event.pos.y) in range(gui_elm_pos_y,gui_elm_pos_y+46):
						gui_click = true
				
				if !gui_click:
					gui_show(false)
					for unit in get_tree().get_nodes_in_group("units"):
						unit.selected = false
				

	elif event.type == InputEvent.MOUSE_MOTION:
		#camera nav
		if event.pos.x > OS.get_window_size().x-tile_size/2 && !event.is_echo() && get_node("camera").get_offset()[0] < (map_size_x*32)-OS.get_window_size().x:
			get_node("camera").set_offset(Vector2(get_node("camera").get_offset()[0]+tile_size,get_node("camera").get_offset()[1]))
		elif event.pos.x < tile_size/2 && !event.is_echo() && get_node("camera").get_offset()[0] > 0:
			get_node("camera").set_offset(Vector2(get_node("camera").get_offset()[0]-tile_size,get_node("camera").get_offset()[1]))
		elif event.pos.y > OS.get_window_size().y-tile_size/2 && !event.is_echo() && get_node("camera").get_offset()[1] < (map_size_y*32)-OS.get_window_size().y:
			get_node("camera").set_offset(Vector2(get_node("camera").get_offset()[0],get_node("camera").get_offset()[1]+tile_size))
		elif event.pos.y < tile_size/2 && !event.is_echo() && get_node("camera").get_offset()[1] > 0:
			get_node("camera").set_offset(Vector2(get_node("camera").get_offset()[0],get_node("camera").get_offset()[1]-tile_size))



func _on_btn_move_pressed():
	command = "move"

func _on_btn_deselect_pressed():
	command = ""
	for unit in get_tree().get_nodes_in_group("units"):
		unit.selected = false
	gui_show(false)
