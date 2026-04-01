extends Node

@export var event_interval_min: float = 7.5
@export var event_interval_max: float = 14.0
@export var post_key_interval_min: float = 5.0
@export var post_key_interval_max: float = 10.0

var _event_timer: float = 0.0
var _last_event_tag: String = ""
var _key_phase: bool = false

func _ready() -> void:
	randomize()
	add_to_group("house_director")
	_reset_timer()
	call_deferred("_connect_state")

func _process(delta: float) -> void:
	var state := get_tree().get_first_node_in_group("game_state")
	if state == null:
		return
	if state.has_method("is_fail_state") and state.is_fail_state():
		return
	if state.has_method("is_win_state") and state.is_win_state():
		return
	if state.has_method("is_threat_active") and state.is_threat_active():
		return

	_event_timer -= delta
	if _event_timer > 0.0:
		return

	_fire_soft_event()
	_reset_timer()

func _connect_state() -> void:
	var state := get_tree().get_first_node_in_group("game_state")
	if state != null and state.has_signal("item_added") and not state.item_added.is_connected(_on_item_added):
		state.item_added.connect(_on_item_added)

func _on_item_added(item_id: String) -> void:
	if item_id == "house_key":
		_key_phase = true
		_reset_timer()

func _fire_soft_event() -> void:
	var level := get_tree().get_first_node_in_group("test_level")
	var memory := get_tree().get_first_node_in_group("house_memory")
	var state := get_tree().get_first_node_in_group("game_state")
	var tension := get_tree().get_first_node_in_group("tension_manager")
	if level == null or memory == null or tension == null:
		return

	var focus_room: String = "hall"
	if memory.has_method("get_dominant_room"):
		focus_room = memory.get_dominant_room()
	var safe_room: String = focus_room
	if memory.has_method("get_safest_room"):
		safe_room = memory.get_safest_room()
	var focus_pressure: float = 0.0
	if memory.has_method("get_room_pressure"):
		focus_pressure = float(memory.get_room_pressure(focus_room))

	var current_tension: float = 0.0
	if tension.has_method("get_tension"):
		current_tension = float(tension.get_tension())
	var event_tag: String = "watch"

	if memory.has_method("is_player_marked") and memory.is_player_marked():
		event_tag = "marked"
		if level.has_method("framed_room_event"):
			await level.framed_room_event(safe_room)
		if level.has_method("mutate_focus_room"):
			await level.mutate_focus_room(safe_room, 2)
		if state != null and state.has_method("set_objective_deceptive"):
			var truth := "Get clear of the %s." % safe_room.capitalize()
			var lie: String = memory.get_objective_deception(truth) if memory.has_method("get_objective_deception") else truth
			state.set_objective_deceptive(truth, lie)
		tension.add_tension(3, "soft_marked")
	elif _key_phase and current_tension >= 38 and safe_room == focus_room:
		event_tag = "safe_breach"
		if level.has_method("false_safe_room_event"):
			await level.false_safe_room_event(safe_room)
		if level.has_method("mutate_focus_room"):
			await level.mutate_focus_room(focus_room, 3)
		if state != null and state.has_method("set_objective_deceptive"):
			var truth := "The %s is not safe." % safe_room.capitalize()
			var lie: String = memory.get_objective_deception(truth) if memory.has_method("get_objective_deception") else truth
			state.set_objective_deceptive(truth, lie)
		tension.add_tension(4, "soft_safe_breach")
	elif current_tension >= 28:
		event_tag = "obsession"
		if level.has_method("obsession_whisper_event"):
			await level.obsession_whisper_event(focus_room)
		if level.has_method("mutate_focus_room") and focus_pressure >= 1.8:
			await level.mutate_focus_room(focus_room, 2)
		if state != null and state.has_method("set_objective_deceptive"):
			var truth := "Return to the %s." % focus_room.capitalize()
			var lie: String = memory.get_objective_deception(truth) if memory.has_method("get_objective_deception") else truth
			state.set_objective_deceptive(truth, lie)
		tension.add_tension(2, "soft_obsession")
	else:
		event_tag = "shift"
		if level.has_method("soft_room_shift"):
			await level.soft_room_shift(focus_room)
		if level.has_method("mutate_focus_room"):
			await level.mutate_focus_room(focus_room, 1)
		if state != null and state.has_method("set_objective_deceptive"):
			var truth := "Keep moving."
			var lie: String = memory.get_objective_deception(truth) if memory.has_method("get_objective_deception") else truth
			state.set_objective_deceptive(truth, lie)
		tension.add_tension(1, "soft_shift")

	_last_event_tag = event_tag

func _reset_timer() -> void:
	if _key_phase:
		_event_timer = randf_range(post_key_interval_min, post_key_interval_max)
	else:
		_event_timer = randf_range(event_interval_min, event_interval_max)
