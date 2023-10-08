extends Node

var packed_point = preload("res://src/props/point.tscn")

var packed_carnivorous = preload("res://src/enemies/Carnivorous.tscn")
var packed_bacteriophages = preload("res://src/enemies/Bacteriophage.tscn")
var packed_wander = preload("res://src/enemies/Wander.tscn")

var antibiotics_remain: Array = ["Amoxicilina", "Bacitracina", "Cefadroxil", "Eritromicina",\
								"Fosfomicina", "Nitroxolina", "Penicilina", "Tetraciclina"]


func spawn_carnivorous():
	
	if get_tree().get_nodes_in_group("P_bacteria").empty():
		return
	
	for i in 4 + randi()%3:
		var carn = packed_carnivorous.instance()
		carn.antibiotic = antibiotics_remain[randi()%antibiotics_remain.size()]
		
		var pos = random_pos()
		
		
		while pos.distance_to(get_tree().get_nodes_in_group("P_bacteria")[0].global_position) < 512:
			pos = random_pos()
		
		carn.global_position = pos
		call_deferred("add_child", carn)


func spawn_bacteriophages():
	
	if get_tree().get_nodes_in_group("P_bacteria").empty():
		return
	
	for i in 20 + randi()% 10:
		var virus = packed_bacteriophages.instance()
		var pos = random_pos()
		
		while pos.distance_to(get_tree().get_nodes_in_group("P_bacteria")[0].global_position) < 512:
			pos = random_pos()
		
		virus.global_position = pos
		call_deferred("add_child", virus)


func spawn_wander():
	
	if get_tree().get_nodes_in_group("P_bacteria").empty():
		return
	
	for i in 10 + randi()% 10:
		var wander = packed_wander.instance()
		var pos = random_pos()
		
		while pos.distance_to(get_tree().get_nodes_in_group("P_bacteria")[0].global_position) < 512:
			pos = random_pos()
		
		wander.global_position = pos
		call_deferred("add_child", wander)


func random_pos() -> Vector2:
	var angle = rand_range(0, 2*PI)
	var radius = randi()%3850
	return Vector2(sin(angle), cos(angle)) * radius

func _carnivorous_dead(antibiotic: String):
	if antibiotics_remain.has(antibiotic):
		antibiotics_remain.erase(antibiotic)
		get_node("../Player")._call_immunity_text(antibiotic)
	
	#print("antibiótico adquirido: ", antibiotic)
	if antibiotics_remain.empty():
		get_tree().get_nodes_in_group("Player")[0]._pause_move()
		yield(get_tree().create_timer(6), "timeout")
		Trans._go_to_scene("res://src/scenes/Victory.tscn")
