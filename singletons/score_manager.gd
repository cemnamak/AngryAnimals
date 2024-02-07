extends Node

const DEFAULT_SCORE: int = 1000
const SCORE_PATH: String = "user://animals.json"


var _selected_level: int = 1
var _level_scores:Dictionary = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	score_load()


func set_selected_level(ls: int)-> void:
	_selected_level = ls
	
func get_selected_level()-> int:
	return _selected_level


func check_and_add(level:String)-> void:
	if _level_scores.has(level) == false:
		_level_scores[level] = DEFAULT_SCORE
		
func set_score_for_level(score: int,level: String)-> void:
	check_and_add(level)
	if _level_scores[level] > score:
			_level_scores[level] = score
			save()
			
func get_best_for_level(level: String)-> int:
	check_and_add(level)
	return _level_scores[level]
	
func save()-> void:
	var file = FileAccess.open(SCORE_PATH,FileAccess.WRITE)
	var json_str: String = JSON.stringify(_level_scores)
	file.store_string(json_str)

func score_load()-> void:
	var file = FileAccess.open(SCORE_PATH,FileAccess.READ)
	if file == null:
		save()
	else:
		_level_scores = JSON.parse_string(file.get_as_text())
		
		
		
		
		
		
		
