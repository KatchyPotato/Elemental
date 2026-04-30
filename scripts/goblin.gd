extends CharacterBody3D

# movement variables 
const SPEED = 3.0
const GRAVITY = -9.8

# death animation variables
var is_dead = false 
var fading = false
var fade_speed = 5.0
var target_rotation = 0.0

@onready var sprite = $PivotPoint/AnimatedSprite3D
@onready var death_sound = $DeathSound


# bullet variables
var bullet_scene = preload("res://scenes/goblin_bullet.tscn")
@onready var bullet_spawn = $BulletSpawn
@onready var shoot_sound = $ShootSound
var shoot_cooldown = 0.0


func _ready():
	sprite.play("goblin-walking")
	shoot_cooldown = randf_range(1.0, 5.0)

func _process(delta):
	
	# death animation
	if fading:
		target_rotation = lerp(target_rotation, -90.0, delta * 5.0)
		$PivotPoint.rotation_degrees.x = target_rotation
		sprite.modulate.a -= fade_speed * delta
		if sprite.modulate.a <= 0.0 and not $DeathSound.playing:
			queue_free()

func _physics_process(delta):
	
	# exit loop if dead
	if fading:
		return
	
	# gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# get player position and move towards player
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		var direction = (player.global_position - global_position).normalized()
		direction.y = 0
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	
	move_and_slide()
	
	# fire bullet at player
	if player:
		var direction = (player.global_position - global_position).normalized()
		direction.y = 0
		look_at(global_position + direction, Vector3.UP)
		
		shoot_cooldown -= delta
		
		if shoot_cooldown <= 0.0:
			shoot_cooldown = randf_range(1.0, 5.0)
			shoot_sound.play()
			var bullet = bullet_scene.instantiate()
			get_tree().root.add_child(bullet)
			bullet.global_position = bullet_spawn.global_position
			bullet.direction = (player.global_position - bullet_spawn.global_position).normalized()
		
func die():
	if is_dead:
		return
	is_dead = true
	death_sound.play()
	$CollisionShape3D.set_deferred("disabled", true)
	fading = true
	sprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var direction = (player.global_position - global_position).normalized()
		direction.y = 0
		look_at(global_position + -direction, Vector3.UP)
	
	
	
