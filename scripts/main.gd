extends Node2D

var file
var map = []
var map_size_x = 0
var map_size_y = 24

var mouse_x = 0
var mouse_y = 0

var p_dirt = load("res://scenes/tiles/dirt.xml")
var p_water = load("res://scenes/tiles/water.xml")

func _ready():
	draw_tiles()
	randomize()
	set_process_input(true)
	get_node("units/unit_1").walk = [[1,0],[1,0],[0,1],[1,1],[1,1],[1,1],[1,0],[1,0],[-1,-1]]
	
func draw_tiles():
	var tile
	file = File.new()
	file.open("res://maps/map_1.csv",1)
	map_size_x = file.get_csv_line().size()
	for i in range(24):
		file.seek(map_size_x*i*2)
		map.append(file.get_csv_line())
	
	for y in range(24):
		for x in range(map_size_x):
			if map[y][x] == "0":
				tile = p_dirt.instance()
			else:
				tile = p_water.instance()
			
			tile.set_pos(Vector2(x*32+16,y*32+16))
			add_child(tile)
			
func _input(event):
	if event.is_pressed():
		mouse_x = floor(event.pos[0]/32)
		mouse_y = floor(event.pos[1]/32)
		print("mouse click cell: ",mouse_x,",",mouse_y)
		walkToCell(mouse_x,mouse_y)
		
func walkToCell(x,y):
	#do the pathfinder
	#return the array
	
	print("moving to next 1 random cell")
	var walk = [[(randi()%3)-1,(randi()%3)-1]]
	
	get_node("units/unit_1").walk = walk