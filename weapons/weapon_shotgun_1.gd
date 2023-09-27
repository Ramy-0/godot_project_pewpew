extends Node3D


var player_state = "idel"
var animation = "idel"

var readytoshoot = false

#weapons stats
@export var mag_size = 5
var mag = mag_size
@export var reserve = 25
@export var rpm = 120.0
@export var dmg = 15
@export var range = 15.0
@export var reload_time = 0.5
@export var inaccuracy = 5.0
@export var instability = 2.0

#debug duh
@export var debug = false
var bullettracerDB = load("res://weapons/misc/bullet_tracer_debug.tscn")
var hitmarkersDB = load("res://weapons/misc/hit_marker_debug.tscn")

@onready var rcc = $RayCastC
@onready var rcul = $RayCastUL
@onready var rcur = $RayCastUR
@onready var rcdl = $RayCastDL
@onready var rcdr = $RayCastDR
@onready var rcs = [rcc, rcul, rcur, rcdl, rcdr]
@onready var muzzle = $shotgun_1_mesh/Muzzle
@onready var rpmtimer = $RPMTimer
@onready var reloadtimer = $ReloadTimer


func _ready():
	for i in rcs:
		i.target_position.z = -range
	
	rpmtimer.wait_time = 1/rpm*60
	reloadtimer.wait_time = reload_time
	readytoshoot = true

func _process(delta):
	$HUD/AmmoLabel.text = str(mag) + "/" + str(reserve)

func _unhandled_input(event):
	if Input.is_action_just_pressed("mouse_l"):
		shoot()
	if Input.is_action_just_pressed("r_key") and mag < mag_size and reserve > 0:
		reload()

func shoot():
	if mag > 0 and readytoshoot:
		for i in rcs:
			if i.is_colliding():
				if i.get_collider().is_in_group("enemy"):
					if i.get_collider().has_method("hit"):
						i.get_collider().hit(dmg)
		
			#bullet trail
				bullet_trail(muzzle.global_position, i.get_collision_point())
			else:
				bullet_trail(muzzle.global_position, to_global(i.target_position))
		mag -= 1
		readytoshoot = false
		
		rpmtimer.start()

func bullet_trail(pos1, pos2):
	var bullettracer = bullettracerDB.instantiate()
	bullettracer.init(pos1, pos2)
	var world = Functions.get_fst_parent_in(self, "world")
	world.add_child(bullettracer)
	
	

func reload():
	reloadtimer.start()

func _on_rpm_timer_timeout():
	readytoshoot = true

func _on_reload_timer_timeout():
	
	mag += 1
	reserve -= 1
	
	if mag < mag_size:
		reloadtimer.start()
