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

# Returns true if unit can walk on map coordinate at position pos
func mapElemIsWalkable(pos):
	var x = pos[0]
	var y = pos[1]
	return map[y][x] == "0"

func mapCoordIsInBounds(pos):
	var x = pos[0]
	var y = pos[1]
	return x >= 0 && x < map_size_x && y >= 0 && y < map_size_y

# Returns the ways an unit can walk (up, down etc)
func getNeighs(pos):
	var x = pos[0]
	var y = pos[1]
	return [[x-1,y],[x+1,y],[x,y-1],[x,y+1]]

func distance(a, b):
	return abs(a[0] - b[0]) + abs(a[1] - b[1])

func walkToCell(x,y):
	var unit = get_node("units/unit_1")
	var start = unit.cell
	var dest = [x, y]

	# A* algorithm
	# currently its only as fast as any common dijkstra
	# but can use priority queue later on...
	var horizon = [] # TODO create pqueue
	var origins = {}
	var cost_so_far = {}
	var found_path = false

	# set everything up
	origins[start] = null
	cost_so_far[start] = 0
	horizon.push_back(start) # TODO horizon.put(start, arbitrary priority)

	while horizon.size() > 0: # TODO pqueue is not empty
		var cur = horizon[0] # TODO pqueue pop
		horizon.remove(0)

		if cur[0] == dest[0] and cur[1] == dest[1]:
			# yaay found the (shortest) path!!!
			found_path = true
			break

		var ccsf = cost_so_far[cur]
		for neigh in getNeighs(cur):
			#print("checking ", neigh)
			if mapCoordIsInBounds(neigh) && mapElemIsWalkable(neigh):
				var candidate_neigh_cost = ccsf + 1
				if !cost_so_far.has(neigh) or candidate_neigh_cost < cost_so_far[neigh]:
					cost_so_far[neigh] = candidate_neigh_cost
					horizon.push_back(neigh) #TODO horizon.put(neigh, distance(a, b))
					origins[neigh] = cur

	if not found_path:
		print("could not find a way !!")
		return

	# now reverse the path, and convert it into directions
	var walk_path = []
	var cur = dest
	var origin = origins[cur]
	while not (origin == null):
		walk_path.insert(0, [cur[0] - origin[0], cur[1] - origin[1]])
		cur = origin
		origin = origins[cur]

	# Finally! The resulting path can be added to the unit.
	get_node("units/unit_1").walk = walk_path