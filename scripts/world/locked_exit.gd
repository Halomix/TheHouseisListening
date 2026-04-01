extends Node3D

@export var open_angle: float = 94.0
@export var open_speed: float = 160.0
@export var required_item_id: String = "house_key"
@export var requires_power: bool = true
@export var blocked_by_active_threat: bool = true
@export var locked_text: String = "You need the house key"
@export var no_power_text: String = "The door release has no power"
@export var active_threat_text: String = "Something waits at the exit. Hide first."
@export var ready_text: String = "Press E to unlock the exit"
@export var opened_text: String = "Press E to close the exit"
@export var door_audio_path: String = "res://assets/audio/door_creak_01.mp3"

var is_open := false
var _target_angle := 0.0
var _has_unlocked := false
var _door_audio: AudioStreamPlayer3D

func _ready() -> void:
	rotation_degrees.y = 0.0
	_setup_audio()

func _process(delta: float) -> void:
	rotation_degrees.y = move_toward(rotation_degrees.y, _target_angle, open_speed * delta)

func get_interaction_text() -> String:
	if is_open:
		return opened_text

	var state := get_tree().get_first_node_in_group("game_state")
	if blocked_by_active_threat and state != null and state.has_method("is_threat_active") and state.is_threat_active():
		return active_threat_text

	if not _requirements_met():
		if requires_power and state != null and state.has_method("is_power_restored") and not state.is_power_restored():
			return no_power_text
		return locked_text
	return ready_text

func interact(_player: Node) -> void:
	var state := get_tree().get_first_node_in_group("game_state")
	if blocked_by_active_threat and state != null and state.has_method("is_threat_active") and state.is_threat_active():
		var hud := get_tree().get_first_node_in_group("hud")
		if hud != null and hud.has_method("flash_message"):
			hud.flash_message(active_threat_text, 1.9)
		return

	if not _requirements_met():
		var hud := get_tree().get_first_node_in_group("hud")
		if hud != null and hud.has_method("flash_message"):
			hud.flash_message(get_interaction_text(), 1.8)
		return

	is_open = not is_open
	_target_angle = open_angle if is_open else 0.0
	_play_door_audio()

	if is_open and not _has_unlocked:
		_has_unlocked = true
		var hud := get_tree().get_first_node_in_group("hud")
		if hud != null and hud.has_method("flash_message"):
			hud.flash_message("The last lock gives way.", 2.2)
		if state != null and state.has_method("set_objective"):
			state.set_objective("Leave the house.")
		var tension := get_tree().get_first_node_in_group("tension_manager")
		if tension != null and tension.has_method("add_tension"):
			tension.add_tension(12, "exit_unlock")

func _requirements_met() -> bool:
	var state := get_tree().get_first_node_in_group("game_state")
	if state == null:
		return false
	if requires_power and state.has_method("is_power_restored") and not state.is_power_restored():
		return false
	return state.has_method("has_item") and state.has_item(required_item_id)

func force_close() -> void:
	is_open = false
	_target_angle = 0.0
	_play_door_audio(-4.0)

func _setup_audio() -> void:
	_door_audio = AudioStreamPlayer3D.new()
	_door_audio.name = "DoorAudio"
	_door_audio.max_distance = 12.0
	_door_audio.volume_db = -2.0
	add_child(_door_audio)
	if ResourceLoader.exists(door_audio_path):
		_door_audio.stream = load(door_audio_path)

func _play_door_audio(volume_offset_db: float = 0.0) -> void:
	if _door_audio == null or _door_audio.stream == null:
		return
	_door_audio.global_position = global_position + Vector3(0.0, 1.2, 0.0)
	_door_audio.pitch_scale = randf_range(0.92, 1.02)
	_door_audio.volume_db = -2.0 + volume_offset_db
	_door_audio.play()
