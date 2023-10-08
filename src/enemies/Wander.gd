extends KinematicBody2D

const minimap_icon = "wander"

const WANDER_CIRCLE_RADIUS: int = 8
const WANDER_RANDOMNESS: float = 0.2

var wander_angle: float = 0
export (bool) var wandering: bool = true
export (int) var enclosure_radius: int = 3850

var move: Vector2
var max_speed: int = 120
var avoid_force: int = 10000
var max_steering: float = 2.5

onready var rays: Node2D = $Raycasts

var life = 3 + randi()%4 
var dead: bool = false


func wander_steering() -> Vector2:
	wander_angle = rand_range(wander_angle - WANDER_RANDOMNESS, wander_angle + WANDER_RANDOMNESS)
	
	var vector_to_circle: Vector2 = move.normalized() * max_speed
	var desired_velocity: Vector2 = vector_to_circle + Vector2(WANDER_CIRCLE_RADIUS, 0).rotated(wander_angle)
	
	return desired_velocity - move


func _physics_process(_delta):
	var steering: Vector2 = Vector2.ZERO
	
	if wandering:
		steering += enclosure_steering()
		steering += wander_steering()
	
	steering += avoid_obstacles_steering()
	steering = steering.clamped(max_steering)
	
	move += steering
	move = move.clamped(max_speed)
	
	move = move_and_slide(move)


func avoid_obstacles_steering() -> Vector2:
	rays.rotation = move.angle()
	
	for raycast in rays.get_children():
		raycast.cast_to.x = move.length()
		if raycast.is_colliding():
			var obstacle: PhysicsBody2D = raycast.get_collider()
			return (position + move - obstacle.position).normalized() * avoid_force
	
	return Vector2.ZERO

func enclosure_steering() -> Vector2:
	var desired_velocity: Vector2 = Vector2.ZERO
	
	if position.distance_to(Vector2.ZERO) > enclosure_radius:
		desired_velocity += position.direction_to(Vector2.ZERO)
	
	desired_velocity = desired_velocity.normalized() * max_speed
	
	if desired_velocity != Vector2.ZERO:
		wander_angle = desired_velocity.angle()
		return desired_velocity - move
	
	return Vector2.ZERO

func _damage():
	if life > 0:
		life -= 1
		$Damage_Sound.play()
	elif !dead:
		die()

func die():
	dead = true
	
	for i in 1+randi()%2:
		var point = get_parent().packed_point.instance()
		point.global_position = global_position
		point.initial_velocity = Vector2.RIGHT.rotated(rand_range(0, 2*PI)) * rand_range(180, 300)
		get_node("../../Props").call_deferred("add_child", point)
	
	$Death_Sound.play()
	hide()
	set_process(false)
	set_physics_process(false)
	yield($Death_Sound, "finished")
	
	queue_free()

