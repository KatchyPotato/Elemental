extends CharacterBody3D

const SPEED = 3.0
const GRAVITY = -9.8

func _ready():
	$AnimatedSprite3D.play("goblin-walking")

func _physics_process(delta):
	# gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# get player position
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		var direction = (player.global_position - global_position).normalized()
		direction.y = 0
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	
	move_and_slide()
	
