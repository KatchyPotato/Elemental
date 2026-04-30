extends Area3D

# movement variables
const SPEED = 20.0
var direction = Vector3.ZERO

func _ready():
	body_entered.connect(_on_body_entered)
	$AnimatedSprite3D.play("crackling")

func _process(delta):
	global_position += direction * SPEED * delta

func _on_body_entered(body):
	if not body.is_in_group("enemy"):
		queue_free()
