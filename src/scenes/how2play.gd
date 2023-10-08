extends Control

onready var tween: Tween = $Tween
onready var pages: Control = $Pages

var page: int = 1

onready var max_pages = $Pages.get_child_count()

func tweenar():
	var pos: Vector2 = Vector2(-1280 * (page - 1), 116)
	"""
	match page:
		1:
			pos = Vector2(0, 116)
		
		2:
			pos = Vector2(-1280, 116)
		
		3:
			pos = Vector2(-2560, 116)
	"""
	tween.remove_all()
	tween.interpolate_property(pages, "rect_position", pages.rect_position, pos, 0.5, Tween.TRANS_BACK)
	tween.start()


func _on_go_back_button_up():
	page -= 1
	if page < 1:
		page = max_pages
	
	tweenar()


func _on_go_forward_button_up():
	page += 1
	if page > max_pages:
		page = 1
	
	tweenar()


func _on_bt_back_button_up():
	Trans._generic_trans()
	yield(Trans, "mid_trans")
	get_parent().rect_position.y = 0
