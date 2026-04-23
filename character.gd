extends CharacterBody3D

# movement variables
var speed
const WALK_SPEED = 8.0
const SPRINT_SPEED = 12.0
const JUMP_VELOCITY = 5.0
const SENSITIVITY = 0.003

# head bobbing variables
const BOB_FREQ = 2.8
const BOB_AMP = 0.10
var t_bob = 0.8

# fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 3.0

# on ready camera variables 
@onready var head = $Head
@onready var camera = $Head/Camera3D

# on ready hand variables
var hands_normal = preload("res://sprites/hands.png")
var hands_attacking = preload("res://sprites/attacking.png")
var hands_defending = preload("res://sprites/defending.png")
@onready var hands = $Head/Camera3D/CanvasLayer/hands

# handle first person camera
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(50))
		
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if event is InputEventMouseButton and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	# add the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# handle sprint
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	# get the input direction and handle the movement/deceleration
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction: Vector3 = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
		
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
		
	# handle hand animations
	if Input.is_action_pressed("attack"):
		hands.texture = hands_attacking
	elif Input.is_action_pressed("defend"):
		hands.texture = hands_defending
	else:
		hands.texture = hands_normal
	
	# head bobbing
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# fov
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 0.8)
	

	move_and_slide()
	
func _headbob(time) -> Vector3:
	var pose = Vector3.ZERO
	pose.y = sin(t_bob * BOB_FREQ) * BOB_AMP
	pose.x = cos(t_bob * BOB_FREQ / 2) * BOB_AMP
	return pose
	
