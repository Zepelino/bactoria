extends CanvasLayer

onready var tween: Tween = $Tween
onready var trans: ColorRect = $trans

signal mid_trans()

func _go_to_scene(path: String):
	tween.remove_all()
	tween.interpolate_property(trans.material,"shader_param/dissolve", -0.1, 1.0, 0.8, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	get_tree().change_scene(path)
	emit_signal("mid_trans")
	tween.interpolate_property(trans.material,"shader_param/dissolve", 1.0, -0.1, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()

func _quit():
	tween.remove_all()
	tween.interpolate_property(trans.material,"shader_param/dissolve", -0.1, 1.0, 0.5)
	tween.start()
	yield(tween, "tween_all_completed")
	get_tree().quit()

func _generic_trans():
	tween.remove_all()
	tween.interpolate_property(trans.material,"shader_param/dissolve", -0.1, 1.0, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	emit_signal("mid_trans")
	tween.interpolate_property(trans.material,"shader_param/dissolve", 1.0, -0.1, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()
