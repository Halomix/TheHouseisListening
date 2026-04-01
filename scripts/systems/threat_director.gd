extends Node

@export var active_threat_duration: float = 5.6
@export var pulse_interval: float = 1.05
@export var key_item_id: String = "house_key"
@export var grace_period_before_attack: float = 1.0
@export var exposed_attack_time: float = 2.0
@export var re_exposed_attack_time: float = 0.75
@export var warning_interval: float = 0.65
@export var movement_speed_threshold: float = 1.2
@export var flashlight_exposure_multiplier: float = 0.65
@export var hidden_flashlight_attack_time: float = 0.8
@export var repeat_hunt_min_delay: float = 10.0
@export var repeat_hunt_max_delay: float = 20.0
@export var min_tension_for_repeat_hunt: int = 34
@export var max_repeat_hunts: int = 2

var _active_threat: bool = false
var _post_key_phase: bool = false
var _hidden_time: float = 0.0
var _pulse_time: float = 0.0
var _pulse_index: int = 0
var _entered_hide_during_threat: bool = false
var _time_since_start: float = 0.0
var _time_exposed: float = 0.0
var _warning_time: float = 0.0
var _max_exposure_ratio: float = 0.0
var _survival_grade: String = ""
var _pre_hunt_played: bool = false
var _hidden_flashlight_time: float = 0.0
var _repeat_hunts_started: int = 0
var _repeat_hunt_timer: float = 0.0
var _current_target_zone: String = "hall"

func _ready() -> void:
	randomize()
	add_to_group("threat_director")
	call_deferred("_connect_state")
	_reset_repeat_timer()

func _process(delta: float) -> void:
	var state := get_tree().get_first_node_in_group("game_state")
	if state == null:
		return
	if state.has_method("is_fail_state") and state.is_fail_state():
		_active_threat = false
		return
	if state.has_method("is_win_state") and state.is_win_state():
		_active_threat = false
		return

	if _active_threat:
		_run_active_threat(delta, state)
	else:
		_run_passive_pressure(delta, state)

func _connect_state() -> void:
	var state := get_tree().get_first_node_in_group("game_state")
	if state == null:
		return
	if state.has_signal("item_added") and not state.item_added.is_connected(_on_item_added):
		state.item_added.connect(_on_item_added)

func _on_item_added(item_id: String) -> void:
	if item_id != key_item_id:
		return
	_post_key_phase = true
	_repeat_hunts_started = 0
	_reset_repeat_timer()
	_start_active_threat("initial")

func _run_passive_pressure(delta: float, state: Node) -> void:
	if not _post_key_phase:
		return
	if not state.has_method("has_item") or not state.has_item(key_item_id):
		return
	if _repeat_hunts_started >= max_repeat_hunts:
		return

	_repeat_hunt_timer -= delta
	if _repeat_hunt_timer > 0.0:
		return

	var tension := get_tree().get_first_node_in_group("tension_manager")
	var memory := get_tree().get_first_node_in_group("house_memory")
	if tension == null or memory == null:
		_reset_repeat_timer()
		return

	var should_repeat := false
	var current_tension: float = 0.0
	if tension.has_method("get_tension"):
		current_tension = float(tension.get_tension())
	if current_tension >= min_tension_for_repeat_hunt:
		should_repeat = true
	if memory.has_method("is_player_marked") and memory.is_player_marked():
		should_repeat = true
	if memory.has_method("get_hide_use_count") and memory.get_hide_use_count("linen_closet") >= 2:
		should_repeat = true

	if should_repeat:
		_repeat_hunts_started += 1
		_start_active_threat("repeat")
	else:
		_reset_repeat_timer()

