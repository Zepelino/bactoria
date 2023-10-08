extends Node2D

const antibiotics: Array = ["Amoxicilina", "Bacitracina", "Cefadroxil", "Eritromicina",\
							"Fosfomicina", "Nitroxolina", "Penicilina", "Tetraciclina"]

var wave_speed: int = 1200
onready var wave_area: Area2D = $Wave_Area
onready var line: Line2D = $Line2D
onready var timer: Timer = $Timer
onready var signal1: AudioStreamPlayer = $Apparition
var active: bool = false

var current_antibiotic: String = ""
var next_antibiotic: String = antibiotics[randi()%antibiotics.size()]

var bodies: Array

var process: bool = false

signal wave

export (NodePath) onready var to_shake = get_node(to_shake)
var shake_force: float
var shake_time: float

func _ready():
	process = false
	
	line.clear_points()
	
	for point in 37:
		var pos: Vector2 = Vector2(cos(deg2rad(point*10)), sin(deg2rad(point*10)))
		line.add_point(pos)
	

func _process(delta):
	
	if timer.time_left < 31 && !signal1.playing:
		match int(timer.time_left):
			30:
				signal1.pitch_scale = 1
				signal1.volume_db = -30
				signal1.play(0)
				shake(0.1)
			20:
				signal1.pitch_scale = 0.9
				signal1.volume_db = -27
				signal1.play(0)
				shake(0.4)
			10:
				signal1.pitch_scale = 0.7
				signal1.volume_db = -24
				signal1.play(0)
				shake(0.7)
			1:
				signal1.pitch_scale = 0.6
				signal1.volume_db = -21
				signal1.play(0)
				shake(1)
	
	
	if shake_time > 0:
		shake_time -= delta
		to_shake.rect_position += Vector2(sin(rad2deg(shake_time*3)), cos(rad2deg(shake_time))) * shake_force
	else:
		to_shake.rect_position = Vector2.ZERO
	
	if process:
		if !active:
			deactive()
			return
		
		wave_area.scale += Vector2.ONE * delta * wave_speed
		line.scale = wave_area.scale
		line.width = 64/wave_area.scale.x
		
		if !get_parent().immunity.has(current_antibiotic):
			for body in bodies:
				if !is_instance_valid(body):
					continue
				if !body.in_a_refuge:
					body.die()
		
		if wave_area.scale.x > 3950:
			active = false

func _call_wave():
	active = true
	$Wave_Area/CollisionShape2D.disabled = false
	line.show()
	process = true
	current_antibiotic = next_antibiotic
	next_antibiotic = antibiotics[randi()%antibiotics.size()]
	var enemies_controller: Node = get_node("../../Enemies")
	#print(enemies_controller)
	
	enemies_controller.spawn_carnivorous()
	enemies_controller.spawn_bacteriophages()
	enemies_controller.spawn_wander()
	
	$Alarm.play()
	
	yield(get_tree().create_timer(0.1),"timeout")
	emit_signal("wave")
	
	print(current_antibiotic)


func deactive():
	process = false
	bodies.clear()
	$Wave_Area.scale = Vector2.ONE
	$Wave_Area/CollisionShape2D.disabled = true
	line.hide()
	line.width = 1


func _on_Area2D_body_entered(body):
	if !bodies.has(body):
		bodies.append(body)


func _on_Timer_timeout():
	_call_wave()

func shake(force: float = 1, time: float = 1):
	shake_force = force*5
	shake_time = time
