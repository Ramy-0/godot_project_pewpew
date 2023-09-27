extends Node3D

var player_state = "idel"
var animation = "idel"

var readytoshoot = false

#weapons stats
@export var mag_size = 30
var mag = mag_size
@export var reserve = 90
@export var rpm = 300.0
@export var dmg = 15
@export var range = 20
@export var reload_time = 5.0
@export var inaccuracy = 5.0
@export var instability = 2.0

#debug duh
@export var debug = false
var bullettracerDB = load("res://weapons/misc/bullet_tracer_debug.tscn")
var hitmarkersDB = load("res://weapons/misc/hit_marker_debug.tscn")


@onready var mesh = $smg_1_mesh
@onready var rpmtimer = $RPMTimer
@onready var reloadtimer = $ReloadTimer
@onready var raycast = $RayCast3D
@onready var muzzle = $smg_1_mesh/Muzzle

func _ready():
	rpmtimer.wait_time = 1/rpm*60
	raycast.target_position.z = - range
	readytoshoot = true
	
	randomize()

func _process(delta):
	#decide what animation to play
	if not rpmtimer.is_stopped():
		animation = "fire"
	elif player_state == "idel":
		animation = "idel"
	elif  player_state == "walking":
		animation = "walking"

	#send animation to mesh
	mesh.animation = animation
	
	#update ammo count
	$HUD/AmmoCount.text = str(mag) + "/" + str(reserve)

func _unhandled_input(event):
	if Input.is_action_just_pressed("mouse_l"):
		shoot()
	if Input.is_action_just_pressed("r_key") and mag < mag_size and reserve > 0:
		reload_gun()

func shoot():
#	Functions.print2db("fire")
	if mag > 0 and readytoshoot:
		#inaccuracy bit
		var spread = randf_range(0.0, deg_to_rad(inaccuracy))
		raycast.rotate_y(spread)
		raycast.rotate_z(randf_range(0.0, 2*PI))
		
		#shoot the bullet
		if raycast.is_colliding():
			if raycast.get_collider().is_in_group("enemy"):
				if raycast.get_collider().has_method("hit"):
					raycast.get_collider().hit(dmg)
			
		
			#bullet trail
			bullet_trail(muzzle.global_position, raycast.get_collision_point())
		else:
			bullet_trail(muzzle.global_position, to_global(raycast.target_position))
		
		#instability bit
		get_parent().get_parent().rotate_x(deg_to_rad(instability))
		
		#reduce 1 bullet from the mag
		mag -= 1
		
		#start the timer to next shot
		readytoshoot = false
		rpmtimer.start()

func reload_gun():
	if mag < mag_size and reserve > 0:
		readytoshoot = false
		reloadtimer.start()

func bullet_trail(pos1, pos2):
	var bullettracer = bullettracerDB.instantiate()
	bullettracer.init(pos1, pos2)
	var world = Functions.get_fst_parent_in(self, "world")
	world.add_child(bullettracer)
	
	var hitmarker_t = hitmarkersDB.instantiate()
	var color = Color(1,1,1,1)
	if raycast.get_collider() == null:
		color = Color(1,1,0,1)
	elif raycast.get_collider().is_in_group("geometry"):
		color = Color(1,0.65,0,1)
	elif raycast.get_collider().is_in_group("enemy"):
		color = Color(1,0,0,1)
	hitmarker_t.init(pos2, color)
	
	world.add_child(hitmarker_t)
	
#	var hitmarker_p = hitmarkersDB.instantiate()
#	hitmarker_p.init(pos1, Color(0,1,0,1))
#	world.add_child(hitmarker_p)

func _on_rpm_timer_timeout():
	readytoshoot = true
	
	#reset weapon spread
	raycast.rotation = Vector3.ZERO
	
	if Input.is_action_pressed("mouse_l"):
		shoot()

func _on_reload_timer_timeout():
	if reserve > mag_size:
		reserve -= mag_size - mag
		mag = mag_size
	else:
		mag = reserve
		reserve = 0
	readytoshoot = true
