extends CharacterBody3D

const SPEED = 6.0
const GRAVITY = -9.8

# death animation variables 
var fading = false
var fade_speed = 5.0
var target_rotation = 0.0
var is_dead = false
var collectable_scene = preload("res://scenes/collectable.tscn")
var spawn_collectable = [true, false]

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
	
	# apply knockback after collision	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("player"):
			var push_dir = (collider.global_position - global_position).normalized()
			push_dir.y = 0
			collider.velocity += push_dir * 20.0
			velocity += -push_dir * 20.0
	
	move_and_slide()
	
func die():
	if is_dead:
		return
	is_dead = true
	death_sound.play()
	$CollisionShape3D.set_deferred("disabled", true)
	
	var spawn = spawn_collectable[randi_range(0, 1)]
	
	if spawn:
		var collectable = collectable_scene.instantiate()
		get_tree().root.add_child(collectable)
		collectable.global_position = global_position + Vector3(0, 2, 0)
	
	fading = true
	sprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var direction = (player.global_position - global_position).normalized()
		direction.y = 0
		look_at(global_position + -direction, Vector3.UP)
	
	
