extends Sprite3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		rotate_y(-0.1)
	elif Input.is_action_pressed("ui_right"):
		rotate_y(0.1)
	
