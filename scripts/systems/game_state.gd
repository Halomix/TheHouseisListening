extends Node

signal objective_changed(text: String)
signal inventory_changed(text: String)
signal item_added(item_id: String)
signal power_changed(powered: bool)
signal game_won()
signal game_over(reason: String)
signal hidden_changed(hidden: bool)
signal threat_state_changed(state_name: String)
signal marked_changed(marked: bool, reason: String)

@export var starting_objective: String = "Read the note."

var objective_text: String = ""
var inventory: Dictionary = {}
var power_restored: bool = false
var has_won: bool = false
var hidden: bool = false
var threat_state: String = "calm"
var has_failed: bool = false
var fail_reason: String = ""
var last_hunt_result: String = "none"
var player_marked: bool = false
var mark_reason: String = ""

func _ready() -> void:
	add_to_group("game_state")
	call_deferred("_initial_sync")
	call_deferred("_connect_house_memory")

func _initial_sync() -> void:
	set_objective(starting_objective)
	_sync_inventory_hud()
	_sync_power_hud()
	_sync_player_state_hud()
	_sync_threat_hud()
	_sync_presence_hud()

func _connect_house_memory() -> void:
	var memory := get_tree().get_first_node_in_group("house_memory")
	var callback := Callable(self, "_on_memory_marked")
	if memory != null and memory.has_signal("mark_state_changed") and not memory.is_connected("mark_state_changed", callback):
		memory.connect("mark_state_changed", callback)

func _on_memory_marked(marked: bool, reason: String) -> void:
	set_marked(marked, reason)

func set_objective(text: String) -> void:
	objective_text = text
	objective_changed.emit(objective_text)
	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("set_objective"):
		hud.set_objective(objective_text)

func add_item(item_id: String, display_name: String) -> void:
	inventory[item_id] = display_name
	inventory_changed.emit(_inventory_text())
	item_added.emit(item_id)
	_sync_inventory_hud()

func has_item(item_id: String) -> bool:
	return inventory.has(item_id)

func set_power_restored(value: bool) -> void:
	power_restored = value
	power_changed.emit(power_restored)
	_sync_power_hud()

func is_power_restored() -> bool:
	return power_restored

func set_hidden(value: bool) -> void:
	if hidden == value:
		return
	hidden = value
	hidden_changed.emit(hidden)
	_sync_player_state_hud()

func is_hidden() -> bool:
	return hidden

func set_marked(value: bool, reason: String = "") -> void:
	if player_marked == value and mark_reason == reason:
		return
	player_marked = value
	mark_reason = reason
	marked_changed.emit(player_marked, mark_reason)
	_sync_player_state_hud()
	if player_marked:
		var hud := get_tree().get_first_node_in_group("hud")
		if hud != null and hud.has_method("flash_message"):
			hud.flash_message(reason if not reason.is_empty() else "The house has marked you.", 2.2)

func is_marked() -> bool:
	return player_marked

func set_threat_state(value: String) -> void:
	var normalized := value.to_lower()
	if threat_state == normalized:
		return
	threat_state = normalized
	threat_state_changed.emit(threat_state)
	_sync_threat_hud()

func get_threat_state() -> String:
	return threat_state

func is_threat_active() -> bool:
	return threat_state == "active"

func set_presence_result(value: String) -> void:
	last_hunt_result = value.to_lower()
	_sync_presence_hud()

func is_fail_state() -> bool:
	return has_failed

func is_win_state() -> bool:
	return has_won

func fail_game(reason: String = "The house found you.") -> void:
	if has_failed or has_won:
		return
	has_failed = true
	fail_reason = reason
	set_threat_state("caught")
	game_over.emit(reason)
	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("show_fail_screen"):
		hud.show_fail_screen(reason)

func restart_game() -> void:
	get_tree().reload_current_scene()

func win_game() -> void:
	if has_won or has_failed:
		return
	has_won = true
	game_won.emit()
	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("show_end_screen"):
		hud.show_end_screen("You made it out.\nPrototype slice complete.")

func _inventory_text() -> String:
	if inventory.is_empty():
		return "Inventory: empty"

	var names: Array[String] = []
	for key in inventory.keys():
		names.append(str(inventory[key]))
	names.sort()
	return "Inventory: %s" % ", ".join(names)

func _sync_inventory_hud() -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("set_inventory"):
		hud.set_inventory(_inventory_text())

func _sync_power_hud() -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("set_power_status"):
		hud.set_power_status("Power restored" if power_restored else "Power out")

func _sync_player_state_hud() -> void:
	var parts: Array[String] = []
	parts.append("Hidden" if hidden else "Exposed")
	if player_marked:
		parts.append("Marked")
	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("set_player_state"):
		hud.set_player_state(" / ".join(parts))

func _sync_threat_hud() -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("set_threat_state"):
		var label := threat_state.capitalize()
		hud.set_threat_state("Threat %s" % label)

func _sync_presence_hud() -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("set_presence_state"):
		var label := last_hunt_result.capitalize() if last_hunt_result != "none" else "Dormant"
		hud.set_presence_state("Presence %s" % label)
