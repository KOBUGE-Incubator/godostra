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
	return [[x-1,y],[x+1,y],[x,y-1],[x,y+1]]

func distance(a, b):
	return abs(a[0] - b[0]) + abs(a[1] - b[1])

func findPathInMap(map, start, dest):
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
			if mapCoordIsInBounds(map, neigh) && mapElemIsWalkable(map, neigh):
				var candidate_neigh_cost = ccsf + 1
				if !cost_so_far.has(neigh) or candidate_neigh_cost < cost_so_far[neigh]:
					cost_so_far[neigh] = candidate_neigh_cost
					horizon.push_back(neigh) #TODO horizon.put(neigh, distance(a, b))
					origins[str(neigh)] = cur

	if not found_path:
		print("could not find a way !!")
		return

	print(found_path, origins.has(dest))

	# now reverse the path, and convert it into directions
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
