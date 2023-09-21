extends CharacterBody3D


@export var SPEED = 7.5
@export var JUMP_VELOCITY = 4.5
@export var MOUSE_SENSITIVITY = 0.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var neck := $Neck
@onready var camera = $Neck/Camera3D
@onready var handviewport = $Neck/Camera3D/SubViewportContainer/SubViewport
@onready var handcamera = $Neck/Camera3D/SubViewportContainer/SubViewport/HandCamera3D
@onready var hand = $Neck/Hand

func _physics_process(delta):
	#fall if not on floor
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	#jumping
	if Input.is_action_just_pressed("space_bar") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	#get direction for movement
	var input_dir = Input.get_vector("a_key", "d_key", "w_key", "s_key")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _process(delta):
	#adjust the handviewpoint to match that of the screen, doesn't work for fullscreen for some reason
	handviewport.size = get_viewport().get_visible_rect().size
	handcamera.global_transform = camera.global_transform
	
	#shows/hide the mouse cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE: 
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#debug
		Functions.print2db("mouse mode : " + str(Input.get_mouse_mode()))
		
	#send animation info to weapons (hand)
	var wep_animation_state = "idel"
	if velocity != Vector3.ZERO:
		wep_animation_state = "walking"
	var weapons = hand.get_children()
	for i in weapons:
		if i.is_in_group("weapon"):
			i.player_state = wep_animation_state
#			Functions.print2db(anim)

func _unhandled_input(event):
	#only allow the mouse to move the camera if the cursor is hidden
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_x(-event.relative.y * 0.01 * MOUSE_SENSITIVITY)
			rotate_y(-event.relative.x * 0.01 * MOUSE_SENSITIVITY)
			neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-80), deg_to_rad(90))
