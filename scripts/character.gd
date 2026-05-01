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

# action variables
var hands_normal = preload("res://sprites/hands/hands.png")
var hands_attacking = preload("res://sprites/hands/attacking.png")
var hands_defending = preload("res://sprites/hands/defending.png")
@onready var hands = $Head/Camera3D/CanvasLayer/hands
@onready var defense_area = $DefenseArea

# sound effects
@onready var shoot_sound = $ShootSound
@onready var hum_sound = $HumSound
@onready var step_sound = $StepSound
@onready var damage_sound = $DamageSound
@onready var heal_sound = $HealSound

# bullet variables
var bullet_scene = preload("res://scenes/bullet.tscn")
@onready var bullet_spawn = $Head/Camera3D/BulletSpawn
var shoot_cooldown = 0.0
const SHOOT_DELAY = 0.5

# health variables
var health = 0
@onready var heart = $"../HeathUI/Heart"
var heart_frames = [
	preload("res://ui/health/heart1.png"),
	preload("res://ui/health/heart2.png"),
	preload("res://ui/health/heart3.png"),
	preload("res://ui/health/heart4.png"),
	preload("res://ui/health/heart5.png"),
	preload("res://ui/health/heart6.png"),
	preload("res://ui/health/heart7.png"),
	preload("res://ui/health/heart8.png"),
	preload("res://ui/health/heart9.png"),
	preload("res://ui/health/heart10.png")
]

var invincible = false
var invincible_timer = 0.0
const INVINCIBLE_DURATION = 0.5
var heal_timer = 0.0
const HEAL_DELAY = 5.0

# handle first person camera
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$DamageArea.body_entered.connect(_on_damage_area_body_entered)
	$DamageArea.area_entered.connect(_on_damage_area_area_entered)
	heart.texture = heart_frames[0]
	

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
		
	# handle hand animations and actions
	if Input.is_action_pressed("attack"):
		hands.texture = hands_attacking
		defense_area.visible = false
		defense_area.monitoring = false
		shoot_cooldown -= delta
		
		if shoot_cooldown <= 0.0:
			shoot_cooldown = SHOOT_DELAY
			shoot_sound.play()
			var bullet = bullet_scene.instantiate()
			get_tree().root.add_child(bullet)
			bullet.global_position = bullet_spawn.global_position
			bullet.direction = -camera.global_transform.basis.z
		
		hum_sound.stop()
	
	elif Input.is_action_pressed("defend"):
		hands.texture = hands_defending
		defense_area.visible = true
		defense_area.monitoring = true
		if not hum_sound.playing:
			hum_sound.play()
	
	else:
		hands.texture = hands_normal
		defense_area.visible = false
		defense_area.monitoring = false
		hum_sound.stop()
	
	# head bobbing
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# fov
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 0.8)
	
	# invincibility cooldown
	if invincible:
		invincible_timer -= delta
		if invincible_timer <= 0.0:
			invincible = false
			
	# health regen while defending
	if Input.is_action_pressed("defend") and health > 0 :
		heal_timer -= delta
		if heal_timer <= 0.0:
			heal_timer = HEAL_DELAY
			health -= 1
			heal_sound.play()
			heart.texture = heart_frames[health]
	
	move_and_slide()
	
func _headbob(time) -> Vector3:
	var pose = Vector3.ZERO
	pose.y = sin(t_bob * BOB_FREQ) * BOB_AMP
	pose.x = cos(t_bob * BOB_FREQ / 2) * BOB_AMP
	return pose
	
func _on_damage_area_body_entered(body):
	if body.is_in_group("enemy"):
		take_damage()
		
func take_damage():
	if invincible:
		return
	invincible = true
	invincible_timer = INVINCIBLE_DURATION
	damage_sound.play()
	health += 1
	heart.texture = heart_frames[health]
	if health >= 9:
		get_tree().reload_current_scene()

func _on_damage_area_area_entered(area):
	if area.is_in_group("projectile"):
		area.queue_free()
		take_damage()
