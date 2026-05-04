extends CharacterBody3D

# movement variables
const GRAVITY = -9.8

# sound

@onready var collect_sound = $PickupArea/CollectSound

# texture variables
var colors = [
	preload("res://sprites/crystal/crystal-red.png"),
	preload("res://sprites/crystal/crystal-blue.png"),
	preload("res://sprites/crystal/crystal-yellow.png")
]

func _ready():
	$Crystal.texture = colors[randi_range(0, 2)]
	$PickupArea.body_entered.connect(_on_pickup_area_entered)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	move_and_slide()

func _on_pickup_area_entered(body):
	if body.is_in_group("player"):
		GameState.crystal_count += 1
		$Crystal.visible = false
		$PickupArea/CollisionShape3D.set_deferred("disabled", true)
		collect_sound.play()
		await collect_sound.finished
		queue_free()
