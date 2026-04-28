extends CharacterBody3D

const SPEED = 6.0
const GRAVITY = -9.8

# death animation variables 
var fading = false
var fade_speed = 5.0
var target_rotation = 0.0
var is_dead = false

@onready var sprite = $PivotPoint/AnimatedSprite3D
@onready var death_sound = $DeathSound

func _ready():
	sprite.play("critter-walking")
	
func _process(delta):
	if fading:
		target_rotation = lerp(target_rotation, -90.0, delta * 5.0)
		$PivotPoint.rotation_degrees.x = target_rotation
		sprite.modulate.a -= fade_speed * delta
		if sprite.modulate.a <= 0.0 and not $DeathSound.playing:
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
	death_sound.play()
	$CollisionShape3D.disabled = true
	fading = true
	sprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var direction = (player.global_position - global_position).normalized()
		direction.y = 0
		look_at(global_position + -direction, Vector3.UP)
	
	
