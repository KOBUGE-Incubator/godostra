const PriorityQueue = preload("priorityQueue.gd")

# Returns true if unit can walk on map coordinate at position pos
func mapElemIsWalkable(map, pos):
	var x = pos[0]
	var y = pos[1]
	return map[y][x] == "0"

func mapCoordIsInBounds(map, pos):
	var x = pos[0]
	var y = pos[1]
	return  y >= 0 && y < map.size() && x >= 0 && x < map[0].size()

# Returns the ways an unit can walk (up, down etc)
func getNeighs(pos):
	var x = pos[0]
	var y = pos[1]
	return [
		[x-1,y],
		[x-1,y-1],
		[x-1,y+1],
		[x+1,y],
		[x+1,y-1],
		[x+1,y+1],
		[x,y-1],
		[x,y+1]
		#[x,y]
	]

const D = 1
const D2 = sqrt(2)

func distance(a, b):
	var dx = abs(a[0] - b[0])
	var dy = abs(a[1] - b[1])
	return D * (dx + dy) + (D2 - 2 * D) * min(dx, dy)

func findPathInMap(map, start, dest):
	if not mapCoordIsInBounds(map, dest) or not mapElemIsWalkable(map, dest) or str(start) == str(dest):
		return
	
	# A* algorithm
	var horizon = PriorityQueue.new()
	var origins = {}
	var cost_so_far = {}
	var found_path = false

	# Set everything up
	origins[start] = null
	cost_so_far[start] = 0
	horizon.insert(start, 0)

	while horizon.size() > 0:
		var cur = horizon.pop()

		if cur[0] == dest[0] and cur[1] == dest[1]:
			# Yaay found the (probably shortest) path!!!
			found_path = true
			break

		var ccsf = cost_so_far[cur]
		for neigh in getNeighs(cur):
			if mapCoordIsInBounds(map, neigh) && mapElemIsWalkable(map, neigh):
				var candidate_neigh_cost = ccsf + distance(cur, neigh)
				if !cost_so_far.has(neigh) or candidate_neigh_cost < cost_so_far[neigh]:
					cost_so_far[neigh] = candidate_neigh_cost
					horizon.insert(neigh, - candidate_neigh_cost - distance(neigh, dest))
					origins[str(neigh)] = cur

	if not found_path:
		print("Could not find a way !!")
		return

	print(found_path, origins.has(dest))

	# Now reverse the path, and convert it into directions
	var walk_path = []
	var cur = dest
	var origin = origins[str(cur)]
	while not (origin == null):
		walk_path.insert(0, [cur[0] - origin[0], cur[1] - origin[1]])
		cur = origin
		if origins.has(str(cur)):
			origin = origins[str(cur)]
		else:
			origin = null

	# Finally! The resulting path can be added to the unit.
	return walk_path
