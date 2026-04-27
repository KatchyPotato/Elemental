extends CharacterBody3D

const SPEED = 7.0
const GRAVITY = -9.8

# death animation variables 
var fading = false
var fade_speed = 5.0

func _ready():
	$AnimatedSprite3D.play("critter-walking")
	
func _process(delta):
	if fading:
		$AnimatedSprite3D.modulate.a -= fade_speed * delta
		if $AnimatedSprite3D.modulate.a <= 0:
			queue_free()

func _physics_process(delta):
	if fading:
		return
	
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
	
func die():
	fading = true
	
	
