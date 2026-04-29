extends Marker3D

var spawn_cooldown = 0.0
var goblin_scene = preload("res://scenes/goblin.tscn")
var critter_scene = preload("res://scenes/critter.tscn")

func _ready():
	spawn_cooldown = randf_range(10.0, 30.0)
	
func _physics_process(delta: float) -> void:
	spawn_cooldown -= delta
	if spawn_cooldown <= 0.0:
		spawn_cooldown = randf_range(1.0, 20.0)
		var enemy_scenes = [goblin_scene, critter_scene]
		var chosen = enemy_scenes[randi_range(0, 1)]
		var enemy = chosen.instantiate()
		get_tree().root.add_child(enemy)
		enemy.global_position = global_position
