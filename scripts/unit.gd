extends KinematicBody2D

var walk = []
var csize = 32
var step = 0
var cell = [0,0]

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	if walk.size() > 0:
		if csize > 0:
			move(Vector2(int(walk[step][0])*2,int(walk[step][1])*2))
			csize -= 2
		else:
			print("step: ",step)
			csize = 32
			step += 1
			if step == walk.size():
				walk = []
				cell = [get_pos()[0]/32,get_pos()[1]/32]
				step = 0
				print("unit cell: ",cell)