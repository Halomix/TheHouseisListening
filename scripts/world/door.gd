extends Node3D

@export var open_angle: float = -92.0
@export var open_speed: float = 160.0
@export var closed_text: String = "Press E to open the door"
@export var opened_text: String = "Press E to close the door"
@export var first_open_tension: int = 10
@export var repeat_tension: int = 1
@export var door_audio_path: String = "res://assets/audio/door_creak_01.mp3"

var is_open := false
var _target_angle := 0.0
var _has_opened_once := false
var _door_audio: AudioStreamPlayer3D

func _ready() -> void:
	rotation_degrees.y = 0.0
	_target_angle = 0.0
	_setup_audio()

func _process(delta: float) -> void:
	rotation_degrees.y = move_toward(rotation_degrees.y, _target_angle, open_speed * delta)

func get_interaction_text() -> String:
	return opened_text if is_open else closed_text

func interact(_player: Node) -> void:
	is_open = not is_open
	_target_angle = open_angle if is_open else 0.0
	_play_door_audio()

	var tension := get_tree().get_first_node_in_group("tension_manager")
	if tension != null and tension.has_method("add_tension"):
		if is_open and not _has_opened_once:
			_has_opened_once = true
			tension.add_tension(first_open_tension, "door_first_open")
			var state := get_tree().get_first_node_in_group("game_state")
			if state != null:
				if state.has_method("set_objective_deceptive"):
					var memory := get_tree().get_first_node_in_group("house_memory")
					var lie := "Find the breaker box."
					if memory != null and memory.has_method("get_objective_deception"):
						lie = memory.get_objective_deception("Find the breaker box.")
					state.set_objective_deceptive("Find the breaker box.", lie)
				elif state.has_method("set_objective"):
					state.set_objective("Find the breaker box.")
		else:
			tension.add_tension(repeat_tension, "door_toggle")

func nudge_once() -> void:
	var remembered_target := _target_angle
	var remembered_state := is_open
	_target_angle = -18.0 if not is_open else open_angle - 12.0
	_play_door_audio(-7.0)
	await get_tree().create_timer(0.22).timeout
	_target_angle = remembered_target
	is_open = remembered_state

func force_close() -> void:
	is_open = false
	_target_angle = 0.0
	_play_door_audio(-4.0)

func _setup_audio() -> void:
	_door_audio = AudioStreamPlayer3D.new()
	_door_audio.name = "DoorAudio"
	_door_audio.max_distance = 10.0
	_door_audio.volume_db = -3.0
	add_child(_door_audio)
	if ResourceLoader.exists(door_audio_path):
		_door_audio.stream = load(door_audio_path)

func _play_door_audio(volume_offset_db: float = 0.0) -> void:
	if _door_audio == null or _door_audio.stream == null:
		return
	_door_audio.global_position = global_position + Vector3(0.0, 1.2, 0.0)
	_door_audio.pitch_scale = randf_range(0.94, 1.05)
	_door_audio.volume_db = -3.0 + volume_offset_db
	_door_audio.play()
