extends TextureButton

const HOVER_SCALE:Vector2 = Vector2(1.1,1.1)
const DEFAULT_SCALE:Vector2 = Vector2(1.0,1.0)

@export var level_number: int = 1


@onready var level_label = $MC/VBoxContainer/LevelLabel
@onready var score_label = $MC/VBoxContainer/ScoreLabel
var _level_scene:PackedScene

func _ready():
	var level_str: String = str(level_number)
	level_label.text = level_str
	var best_score: int = ScoreManager.get_best_for_level(level_str)
	score_label.text = str(best_score)
	_level_scene = load("res://level/level%s.tscn" % level_number)

func _on_pressed():
	ScoreManager.set_selected_level(level_number)
	get_tree().change_scene_to_packed(_level_scene)

func _on_mouse_entered():
	scale = HOVER_SCALE

func _on_mouse_exited():
	scale = DEFAULT_SCALE
