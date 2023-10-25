extends Control

@export var active = false

func _ready():
	if active:
		show()
	else:
		hide()
	
	Functions.pass_bd_line.connect(print2screen)


func _process(delta):
	$VBoxContainer/Windowsize.text = "windowsize : " + str(get_viewport().get_visible_rect().size)
	$VBoxContainer/FPS.text = "FPS : " + str(Engine.get_frames_per_second())
	$VBoxContainer/VelocityVector.text = "velocity : " + str(get_parent().velocity)
	
	
	
func _unhandled_input(event):
	#show/hide the menu
	if Input.is_action_just_pressed("tidle"):
		active = !active
		
		if active:
			show()
		else:
			hide()

func print2screen(string):
	#shows the output menu in the top right corner of the game for easier debugging
	$RichTextLabel.add_text("\n" + str(string))
