extends KinematicBody2D

var move: Vector2
var max_speed: int = 240
var max_steering: float = 10

var dead: bool = false

var target: KinematicBody2D
var aim: bool = false
var representation: Sprite

onready var animated_sprite: AnimatedSprite = $Sprite

func _ready():
	get_tree().get_nodes_in_group("Player")[0].connect("main_changed", self, "_main_changed")


func _physics_process(_delta):
	var steering: Vector2 = Vector2.ZERO
	
	if is_instance_valid(target):
		if !aim:
			steering += chase_steering()
		
	else:
		if aim:
			die()
		elif get_tree().get_nodes_in_group("P_bacteria").size() > 0:
			target = get_tree().get_nodes_in_group("P_bacteria")[0]
	
	steering = steering.clamped(max_steering)
	
	move += steering
	move = move.clamped(max_speed)
	
	animated_sprite.rotation = move.angle() + 1.57
	
	move = move_and_slide(move)


func chase_steering() -> Vector2:
	var chase_angle = global_position.direction_to(target.global_position).angle()
	
	var vector_to_circle: Vector2 = move.normalized() * max_speed
	var desired_velocity: Vector2 = vector_to_circle + Vector2(8, 0).rotated(chase_angle)
	
	return desired_velocity - move


func die(self_destruct: bool = false):
	dead = true
	
	if self_destruct:
		pass
		#global_position = representation.global_position
	
	for i in 1+randi()%2:
		var point = get_parent().packed_point.instance()
		point.global_position = global_position
		point.initial_velocity = Vector2.RIGHT.rotated(rand_range(0, 2*PI)) * rand_range(180, 300)
		get_node("../../Props").call_deferred("add_child", point)
	
	$Death_Sound.play()
	$Infect_Timer.stop()
	hide()
	set_process(false)
	set_physics_process(false)
	yield($Death_Sound, "finished")
	
	queue_free()

func _main_changed(main):
	if !aim:
		target = main


func _on_Area2D_body_entered(body):
	if !aim:
		target = body
		representation = body._create_virus_representation(global_position, (global_position - body.global_position).angle(), self)
		aim = true
		set_process(false)
		set_physics_process(false)
		hide()
		$Infect_Timer.start()
	


func _on_Infect_Timer_timeout():
	if is_instance_valid(target):
		target._infect()
		representation._die(true)
