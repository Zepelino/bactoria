extends Control

const standard_text = "\n[center][wave amp=50 freq=2] [fade start=%s length=5] %s [/fade] [/wave][/center]"
var fade_control: float = -5
var text: String = ""

func _ready():
	set_process(false)

func _process(delta):
	fade_control += delta * 16
	$RichTextLabel.bbcode_text = standard_text%[fade_control, text]
	if fade_control > text.length():
		set_process(false)

func _call_immunity_text(antibiotic: String, imn_txt: String = "-Immunity-"):
	$RichTextLabel/Label.text = imn_txt
	if !$AnimationPlayer.is_playing() || imn_txt != "-Immunity-":
		text = antibiotic
		fade_control = -5
		$RichTextLabel.bbcode_text = standard_text%[fade_control, antibiotic]
		$AnimationPlayer.play("Immunity")
		$RichTextLabel.rect_size.x = 1280
		if imn_txt == "-Immunity-":
			$Immunity_Sound.play()
		set_process(true)


func _on_Wave_Alert_mouse_entered():
	var txt = "Immunity:\n"
	for antibiotic in get_node("../../").immunity:
		txt += "-%s\n"%[antibiotic]
	$shake/Wave_Alert.hint_tooltip = txt
