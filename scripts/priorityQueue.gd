class HeapItem:
	var priority = -1
	var tiebreaker = 0
	var data = null

var heap_array = []
var heap_size = 0
var current_tiebreaker = 0

func _init():
	var init_item = HeapItem.new()
	init_item.priority = 65535
	heap_array.push_back(init_item)
	

func size():
	return heap_size

func insert(data, priority):
	var item = HeapItem.new()
	item.data = data
	item.priority = priority
	# Tiebreaker is needed when two or more items have the same priority
	current_tiebreaker += 1
	item.tiebreaker = current_tiebreaker
	
	heap_size += 1
	heap_array.push_back(item)
	
	_shift_up(heap_size)


func pop():

	if heap_size <= 0:
		return
	var item = heap_array[1]
	
	heap_array[1] = heap_array[heap_size]
	heap_array.remove(heap_size)
	heap_size -= 1
	
	if heap_size > 0:
		_shift_down(1)
		
	return item.data

func _shift_up(position):
	var item = heap_array[position]
	var postion_found = int(position)
	# It is important for postion_found to be int, otherwise we will start searching .5 positions
	# Could have used floor(.../2), but it is too troublesome
	
	while _is_better(item, heap_array[postion_found / 2]) && postion_found > 0:
		heap_array[postion_found] = heap_array[postion_found / 2]
		postion_found = int(postion_found / 2)
	
	heap_array[postion_found] = item

func _shift_down(position):
	var item = heap_array[position]
	var postion_found = int(position)
	var half_size = int(heap_size / 2)

	while postion_found <= half_size:
		var suggestion = 2 * postion_found
		
		if suggestion + 1 <= heap_size and _is_better(heap_array[suggestion + 1], heap_array[suggestion]):
			suggestion += 1
			
		if _is_better(item, heap_array[suggestion]):
			break
		
		heap_array[postion_found] = heap_array[suggestion]
		postion_found = suggestion
	
	heap_array[postion_found] = item

func _is_better(item, other_item):
	return item.priority > other_item.priority