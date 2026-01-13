extends CharacterBody3D

@onready var head = $head
@onready var playercamera = $head/playercamera

var current_speed = 5.0
const walking_speed = 5.0
const sprint_speed = 8.0 
const crouching_speed = 3.0
const jump_velocity = 4.5

var lerp_speed = 10

var height = Vector3.ZERO
var direction = Vector3.ZERO

const mouse_sens = 0.1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(event.relative.x * -mouse_sens))
		head.rotate_x(deg_to_rad(event.relative.y * -mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
		
	if Input.is_action_pressed("crouch"):
		current_speed = crouching_speed
		head.position.y = 1
	elif Input.is_action_just_released("crouch"):
		head.position.y = 2
	else: 
		if Input.is_action_pressed("sprint"):
			current_speed = sprint_speed 
		else:
			current_speed = walking_speed
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed)
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
