extends Control




func _on_bt_play_button_up():
	Trans._go_to_scene("res://src/scenes/Petri.tscn")


func _on_bt_quit_button_up():
	Trans._quit()


func _on_bt_how2play_button_up():
	Trans._generic_trans()
	yield(Trans, "mid_trans")
	rect_position.y = -720 


func _on_bt_options_button_up():
	Trans._generic_trans()
	yield(Trans, "mid_trans")
	rect_position.y = -1440
