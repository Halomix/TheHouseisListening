extends Node

signal memory_changed()
signal obsession_changed(theme: String)
signal mark_state_changed(marked: bool, reason: String)

@export var noise_decay_per_second: float = 1.8
@export var mark_default_duration: float = 20.0

var room_visits: Dictionary = {}
var room_dwell: Dictionary = {}
var hide_usage: Dictionary = {}
var object_interest: Dictionary = {}
var phrase_buckets: Dictionary = {}
var safe_room_hits: Dictionary = {}
var player_noise: float = 0.0
var flashlight_seconds: float = 0.0
var current_room: String = "foyer"
var obsession_theme: String = "watching"
var player_marked: bool = false
var mark_reason: String = ""
var _mark_timer: float = 0.0

func _ready() -> void:
	add_to_group("house_memory")

func _process(delta: float) -> void:
	if player_noise > 0.0:
		player_noise = maxf(player_noise - noise_decay_per_second * delta, 0.0)
	if player_marked:
		_mark_timer -= delta
		if _mark_timer <= 0.0:
			clear_mark()

func set_current_room(room_name: String) -> void:
	var normalized := room_name.strip_edges().to_lower()
	if normalized.is_empty():
		normalized = "unknown"
	if normalized == current_room:
		return
	current_room = normalized
	record_room_visit(normalized)

func add_room_dwell(room_name: String, amount: float) -> void:
	var normalized := room_name.strip_edges().to_lower()
	if normalized.is_empty():
		normalized = current_room
	room_dwell[normalized] = float(room_dwell.get(normalized, 0.0)) + maxf(amount, 0.0)
	_emit_memory_changed()

func record_room_visit(room_name: String) -> void:
	var normalized := room_name.strip_edges().to_lower()
	if normalized.is_empty():
		normalized = current_room
	room_visits[normalized] = int(room_visits.get(normalized, 0)) + 1
	if normalized in ["linen", "bathroom", "bedroom", "kitchen", "hall"]:
		phrase_buckets["room_%s" % normalized] = float(phrase_buckets.get("room_%s" % normalized, 0.0)) + 0.4
	_update_obsession()
	_emit_memory_changed()

func record_hide_used(spot_id: String) -> void:
	var normalized := spot_id.strip_edges().to_lower()
	if normalized.is_empty():
		normalized = "unknown_hide"
	hide_usage[normalized] = int(hide_usage.get(normalized, 0)) + 1
	safe_room_hits[current_room] = int(safe_room_hits.get(current_room, 0)) + 1
	phrase_buckets["panic_focus"] = float(phrase_buckets.get("panic_focus", 0.0)) + 0.8
	_update_obsession()
	_emit_memory_changed()

func record_object_interest(object_id: String, weight: float = 1.0) -> void:
	var normalized := object_id.strip_edges().to_lower()
	if normalized.is_empty():
		normalized = "unknown_object"
	object_interest[normalized] = float(object_interest.get(normalized, 0.0)) + weight
	if normalized.find("key") != -1 or normalized.find("lock") != -1:
		phrase_buckets["access_focus"] = float(phrase_buckets.get("access_focus", 0.0)) + weight
	_update_obsession()
	_emit_memory_changed()

func record_noise(amount: float, source: String = "") -> void:
	player_noise = clampf(player_noise + maxf(amount, 0.0), 0.0, 100.0)
	if source == "flashlight":
		flashlight_seconds += amount
		phrase_buckets["light_focus"] = float(phrase_buckets.get("light_focus", 0.0)) + amount * 0.25
	if source == "sprint" or source == "jump":
		phrase_buckets["panic_focus"] = float(phrase_buckets.get("panic_focus", 0.0)) + amount * 0.4
	_emit_memory_changed()

func record_phrase_bucket(bucket: String, weight: float = 1.0) -> void:
	var normalized := bucket.strip_edges().to_lower()
	if normalized.is_empty():
		return
	phrase_buckets[normalized] = float(phrase_buckets.get(normalized, 0.0)) + weight
	_update_obsession()
	_emit_memory_changed()

func record_false_safety(room_name: String) -> void:
	var normalized := room_name.strip_edges().to_lower()
	if normalized.is_empty():
		normalized = current_room
	safe_room_hits[normalized] = int(safe_room_hits.get(normalized, 0)) + 2
	phrase_buckets["certainty_focus"] = float(phrase_buckets.get("certainty_focus", 0.0)) + 1.5
	_update_obsession()
	_emit_memory_changed()

