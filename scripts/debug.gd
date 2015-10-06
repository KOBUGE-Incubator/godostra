
extends Node2D

var state = 0
var states = 2

func _draw():
	if state == 0:
		return
	if state == 1:
		var tile_size = get_parent().tile_size
		var path_finder = get_parent().pathFinder
		for x in range(get_parent().map_size_x):
			for y in range(get_parent().map_size_y):
				if not path_finder.mapElemIsWalkable([x, y]):
					draw_rect(Rect2(x * tile_size, y * tile_size, tile_size, tile_size), Color(1, 0, 0, 0.5))

func _ready():
	update()
	set_process(true)

func _process(delta):
	update()

func next_state():
	state = (state + 1) % states


