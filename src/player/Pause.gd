extends Control


func _on_Menu_button_up():
	get_tree().paused = false
	Trans._go_to_scene("res://src/scenes/Menu.tscn")


func _on_Quit_button_up():
	get_tree().paused = false
	Trans._quit()


func _unhandled_input(_event):
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
		visible = get_tree().paused