func mark_player(reason: String, duration: float = -1.0) -> void:
	player_marked = true
	mark_reason = reason
	_mark_timer = duration if duration > 0.0 else mark_default_duration
	phrase_buckets["marked_focus"] = float(phrase_buckets.get("marked_focus", 0.0)) + 1.5
	mark_state_changed.emit(true, mark_reason)
	_emit_memory_changed()

func clear_mark() -> void:
	if not player_marked:
		return
	player_marked = false
	mark_reason = ""
	_mark_timer = 0.0
	mark_state_changed.emit(false, "")
	_emit_memory_changed()

func is_player_marked() -> bool:
	return player_marked

func get_mark_reason() -> String:
	return mark_reason

func get_hide_use_count(spot_id: String) -> int:
	return int(hide_usage.get(spot_id.strip_edges().to_lower(), 0))

func get_room_pressure(room_name: String) -> float:
	var normalized := room_name.strip_edges().to_lower()
	var visits := float(room_visits.get(normalized, 0)) * 0.6
	var dwell := float(room_dwell.get(normalized, 0.0)) * 0.12
	var safe_hits := float(safe_room_hits.get(normalized, 0)) * 1.4
	return visits + dwell + safe_hits

func get_dominant_room() -> String:
	var best_room := current_room
	var best_score := -INF
	var keys := {}
	for key in room_visits.keys():
		keys[key] = true
	for key in room_dwell.keys():
		keys[key] = true
	for key in safe_room_hits.keys():
		keys[key] = true
	for room in keys.keys():
		var score := get_room_pressure(str(room))
		if score > best_score:
			best_score = score
			best_room = str(room)
	return best_room

func get_safest_room() -> String:
	var best_room := current_room
	var best_score := -1
	for room in safe_room_hits.keys():
		var score := int(safe_room_hits.get(room, 0))
		if score > best_score:
			best_score = score
			best_room = str(room)
	return best_room

func get_most_used_hide() -> String:
	var best_hide := ""
	var best_count := -1
	for hide_id in hide_usage.keys():
		var count := int(hide_usage.get(hide_id, 0))
		if count > best_count:
			best_count = count
			best_hide = str(hide_id)
	return best_hide

func get_obsession_theme() -> String:
	return obsession_theme

func get_recommended_hunt_zone() -> String:
	if player_marked:
		return get_safest_room()
	if float(phrase_buckets.get("access_focus", 0.0)) >= 2.0:
		return "hall"
	var safest := get_safest_room()
	if safest != "":
		return safest
	return get_dominant_room()

func get_recap_lines() -> PackedStringArray:
	var lines: PackedStringArray = []
	lines.append("The house focused on %s." % get_dominant_room().capitalize())
	var hide_id := get_most_used_hide()
	if not hide_id.is_empty():
		lines.append("You trusted %s too often." % hide_id.replace("_", " "))
	if player_marked:
		lines.append("It marked you for moving like prey.")
	if float(phrase_buckets.get("panic_focus", 0.0)) >= 2.5:
		lines.append("Panic made it bolder.")
	if float(phrase_buckets.get("access_focus", 0.0)) >= 2.0:
		lines.append("Keys and exits became the obsession.")
	return lines

func _update_obsession() -> void:
	var next_theme := obsession_theme
	var dominant_room := get_dominant_room()
	var access_focus := float(phrase_buckets.get("access_focus", 0.0))
	var panic_focus := float(phrase_buckets.get("panic_focus", 0.0))
	var certainty_focus := float(phrase_buckets.get("certainty_focus", 0.0))
	if certainty_focus >= 1.5:
		next_theme = "certainty"
	elif access_focus >= 2.0:
		next_theme = "access"
	elif dominant_room == "linen":
		next_theme = "hiding"
	elif dominant_room == "bedroom":
		next_theme = "bedroom"
	elif dominant_room == "bathroom":
		next_theme = "bathroom"
	elif dominant_room == "kitchen":
		next_theme = "kitchen"
	elif panic_focus >= 2.0:
		next_theme = "panic"
	else:
		next_theme = "watching"
	if next_theme != obsession_theme:
		obsession_theme = next_theme
		obsession_changed.emit(obsession_theme)

func _emit_memory_changed() -> void:
	memory_changed.emit()
