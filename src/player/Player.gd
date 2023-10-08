extends Node2D

const bacteria = preload("res://src/player/Bacteria.tscn")
const virus = preload("res://src/enemies/Bacteriophage_representation.tscn")

signal main_changed(main)

var rng = RandomNumberGenerator.new()

var acl: = 2
var speed: = 0
var spd_set_point: = 0
var max_speed: = 100
var run_speed: = 150

var running: = false

var axis: = Vector2.ZERO
var move_axis: = Vector2.ZERO
var move: = Vector2.ZERO

var max_stamin: float = 100
var stamin: float = max_stamin

var cam: Camera2D

var points: int = 20

var carnivorous: bool = false

var max_life: int = 100

var immunity: Array = []

var prices: Array = [100, 10, 10, 15, 20] #1 - carnivorous, 2 - velocity, 3 - stamin, 4 - life, 5 - reproduce


func _ready():
	rng.randomize()
	cam = $Camera
	get_tree().get_nodes_in_group("P_bacteria")[0]._set_current()
	
	$CanvasLayer/Control/buttons/GridContainer/up1/Label.text = str(prices[0])
	$CanvasLayer/Control/buttons/GridContainer/up2/Label.text = str(prices[1])
	$CanvasLayer/Control/buttons/GridContainer/up3/Label.text = str(prices[2])
	$CanvasLayer/Control/buttons/GridContainer/up4/Label.text = str(prices[3])
	$CanvasLayer/Control/buttons/reproduce/Label.text = str(prices[4])

func _process(delta):
	running = Input.is_action_pressed("run") && axis && (stamin > 30 || running)
	if stamin <= 0:
		running = false
	
	stamin += delta * (14 if !running else -20)
	stamin = clamp(stamin, 0, max_stamin)
	
	speed = max_speed if !running else run_speed
	cam.zoom = cam.zoom.linear_interpolate(Vector2.ONE * (0.6 if !running else 0.7), delta * acl)
	#cam.smoothing_speed = lerp(cam.smoothing_speed, max_speed/90.0 if !running else max_speed/40.0, delta * acl)
	
	ui_process()

func _physics_process(delta):
	
	spd_set_point = speed if axis else 0
	move_axis = move_axis.linear_interpolate(axis * spd_set_point, delta * acl)
	
	for bac in get_tree().get_nodes_in_group("P_bacteria"):
		bac._move(move_axis, delta)

#########################################################################################
#                                 tem debug aki
#########################################################################################
func _unhandled_input(_event):
	axis = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	
	if Input.is_action_just_pressed("call"):
		get_tree().get_nodes_in_group("P_bacteria")[0]._call_all()
	
	if Input.is_action_just_pressed("ui_down"):
		_call_immunity_text("supimpa")
	if Input.is_action_just_pressed("ui_up"):
		$Wave_Controller._call_wave()

func _call_immunity_text(antibiotic: String):
	$CanvasLayer/Control._call_immunity_text(antibiotic)
	if !immunity.has(antibiotic):
		immunity.append(antibiotic)

func ui_process():
	$CanvasLayer/Control/Stamin.value = stamin
	$CanvasLayer/Control/shake/Wave_Alert.text = "Next Wave in: %s\n%s" %[int($Wave_Controller/Timer.time_left), $Wave_Controller.next_antibiotic]
	$CanvasLayer/Control/Stamin/Label.text = str(int(stamin))

func _set_max_stamin(value):
	max_stamin = value
	$CanvasLayer/Control/Stamin.max_value = value


func _kill_bacteria(bac):
	var cur = bac.current
	bac.queue_free()
	
	yield(bac, "tree_exited")
	
	if cur:
		$Change_Timer.start()
		yield($Change_Timer, "timeout")
		check_game_over()
		


func check_game_over():
	if get_tree().get_nodes_in_group("P_bacteria").size() > 0:
		get_tree().get_nodes_in_group("P_bacteria")[0]._set_current()
		emit_signal("main_changed", get_tree().get_nodes_in_group("P_bacteria")[0])
	else:
		_pause_move()
		$CanvasLayer/Control._call_immunity_text("Game Over", "-Is it the end?-")
		yield(get_tree().create_timer(3), "timeout")
		Trans._generic_trans()
		yield(Trans, "mid_trans")
		get_tree().reload_current_scene()


func gather_points(value):
	points += value
	$CanvasLayer/Control/Points.text = str(points)


func buy_item(index: int): #1 - carnivorous, 2 - velocity, 3 - stamin, 4 - life, 5 - reproduce
	match index:
		1:
			if !carnivorous && points >= 100:
				carnivorous = true
				$CanvasLayer/Control/buttons/GridContainer/up1.disabled = true
				gather_points(-prices[0])
		
		2:
			if points >= 10:
				max_speed += 5
				run_speed += 5
				if max_speed >= 450:
					$CanvasLayer/Control/buttons/GridContainer/up2.disabled = true
				gather_points(-prices[1])
		
		3:
			if points >= 10:
				_set_max_stamin(max_stamin + 10)
				gather_points(-prices[2])
		
		4:
			if points >= 15:
				max_life += 10
				gather_points(-prices[3])
		
		5:
			if points >= 20:
				get_tree().get_nodes_in_group("P_bacteria")[0]._reproduce()
				gather_points(-prices[4])


func _pause_move():
	set_physics_process(false)


func _play_point_sound():
	$Camera/Point_Sound.play(0)


func _on_up1_button_up():
	buy_item(1)


func _on_up2_button_up():
	buy_item(2)


func _on_up3_button_up():
	buy_item(3)


func _on_up4_button_up():
	buy_item(4)


func _on_reproduce_button_up():
	buy_item(5)
