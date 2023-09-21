extends CharacterBody3D

@export var health = 500

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()

func hit(dmg):
	health -= dmg
	Functions.print2db("test dummie took " + str(dmg) + " dmg")
