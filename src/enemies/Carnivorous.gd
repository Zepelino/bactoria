extends KinematicBody2D

const minimap_icon = "carnivorous"

const WANDER_CIRCLE_RADIUS: int = 8
const WANDER_RANDOMNESS: float = 0.2

var wander_angle: float = 0
export (bool) var wandering: bool = true
export (int) var enclosure_radius: int = 3850

var move: Vector2
var max_speed: int = 80
var chasing_speed: int = 125
var avoid_force: int = 10
var max_steering: float = 2.5


var life: int = 50 + randi()%30
var dead: bool = false

var state: int = 0 #0 - wandering, 1 - chasing, 2 - attacking

var bodies: Array = []
var bodies_to_damage: Array = []
var body_pos_bef_att: Vector2 = Vector2.ZERO

var antibiotic: String = ""

func _physics_process(delta):
	var steering: Vector2 = Vector2.ZERO
	var spd: int = 0
	
	match state:
		0:
			steering += enclosure_steering()
			steering += wander_steering()
			spd = max_speed
		
		1:
			if !bodies.empty():
				steering += chase_steering()
				spd = chasing_speed
			else:
				set_state(0)
		
		2:
			if !bodies_to_damage.empty():
				move = move.linear_interpolate(position.direction_to(body_pos_bef_att), delta*10)
	
	steering = steering.clamped(spd)
	
	if state != 2:
		move += steering
	move = move.clamped(max_speed)
	
	$Sprite.rotation = move.angle()
	move = move.linear_interpolate(move_and_slide(move), 0.5)


func wander_steering() -> Vector2:
	wander_angle = rand_range(wander_angle - WANDER_RANDOMNESS, wander_angle + WANDER_RANDOMNESS)
	
	var vector_to_circle: Vector2 = move.normalized() * max_speed
	var desired_velocity: Vector2 = vector_to_circle + Vector2(WANDER_CIRCLE_RADIUS, 0).rotated(wander_angle)
	
	return desired_velocity - move


func enclosure_steering() -> Vector2:
	var desired_velocity: Vector2 = Vector2.ZERO
	
	if position.distance_to(Vector2.ZERO) > enclosure_radius:
		desired_velocity += position.direction_to(Vector2.ZERO)
	
	desired_velocity = desired_velocity.normalized() * max_speed
	
	if desired_velocity != Vector2.ZERO:
		wander_angle = desired_velocity.angle()
		return desired_velocity - move
	
	return Vector2.ZERO


func chase_steering() -> Vector2:
	var chase_angle = global_position.direction_to(bodies[0].global_position).angle()
	
	var vector_to_circle: Vector2 = move.normalized() * chasing_speed
	var desired_velocity: Vector2 = vector_to_circle + Vector2(8, 0).rotated(chase_angle)
	
	return desired_velocity - move


func set_state(value: int) -> void:
	state = value
	
	if value == 2:
		body_pos_bef_att = bodies_to_damage[0].global_position
		attack()

#bug de atacar pela parede
func attack():
	var valid: bool = false
	
	for bac in get_tree().get_nodes_in_group("P_bacteria"):
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(global_position, bac.global_position, [self])
		if result && result.collider is KinematicBody2D:
			valid = true
			break
	
	if !valid:
		set_state(1)
		return
	
	$Attack_Timer.start()
	$Attack_Timer/Damage_Timer.start()
	
	yield($Attack_Timer/Damage_Timer, "timeout")
	if state != 2:
		return
	$Sprite/Damage_area/Sprite.show()
	
	for bac in bodies_to_damage:
		bac._damage("carnivorous")
	
	yield(get_tree().create_timer(0.2), "timeout")
	$Sprite/Damage_area/Sprite.hide()


func _damage():
	if life > 0:
		life -= 1
		$Damage_Sound.play()
	elif !dead:
		die()


func die():
	dead = true
	
	get_parent()._carnivorous_dead(antibiotic)
	
	for i in 10+randi()%5:
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



func _on_Area2D_body_entered(body):
	if !bodies.has(body):
		bodies.append(body)
	
	if state == 2:
		return
	set_state(1)


func _on_Area2D_body_exited(body):
	if bodies.has(body):
		bodies.erase(body)
	
	if bodies.empty() && state != 2:
		set_state(0)


func _on_Damage_area_body_entered(body):
	if state != 2:
		if !bodies_to_damage.has(body):
			bodies_to_damage.append(body)
		set_state(2)


func _on_Damage_area_body_exited(body):
	if bodies_to_damage.has(body):
		bodies_to_damage.erase(body)


func _on_Attack_Timer_timeout():
	if bodies_to_damage.empty():
		set_state(1)
	else:
		set_state(2)








