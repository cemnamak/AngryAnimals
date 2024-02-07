extends Node2D
@onready var debug_label = $DebugLabel
@onready var spawn_point = $SpawnPoint

const animal_scene: PackedScene = preload("res://animal/animal.tscn")



# Called when the node enters the scene tree for the first time.
func _ready():
	spawn()
	SignalManager.on_update_debug_label.connect(on_update_debug_label)
	SignalManager.on_animal_died.connect(on_animal_died)


func spawn()-> void:
	var animal = animal_scene.instantiate()
	animal.global_position = spawn_point.global_position
	add_child(animal)

func on_update_debug_label(text: String)->void:
	debug_label.text = text
	
func on_animal_died()-> void:
	spawn()
