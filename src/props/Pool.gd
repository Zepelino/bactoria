extends Area2D

const minimap_icon = "pool"

func _on_Pool_body_entered(body):
	body.in_a_pool = true


func _on_Pool_body_exited(body):
	body.in_a_pool = false
