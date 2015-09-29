extends KinematicBody2D

var walk = []
var moveAmount = 32
var step = 0
var cell = [0,0]
var selected = false

func _ready():
	add_to_group("units")
	set_pos(Vector2(cell[0]*32+16,cell[1]*32+16))
	set_fixed_process(true)
	
func _fixed_process(delta):
	if walk.size() > 0:
		if moveAmount > 0:
			move(Vector2(int(walk[step][0])*2,int(walk[step][1])*2))
			moveAmount -= 2
		else:
			print("step: ",step)
			moveAmount = 32
			step += 1
			if step == walk.size():
				walk = []
				cell = [floor(get_pos()[0]/32),floor(get_pos()[1]/32)]
				step = 0
				print("unit cell: ", cell)


func _on_clickable_pressed():
	if selected:
		selected = false
		get_node("selection").hide()
	else:
		selected = true
		get_node("selection").show()
