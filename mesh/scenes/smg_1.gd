extends Node3D

var animation = "idel"
var animation_speed = {
	"idel": 0.4,
	"walking": 0.5,
	"fire": 1}

@onready var animpl = $AnimationPlayer

var delayedinittimer := Timer.new()

func _ready():
	animpl.play(animation)
	animpl.speed_scale = animation_speed[animation]
	
	#delayed timer for things that cant be done in ready but need to happen once
	delayedinittimer.wait_time = 0.2
	delayedinittimer.one_shot = true
	delayedinittimer.autostart = true
	add_child(delayedinittimer)
	delayedinittimer.timeout.connect(delayedinit)


func _process(delta):
	animpl.play(animation)
	animpl.speed_scale = animation_speed[animation]
	
func delayedinit():
	animation_speed["fire"] = 1 / get_parent().rpmtimer.wait_time
	Functions.print2db(str(self) + "finished delayed init")
