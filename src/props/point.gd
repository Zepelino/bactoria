extends Area2D

var sight_body: KinematicBody2D = null
var speed: float = 0
var initial_velocity: Vector2 = Vector2.ONE * 400

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !is_instance_valid(sight_body):
		set_process(false)
		speed = 0
		return
	speed = lerp(speed, 600, delta * 2)
	global_position += global_position.direction_to(sight_body.global_position) * speed * delta


func _physics_process(delta):
	global_position += initial_velocity * delta
	initial_velocity = initial_velocity.linear_interpolate(Vector2.ZERO, delta * 2)
	if initial_velocity.is_equal_approx(Vector2.ZERO):
		set_physics_process(false)


func _on_near_body_entered(body):
	if body.is_in_group("P_bacteria") && !is_instance_valid(sight_body):
		set_process(true)
		sight_body = body


func _on_point_body_entered(body):
	if body.is_in_group("P_bacteria") && is_instance_valid(sight_body):
		sight_body.parent.gather_points(4)
		sight_body.parent._play_point_sound()
		queue_free()
	else:
		sight_body = null
		speed = 0