func _run_active_threat(delta: float, state: Node) -> void:
	_time_since_start += delta
	_pulse_time += delta
	_warning_time += delta

	var player := get_tree().get_first_node_in_group("player")
	var level := get_tree().get_first_node_in_group("test_level")
	var memory := get_tree().get_first_node_in_group("house_memory")
	var is_hidden: bool = state.has_method("is_hidden") and state.is_hidden()
	var flashlight_on: bool = player != null and player.has_method("is_flashlight_on") and player.is_flashlight_on()

	var active_hide_id: String = ""
	if player != null and player.has_method("get_active_hide_spot_id"):
		active_hide_id = player.get_active_hide_spot_id()
	var hide_penalty: float = 1.0
	if active_hide_id != "" and memory != null and memory.has_method("get_hide_use_count"):
		var repeat_count: int = max(0, int(memory.get_hide_use_count(active_hide_id)) - 1)
		hide_penalty = maxf(1.0 - float(repeat_count) * 0.12, 0.68)

	if is_hidden:
		if not _entered_hide_during_threat:
			_entered_hide_during_threat = true
			_time_exposed = 0.0
			_warning_time = 0.0
			var hud := get_tree().get_first_node_in_group("hud")
			if hud != null and hud.has_method("flash_message"):
				hud.flash_message("Stay still. It is checking %s." % _current_target_zone, 1.6)

		if flashlight_on:
			_hidden_flashlight_time += delta
			if _warning_time >= warning_interval:
				_warning_time = 0.0
				var hud_warn := get_tree().get_first_node_in_group("hud")
				if hud_warn != null and hud_warn.has_method("flash_message"):
					hud_warn.flash_message("The light is bleeding through the door.", 0.9)
				if level != null and level.has_method("closet_handle_fake"):
					await level.closet_handle_fake()
			if _hidden_flashlight_time >= hidden_flashlight_attack_time:
				_attack_player("The light gave your hiding place away.")
				return
		else:
			_hidden_flashlight_time = maxf(_hidden_flashlight_time - delta * 0.5, 0.0)

		_hidden_time += delta
		var required_hide_time: float = active_threat_duration / hide_penalty
		if _hidden_time >= required_hide_time:
			_resolve_active_threat()
			return
	else:
		_hidden_flashlight_time = 0.0
		_hidden_time = maxf(_hidden_time - delta * 0.25, 0.0)
		if _time_since_start >= grace_period_before_attack:
			_time_exposed += delta
			var allowed_exposure: float = (re_exposed_attack_time if _entered_hide_during_threat else exposed_attack_time)
			allowed_exposure *= hide_penalty
			if flashlight_on:
				allowed_exposure *= flashlight_exposure_multiplier
			_max_exposure_ratio = maxf(_max_exposure_ratio, clampf(_time_exposed / allowed_exposure, 0.0, 2.0))
			if _warning_time >= warning_interval:
				_warning_time = 0.0
				_emit_exposure_warning(player, flashlight_on)
			if _time_exposed >= allowed_exposure:
				var reason: String = "It found you before you could disappear." if not _entered_hide_during_threat else "You stepped out while it was still searching."
				if flashlight_on:
					reason = "Your flashlight gave you away."
				_attack_player(reason)
				return

	if _pulse_time >= pulse_interval:
		_pulse_time = 0.0
		_pressure_pulse(player)

func _start_active_threat(mode: String) -> void:
	_active_threat = true
	_hidden_time = 0.0
	_pulse_time = 0.0
	_pulse_index = 0
	_entered_hide_during_threat = false
	_time_since_start = 0.0
	_time_exposed = 0.0
	_warning_time = 0.0
	_max_exposure_ratio = 0.0
	_survival_grade = ""
	_hidden_flashlight_time = 0.0

	var state := get_tree().get_first_node_in_group("game_state")
	var memory := get_tree().get_first_node_in_group("house_memory")
	if memory != null and memory.has_method("get_recommended_hunt_zone"):
		_current_target_zone = memory.get_recommended_hunt_zone()
	else:
		_current_target_zone = "hall"

	if state != null:
		if state.has_method("set_threat_state"):
			state.set_threat_state("active")
		if state.has_method("set_objective_deceptive"):
			var truth := "Hide until the house stops searching." if mode == "initial" else "Hide again. It learned your route."
			var lie: String = truth
			if memory != null and memory.has_method("get_objective_deception"):
				lie = memory.get_objective_deception(truth)
			state.set_objective_deceptive(truth, lie)
		elif state.has_method("set_objective"):
			if mode == "initial":
				state.set_objective("Hide until the house stops searching.")
			else:
				state.set_objective("Hide again. It learned your route.")

	var level := get_tree().get_first_node_in_group("test_level")
	if level != null and level.has_method("pre_hunt_presence") and not _pre_hunt_played:
		_pre_hunt_played = true
		await level.pre_hunt_presence()

	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("flash_message"):
		if mode == "initial":
			hud.flash_message("It heard the key. Hide now.", 1.9)
		else:
			hud.flash_message("It comes back for %s." % _current_target_zone, 2.0)

	if level != null:
		if level.has_method("start_targeted_hunt_sequence"):
			await level.start_targeted_hunt_sequence(_current_target_zone, _repeat_hunts_started)
		elif level.has_method("start_hunt_sequence"):
			await level.start_hunt_sequence()

	var tension := get_tree().get_first_node_in_group("tension_manager")
	if tension != null and tension.has_method("add_tension"):
		tension.add_tension(10 if mode == "initial" else 8, "threat_started_%s" % mode)

func _emit_exposure_warning(player: Node, flashlight_on: bool) -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	var moving_fast: bool = false
	if player != null and "velocity" in player:
		var v: Vector3 = player.velocity
		moving_fast = Vector2(v.x, v.z).length() > movement_speed_threshold

	if hud != null and hud.has_method("flash_message"):
		if _entered_hide_during_threat:
			hud.flash_message("Too early. Get back into cover.", 0.9)
		elif flashlight_on:
			hud.flash_message("The beam cuts through the dark. It sees it.", 0.95)
		elif moving_fast:
			hud.flash_message("It is closing on your footsteps.", 0.9)
		elif _max_exposure_ratio > 0.7:
			hud.flash_message("It is almost at %s." % _current_target_zone, 0.9)
		else:
			hud.flash_message("It is almost on top of you.", 0.9)

	var tension := get_tree().get_first_node_in_group("tension_manager")
	if tension != null and tension.has_method("add_tension"):
		tension.add_tension(2, "threat_warning")

