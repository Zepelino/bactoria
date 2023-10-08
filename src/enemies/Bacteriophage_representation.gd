extends Sprite

var bac: KinematicBody2D

func _die(self_destruction: bool = false):
	if is_instance_valid(bac):
		bac.global_position = global_position
		bac.global_rotation = global_rotation
		bac.die(self_destruction)
	queue_free()
