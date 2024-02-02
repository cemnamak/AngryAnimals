extends RigidBody2D

enum ANIMAL_STATE {READY,DRAG,RELEASE}
var _state:ANIMAL_STATE = ANIMAL_STATE.READY;

const DRAG_LIM_MAX: Vector2 = Vector2(0,60)
const DRAG_LIM_MIN: Vector2 = Vector2(-60,0)
const IMPULSE_MULT: float = 20.0
const IMPULSE_MAX: float = 1200.0



@onready var stretch_sound = $StretchSound
@onready var launch_sound = $LaunchSound
@onready var kick_sound = $KickSound
@onready var arrow = $Arrow


var _dead: bool = false

var _start: Vector2 = Vector2.ZERO
var _drag_start: Vector2 = Vector2.ZERO
var _dragged_vector: Vector2 = Vector2.ZERO
var _last_dragged_vector: Vector2 = Vector2.ZERO

var _fired_time: float = 0.0
var _last_drag_amount: float = 0.0
var _last_collision_count: int = 0
var _arrow_scale_x: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	_arrow_scale_x = arrow.scale.x
	_start = position
	arrow.hide()

func set_new_state(new_state:ANIMAL_STATE)-> void:
	_state = new_state
	if _state == ANIMAL_STATE.RELEASE:
		set_release()
	elif _state == ANIMAL_STATE.DRAG:
		set_drag()
	
func set_release()-> void:
	arrow.hide()
	freeze = false	
	apply_central_impulse(get_impulse())
	launch_sound.play()	
	SignalManager.on_attempt_made.emit()

func set_drag()-> void:
	arrow.show()
	stretch_sound.play()
	_drag_start = get_global_mouse_position()
	
func get_dragged_vector(gmp:Vector2) -> Vector2:
	return gmp - _drag_start
	
func scale_arrow()-> void:
	var imp_len = get_impulse().length()
	var perc = imp_len / IMPULSE_MAX
	arrow.scale.x = (_arrow_scale_x * perc) + _arrow_scale_x
	arrow.rotation = (_start - position).angle()

func drag_in_limits()-> void:
	_dragged_vector.x = clampf(_dragged_vector.x,DRAG_LIM_MIN.x,DRAG_LIM_MAX.x)
	_dragged_vector.y = clampf(_dragged_vector.y,DRAG_LIM_MIN.y,DRAG_LIM_MAX.y)
	
	position = _start + _dragged_vector
	

func _physics_process(delta):
	#on_update_debug_label()
	update(delta)

func get_impulse()-> Vector2:
	return _dragged_vector * -1 * IMPULSE_MULT

func update(delta:float)-> void:
	
	match _state:
		ANIMAL_STATE.DRAG:
			update_drag()
		ANIMAL_STATE.RELEASE:
			play_collision()
			
func update_drag()-> void:
	if detect_release():
		return
	var gmp = get_global_mouse_position()
	_dragged_vector = get_dragged_vector(gmp)	
	drag_in_limits()
	scale_arrow()

func detect_release() -> bool:
	if _state == ANIMAL_STATE.DRAG:
		if Input.is_action_just_released("drag"):
			set_new_state(ANIMAL_STATE.RELEASE)
			return true
	return false


func on_update_debug_label() -> void:
	var s: String ="g_pos: %s _contacts : %s\n" % [
		Utils.vec2_to_str(global_position),
		get_contact_count()
	]
	
	s += "_start: %s\n_drag_start: %s \n_dragged_vector: %s" % [
			Utils.vec2_to_str(_start),
			Utils.vec2_to_str(_drag_start),
			Utils.vec2_to_str(_dragged_vector)
		]
	
	s += "angular_velocity: %.1f\nlinear_velocity: %s\n_fired_time: %.1f" % [
			angular_velocity,
			Utils.vec2_to_str(linear_velocity),
			_fired_time
		]
	SignalManager.on_update_debug_label.emit(s)




	
func play_collision()-> void:
	if _last_collision_count == 0 and get_contact_count() > 0 and not kick_sound.playing:
		kick_sound.play()
	_last_collision_count = get_contact_count()	
	
	


func die()-> void:
	if _dead:
		return
	_dead = true

	
	queue_free()
	SignalManager.on_animal_died.emit()

func _on_screen_exited():	
	die()


func _on_input_event(viewport, event:InputEvent, shape_idx):
	
	if _state == ANIMAL_STATE.READY and event.is_action_pressed("drag"):
		set_new_state(ANIMAL_STATE.DRAG)
	elif event.is_action_released("drag"):
		set_new_state(ANIMAL_STATE.RELEASE)
	


func _on_sleeping_state_changed():
	if sleeping:
		var cb = get_colliding_bodies()
		if cb.size() > 0:
			cb[0].vanish()
		call_deferred("die")