func _pressure_pulse(player: Node) -> void:
	var level := get_tree().get_first_node_in_group("test_level")
	var player_zone: String = "unknown"
	if level != null and level.has_method("get_zone_name_for_position") and player is Node3D:
		player_zone = level.get_zone_name_for_position(player.global_position)

	if level != null and level.has_method("hunt_pulse"):
		await level.hunt_pulse(_pulse_index, _current_target_zone if _current_target_zone != "" else player_zone)
	elif level != null and level.has_method("presence_glimpse"):
		await level.presence_glimpse()

	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("flash_message"):
		match _pulse_index % 5:
			0:
				hud.flash_message("A slow step drags through %s." % _current_target_zone, 1.0)
			1:
				hud.flash_message("Do not move yet.", 0.9)
			2:
				hud.flash_message("It stops outside the room you trust.", 1.0)
			3:
				hud.flash_message("The handle twitches once.", 1.0)
			_:
				hud.flash_message("It is still close.", 1.0)

	var tension := get_tree().get_first_node_in_group("tension_manager")
	if tension != null and tension.has_method("add_tension"):
		tension.add_tension(3, "threat_pulse")

	_pulse_index += 1

func _attack_player(reason: String) -> void:
	if not _active_threat:
		return
	_active_threat = false

	var level := get_tree().get_first_node_in_group("test_level")
	if level != null and level.has_method("attack_sequence"):
		await level.attack_sequence()
	elif level != null and level.has_method("blackout_pulse"):
		await level.blackout_pulse()

	var state := get_tree().get_first_node_in_group("game_state")
	if state != null and state.has_method("fail_game"):
		state.fail_game(reason)

func _resolve_active_threat() -> void:
	_active_threat = false
	_survival_grade = _calculate_survival_grade()

	var state := get_tree().get_first_node_in_group("game_state")
	var level := get_tree().get_first_node_in_group("test_level")
	var memory := get_tree().get_first_node_in_group("house_memory")
	if state != null:
		if state.has_method("set_threat_state"):
			state.set_threat_state("warning")
		if state.has_method("set_objective_deceptive"):
			var truth := "Get to the exit before it circles back."
			var lie: String = truth
			if memory != null and memory.has_method("get_objective_deception"):
				lie = memory.get_objective_deception(truth)
			state.set_objective_deceptive(truth, lie)
		elif state.has_method("set_objective"):
			state.set_objective("Get to the exit before it circles back.")
		if state.has_method("set_presence_result"):
			state.set_presence_result(_survival_grade)

	if level != null:
		if level.has_method("clear_hunt_sequence"):
			await level.clear_hunt_sequence()
		if level.has_method("post_hunt_payoff"):
			await level.post_hunt_payoff(_survival_grade)

	var should_mark: bool = _survival_grade == "barely"
	if memory != null and memory.has_method("get_hide_use_count") and memory.get_hide_use_count("linen_closet") >= 2:
		should_mark = true
	if should_mark:
		if memory != null and memory.has_method("mark_player"):
			memory.mark_player("The house marked the place you trusted.", 24.0)
		if state != null:
			if state.has_method("set_objective_deceptive") and memory != null and memory.has_method("get_objective_deception"):
				var truth := "Move. It learned your hiding place."
				var lie: String = memory.get_objective_deception(truth)
				state.set_objective_deceptive(truth, lie)
			elif state.has_method("set_objective"):
				state.set_objective("Move. It learned your hiding place.")

	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("flash_message"):
		match _survival_grade:
			"clean":
				hud.flash_message("It drifts deeper into the house. Move now.", 2.3)
			"shaken":
				hud.flash_message("It nearly saw you. Leave before it circles back.", 2.4)
			_:
				hud.flash_message("It was right outside. Run for the exit.", 2.4)
		if hud.has_method("set_presence_state"):
			var label: String = "Faded" if _survival_grade == "clean" else ("Near" if _survival_grade == "shaken" else "Marked")
			hud.set_presence_state("Presence %s" % label)

	var tension := get_tree().get_first_node_in_group("tension_manager")
	if tension != null and tension.has_method("add_tension"):
		tension.add_tension(6, "threat_resolved_%s" % _survival_grade)

	_reset_repeat_timer()
	await get_tree().create_timer(3.0).timeout
	if state != null and state.has_method("set_threat_state") and state.get_threat_state() == "warning":
		state.set_threat_state("calm")

func _calculate_survival_grade() -> String:
	if not _entered_hide_during_threat:
		return "barely"
	if _max_exposure_ratio >= 0.8:
		return "barely"
	if _max_exposure_ratio >= 0.35:
		return "shaken"
	return "clean"

func _reset_repeat_timer() -> void:
	_repeat_hunt_timer = randf_range(repeat_hunt_min_delay, repeat_hunt_max_delay)
