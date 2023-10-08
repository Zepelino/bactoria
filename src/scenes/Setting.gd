extends Control

var MASTER: int = AudioServer.get_bus_index("Master")
var MUSIC: int = AudioServer.get_bus_index("music")
var SFX: int = AudioServer.get_bus_index("sfx")

func _ready():
	$VBoxContainer/Master.value = AudioServer.get_bus_volume_db(MASTER)
	$VBoxContainer/Music.value = AudioServer.get_bus_volume_db(MUSIC)
	$VBoxContainer/SFX.value = AudioServer.get_bus_volume_db(SFX)


func _on_bt_back_button_up():
	Trans._generic_trans()
	yield(Trans, "mid_trans")
	get_parent().rect_position.y = 0


func _on_Master_value_changed(value):
	AudioServer.set_bus_volume_db(MASTER, value)


func _on_Music_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC, value)


func _on_SFX_value_changed(value):
	AudioServer.set_bus_volume_db(SFX, value)


func _on_FullScreen_toggled(button_pressed):
	OS.window_fullscreen = button_pressed


func _on_Vsync_toggled(button_pressed):
	OS.vsync_enabled = button_pressed
