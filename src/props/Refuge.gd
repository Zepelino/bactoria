extends Area2D

const minimap_icon = "refuge"

func _on_Pool_body_entered(body):
	body.in_a_refuge = true


func _on_Pool_body_exited(body):
	body.in_a_refuge = false
