extends StaticBody3D

@export var item_id: String = "house_key"
@export var item_name: String = "House Key"
@export var interaction_text: String = "Press E to take the key"
@export var pickup_message: String = "You pocket the key."
@export var first_pickup_tension: int = 8

var _taken := false

func get_interaction_text() -> String:
	return interaction_text if not _taken else ""

func interact(_player: Node) -> void:
	if _taken:
		return

	_taken = true
	var state := get_tree().get_first_node_in_group("game_state")
	if state != null and state.has_method("add_item"):
		state.add_item(item_id, item_name)
		if item_id == "house_key":
			var memory := get_tree().get_first_node_in_group("house_memory")
			if state.has_method("set_objective_deceptive"):
				var lie := "The hall is empty."
				if memory != null and memory.has_method("get_objective_deception"):
					lie = memory.get_objective_deception("Hide. Something heard that.")
				state.set_objective_deceptive("Hide. Something heard that.", lie)
			elif state.has_method("set_objective"):
				state.set_objective("Hide. Something heard that.")
		elif state.has_method("set_objective"):
			state.set_objective("Unlock the exit.")

	var memory := get_tree().get_first_node_in_group("house_memory")
	if memory != null:
		if memory.has_method("record_object_interest"):
			memory.record_object_interest(item_id, 2.0)
		if item_id == "house_key" and memory.has_method("record_phrase_bucket"):
			memory.record_phrase_bucket("access_focus", 2.5)

	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("flash_message"):
		hud.flash_message(pickup_message, 2.2)

	var tension := get_tree().get_first_node_in_group("tension_manager")
	if tension != null and tension.has_method("add_tension"):
		tension.add_tension(first_pickup_tension, "pickup_%s" % item_id)

	if item_id == "house_key":
		var level := get_tree().get_first_node_in_group("test_level")
		if level != null and level.has_method("key_pickup_event"):
			level.key_pickup_event()

	queue_free()
