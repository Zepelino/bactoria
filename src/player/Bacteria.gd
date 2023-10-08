extends KinematicBody2D

#fazer o dano para dropar os pontos

const avoid_force: int = 10000


var multiplier: float = 1
var angle: float = 0

var current: = false

var life: = 100

var attacking: = false
var state: int = 0 #0-normal, 1-tentando chegar perto do player, 2 - reproduction

var move: Vector2

onready var parent: = get_node("../../")

var overlapping_bodies: Array
onready var rays: Node2D = $Rays

var infection_time: int = 15
var infected: bool = false
var in_a_pool: bool = false

var in_a_refuge: bool = false

onready var death_timer: Timer = $Death_Timer
var counter: float = 0

onready var animated_sprite: AnimatedSprite = $AnimatedSprite
onready var remote_transform: RemoteTransform2D = $RemoteTransform2D
onready var damage_sound: AudioStreamPlayer2D = $Damage_Sound

func _ready():
	parent.rng.randomize()
	death_timer.wait_time = parent.rng.randi_range(90, 120)
	death_timer.start()
	
	life =  parent.max_life
	#print(death_timer.wait_time)


func _process(delta):
	if state == 1:
		var steering = Vector2.ZERO
		
		var player_pos = get_tree().get_nodes_in_group("P_bacteria")[0].position
		
		if position.distance_to(player_pos) < 70:
			_set_state(0)
		
		#var axis = position.direction_to(player_pos) * parent.run_speed
		steering += follow_steering()
		steering += avoid_obstacles_steering()
		steering = steering.clamped(parent.max_speed/5)
		
		move += steering
		move = move.clamped(parent.run_speed)
		move = move.linear_interpolate(move_and_slide(move), 0.5)
	
	if state == 1 || state == 0:
		if !attacking:
			animated_sprite.play("walk")
		else:
			animated_sprite.play("attack")
		 
	
	if death_timer.time_left < 40 && death_timer.time_left > 0:
		
		counter += delta * 30/death_timer.time_left
		if counter > 6.28:
			counter = 0
		
		animated_sprite.modulate.a = sin(counter)/2 + 0.6


func _move(axis: Vector2, delta):
	angle += delta
	if angle >= 2*PI:
		angle = 0
	
	if state == 0:
		move = move_and_slide(axis * (sin(angle)/10 + 1))
		
		if current:
			remote_transform.position = global_position.direction_to(get_global_mouse_position()) * global_position.distance_to(get_global_mouse_position())/8


func follow_steering() -> Vector2:
	var wander_angle = global_position.direction_to(get_tree().get_nodes_in_group("P_bacteria")[0].global_position).angle()
	
	var vector_to_circle: Vector2 = move.normalized() * parent.max_speed
	var desired_velocity: Vector2 = vector_to_circle + Vector2(8, 0).rotated(wander_angle)
	
	return (desired_velocity - move) * parent.max_speed/100


func avoid_obstacles_steering() -> Vector2:
	rays.rotation = move.angle()
	
	for raycast in rays.get_children():
		raycast.cast_to.x = move.length()
		if raycast.is_colliding():
			var obstacle: PhysicsBody2D = raycast.get_collider()
			if !is_instance_valid(obstacle):
				continue
			return (position + move - obstacle.position).normalized() * avoid_force
	
	return Vector2.ZERO


func _set_current():
	current = true
	remote_transform.remote_path = parent.cam.get_path()
	for bac in get_tree().get_nodes_in_group("P_bacteria"):
		bac.angle = parent.rng.randf_range(0.1, 2*PI - 0.1)
		if bac == self:
			continue
		bac.get_node("RemoteTransform2D").remote_path = ""


func _call_all():
	for bac in get_tree().get_nodes_in_group("P_bacteria"):
		if bac == self:
			continue
		
		if position.distance_to(bac.position) > 100:
			bac._set_state(1)


func _reproduce():
	animated_sprite.play("reproduction")
	_set_state(2)


func _hp(value: int):
	life += value
	damage_sound.play(0)
	if life <= 0:
		die()


func _damage(entity: String):
	match entity:
		"teste":
			_hp(-20)
		"carnivorous":
			_hp(-25)


func die():
	parent._kill_bacteria(self)


func attack():
	attacking = false
	
	if parent.carnivorous:
		for body in overlapping_bodies:
			body._damage()
	
	for virus in $viruses.get_children():
		virus._die()
	
	if in_a_pool && infected:
		disinfect()
	
	$AnimatedSprite/CPUParticles2D.emitting = false


func _set_state(value):
	state = value
	for raycast in rays.get_children():
		raycast.enabled = value == 1


func _on_Tween_tween_completed(_object, key):
	if key == ":rotation":
		attack()
	


func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if !attacking && state != 2:
		if event is InputEventMouseButton && event.button_index == BUTTON_LEFT && event.pressed:
			#print("atacar: ", name)
			$AnimatedSprite/CPUParticles2D.emitting = true
			attacking = true
			$Tween.interpolate_property(animated_sprite, "rotation", 0, 2*PI, 0.3, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$Tween.start()
			$Spin_Sound.play()


func _on_AnimatedSprite_animation_finished():
	if animated_sprite.animation == "reproduction":
		_set_state(0)
		var bac = parent.bacteria.instance()
		bac.global_position = global_position + Vector2.RIGHT.rotated(parent.rng.randf_range(0, 2*PI))*32
		get_parent().call_deferred("add_child", bac)


func _on_Death_Timer_timeout():
	die()


func _on_Area2D_body_entered(body):
	if !overlapping_bodies.has(body) && !body.is_in_group("Virus"):
		overlapping_bodies.append(body)


func _on_Area2D_body_exited(body):
	if overlapping_bodies.has(body):
		overlapping_bodies.erase(body)


func _infect():
	if !infected:
		infected = true
		$Infection_Timer.wait_time = infection_time
		$Infection_Timer.start()
		$Tween.interpolate_property(animated_sprite, "modulate", Color.white, Color("0e272e"), infection_time)
		$Tween.start()


func disinfect():
	infected = false
	$splash.play()
	$Infection_Timer.stop()
	$Tween.remove(animated_sprite, "modulate")
	animated_sprite.modulate = Color.white


func _on_Infection_Timer_timeout():
	die()


func _create_virus_representation(pos: Vector2, rot: float, bac: KinematicBody2D):
	var virus = parent.virus.instance()
	virus.bac = bac
	$viruses.call_deferred("add_child", virus)
	virus.set_deferred("global_position", pos)
	virus.set_deferred("global_rotation", rot)
	return virus










