extends KinematicBody2D

export var health_current = 100
export var health_max = 100

var walk = []
var moveAmount = Vector2(0,0)
var step = 0
var cell = [0,0]
var cells_reserved = []
var target_cell = cell
var selected = false
var world
var attempt = 0
var id = -1

func _ready():
	id = get_instance_ID()
	add_to_group("units")
	set_pos(Vector2(cell[0]*32+16,cell[1]*32+16))
	target_cell = cell
	reserve_cell(cell)
	set_fixed_process(true)
	
func _fixed_process(delta):
	if selected:
		if !get_node("selection").is_visible():
				get_node("selection").show()
				get_tree().get_root().get_children()[0].gui_show(true)
	else:
		if get_node("selection").is_visible():
				get_node("selection").hide()
				get_tree().get_root().get_children()[0].gui_show(false)

	if walk.size() > 0:
		if moveAmount.length_squared() >= 2:
			var to_move = (moveAmount.normalized() * 2).snapped(Vector2(2,2))
			move(to_move)
			moveAmount -= to_move
		else:
			cell = [floor(get_pos()[0]/32),floor(get_pos()[1]/32)]
			
			if step == walk.size():
				unreserve_all_cells()
				find_path()
				if not reserve_cell(cell):
					walk = []
			else:
				unreserve_all_cells()
				if not reserve_cell([cell[0] + walk[step][0], cell[1] + walk[step][1]]):
					walk = []
				else:
					moveAmount = Vector2(walk[step][0], walk[step][1])*32
					step += 1
				reserve_cell(cell)
	elif(str(cell) != str(target_cell)) && attempt < 32:
		attempt += 1
		unreserve_all_cells()
		reserve_cell(cell)
		if find_path():
			attempt = 0

func reserve_cell(cell):
	#return true
	var result = world.pathFinder.reserve_cell(cell, id)
	if result == 1:
		cells_reserved.push_back(cell)
	return result != 0

func unreserve_cell():
	if cells_reserved.size() > 0 && world.pathFinder.unreserve_cell(cells_reserved[0], id):
		cells_reserved.remove(0)

func unreserve_all_cells():
	for cell in cells_reserved:
		world.pathFinder.unreserve_cell(cell, id)
	cells_reserved.clear()
	
func find_path():
	if not world.pathFinder.mapElemIsWalkable(target_cell):
		return
	var path = world.pathFinder.findPathInMap(cell, target_cell)
	step = 0
	if path != null:
		walk = path
		return true
	else:
		walk = []
		return false
	
func set_target(tc):
	target_cell = tc
	attempt = 0


func _on_clickable_pressed():
	if !Input.is_action_pressed("btn_l_ctrl"):
		for unit in get_tree().get_nodes_in_group("units"):
			unit.selected = false
	if selected:
		selected = false
	else:
		selected = true