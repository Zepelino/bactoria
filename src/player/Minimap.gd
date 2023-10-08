extends MarginContainer


var player
export var zoom: float = 0.5

onready var grid = $MarginContainer/Grid
onready var player_mark = $MarginContainer/Grid/player
onready var carnivorous_mark = $MarginContainer/Grid/carnivorous
onready var wander_mark = $MarginContainer/Grid/wander
onready var refuge_mark = $MarginContainer/Grid/refuge
onready var pool_mark = $MarginContainer/Grid/pool

onready var icons = {"carnivorous": carnivorous_mark, "wander": wander_mark,\
					"refuge": refuge_mark, "pool": pool_mark}

var grid_scale: Vector2
var markers: Dictionary = {}


func _ready():
	player_mark.position = grid.rect_size/2
	grid_scale = grid.rect_size / (get_viewport().size/zoom)
	
	yield(get_tree().get_root().get_node("Petri"), "ready")
	get_tree().get_nodes_in_group("wave_control")[0].connect("wave", self, "_update_markers")
	_update_markers()


func _process(_delta):
	
	if !is_instance_valid(player):
		if !get_tree().get_nodes_in_group("P_bacteria").empty():
			player = get_tree().get_nodes_in_group("P_bacteria")[0]
		return
	
	player_mark.rotation = player.move.angle() + 1.57
	
	for obj in markers:
		
		if !is_instance_valid(obj):
			markers[obj].queue_free()
			markers.erase(obj)
			continue
		
		var obj_position = (obj.position - player.position) * grid_scale + grid.rect_size / 2
		if grid.get_rect().has_point(obj_position + grid.rect_position):
			markers[obj].scale = Vector2.ONE
		else:
			markers[obj].scale = Vector2(0.5, 0.5)
		obj_position.x = clamp(obj_position.x, 4, grid.rect_size.x-4)
		obj_position.y = clamp(obj_position.y, 4, grid.rect_size.y-4)
		markers[obj].position = obj_position

func _update_markers():
	
	for obj in markers:
		markers[obj].queue_free()
		markers.erase(markers)
	
	#yield(get_tree(), "idle_frame")
	var map_objects = get_tree().get_nodes_in_group("minimap")
	#print("---------------------------------------------------------")
	#print(map_objects)
	#print("---------------------------------------------------------")
	
	for obj in map_objects:
		
		var new_marker = icons[obj.minimap_icon].duplicate()
		grid.add_child(new_marker)
		new_marker.show()
		markers[obj] = new_marker




