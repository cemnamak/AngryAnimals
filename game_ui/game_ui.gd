extends Control

const MAIN = preload("res://main/main.tscn")

@onready var level_label = $MarginContainer/VB/LevelLabel
@onready var attempts_label = $MarginContainer/VB/AttemptsLabel
@onready var vb_2 = $MarginContainer/VB2
@onready var complete_sound = $complete_sound

var _level_completed: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	level_label.text = "LEVEL %s" % ScoreManager.get_selected_level()
	SignalManager.on_score_updated.connect(update_attempts)
	SignalManager.on_level_completed.connect(on_level_completed)
	update_attempts(0)
	
func update_attempts(attempts: int)-> void:
	attempts_label.text = "Attempts %s" % attempts
	
func on_level_completed()-> void:
	_level_completed = true
	vb_2.show()
	complete_sound.play()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("space") and _level_completed:
		get_tree().change_scene_to_packed(MAIN)
		
	
