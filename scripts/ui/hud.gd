extends CanvasLayer

var prompt_label: Label
var message_label: Label
var tension_label: Label
var objective_label: Label
var inventory_label: Label
var power_label: Label
var threat_label: Label
var state_label: Label
var presence_label: Label
var archive_label: Label
var note_panel: PanelContainer
var note_title_label: Label
var note_body_label: Label
var note_hint_label: Label
var end_panel: PanelContainer
var end_label: Label
var fail_panel: PanelContainer
var fail_label: Label

func _ready() -> void:
	add_to_group("hud")
	layer = 1
	_build_crosshair()
	_build_top_left_stack()
	_build_prompt_label()
	_build_message_label()
	_build_note_panel()
	_build_end_panel()
	_build_fail_panel()
	show_prompt("")
	set_tension(0)
	set_objective("Objective: --")
	set_inventory("Inventory: empty")
	set_power_status("Power out")
	set_player_state("Exposed")
	set_threat_state("Threat Calm")
	set_presence_state("Presence Dormant")
	set_archive_status("Archive: empty")
	call_deferred("_sync_existing_state")

func _sync_existing_state() -> void:
	var state := get_tree().get_first_node_in_group("game_state")
	if state != null:
		set_objective("Objective: %s" % state.objective_text)
		if state.has_method("is_power_restored"):
			set_power_status("Power restored" if state.is_power_restored() else "Power out")
		if state.has_method("get_threat_state"):
			set_threat_state("Threat %s" % state.get_threat_state().capitalize())
		if state.has_method("is_hidden"):
			set_player_state("Hidden" if state.is_hidden() else "Exposed")
		var hunt_result := str(state.get("last_hunt_result"))
		var label := hunt_result.capitalize() if hunt_result != "none" else "Dormant"
		set_presence_state("Presence %s" % label)
		if state.has_method("has_item"):
			if state.inventory.is_empty():
				set_inventory("Inventory: empty")
			else:
				var names: Array[String] = []
				for value in state.inventory.values():
					names.append(str(value))
				names.sort()
				set_inventory("Inventory: %s" % ", ".join(names))

	var archive := get_tree().get_first_node_in_group("archive_log")
	if archive != null and archive.has_method("get_archive_status"):
		set_archive_status(archive.get_archive_status())

func show_prompt(text: String) -> void:
	var cleaned := text.strip_edges()
	prompt_label.text = cleaned
	prompt_label.visible = not cleaned.is_empty() and not is_note_open() and not is_end_screen_open() and not is_fail_screen_open()

func flash_message(text: String, duration: float = 2.5) -> void:
	if is_end_screen_open() or is_fail_screen_open():
		return
	message_label.text = text
	message_label.visible = true
	var shown_text := text
	await get_tree().create_timer(duration).timeout
	if message_label.text == shown_text:
		message_label.visible = false

func set_tension(value: int) -> void:
	tension_label.text = "Tension %02d" % value

func set_objective(text: String) -> void:
	objective_label.text = text if text.begins_with("Objective:") else "Objective: %s" % text

func set_inventory(text: String) -> void:
	inventory_label.text = text

func set_power_status(text: String) -> void:
	power_label.text = text

func set_player_state(text: String) -> void:
	state_label.text = text if text.begins_with("State:") else "State: %s" % text

func set_threat_state(text: String) -> void:
	threat_label.text = text if text.begins_with("Threat") else "Threat %s" % text

func set_presence_state(text: String) -> void:
	presence_label.text = text if text.begins_with("Presence") else "Presence %s" % text

func set_archive_status(text: String) -> void:
	archive_label.text = text if text.begins_with("Archive") else "Archive: %s" % text

func show_note(title: String, body: String) -> void:
	note_title_label.text = title
	note_body_label.text = body
	note_panel.visible = true
	prompt_label.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide_note() -> void:
	note_panel.visible = false
	if not is_end_screen_open() and not is_fail_screen_open():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func is_note_open() -> bool:
	return note_panel.visible

func show_end_screen(text: String) -> void:
	end_label.text = "%s\n\nPress Esc to quit." % text
	end_panel.visible = true
	message_label.visible = false
	prompt_label.visible = false
	note_panel.visible = false
	fail_panel.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func is_end_screen_open() -> bool:
	return end_panel.visible

func show_fail_screen(text: String) -> void:
	fail_label.text = "%s\n\nPress R to restart or Esc to quit." % text
	fail_panel.visible = true
	message_label.visible = false
	prompt_label.visible = false
	note_panel.visible = false
	end_panel.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func is_fail_screen_open() -> bool:
	return fail_panel.visible

func _build_crosshair() -> void:
	var center := CenterContainer.new()
	center.name = "CrosshairContainer"
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var crosshair := Label.new()
	crosshair.name = "Crosshair"
	crosshair.text = "+"
	crosshair.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crosshair.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	crosshair.add_theme_font_size_override("font_size", 28)
	center.add_child(crosshair)

func _build_top_left_stack() -> void:
	var panel := PanelContainer.new()
	panel.name = "InfoPanel"
	panel.anchor_left = 0.0
	panel.anchor_right = 0.0
	panel.anchor_top = 0.0
	panel.anchor_bottom = 0.0
	panel.offset_left = 16
	panel.offset_top = 16
	panel.offset_right = 350
	panel.offset_bottom = 208
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 4)
	margin.add_child(stack)

	objective_label = Label.new()
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_label.add_theme_font_size_override("font_size", 16)
	stack.add_child(objective_label)

	inventory_label = Label.new()
	inventory_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	inventory_label.add_theme_font_size_override("font_size", 15)
	stack.add_child(inventory_label)

	power_label = Label.new()
	power_label.add_theme_font_size_override("font_size", 15)
	stack.add_child(power_label)

	state_label = Label.new()
	state_label.add_theme_font_size_override("font_size", 15)
	stack.add_child(state_label)

	threat_label = Label.new()
	threat_label.add_theme_font_size_override("font_size", 15)
	stack.add_child(threat_label)

	presence_label = Label.new()
	presence_label.add_theme_font_size_override("font_size", 15)
	stack.add_child(presence_label)

	archive_label = Label.new()
	archive_label.add_theme_font_size_override("font_size", 15)
	stack.add_child(archive_label)

	tension_label = Label.new()
	tension_label.add_theme_font_size_override("font_size", 16)
	stack.add_child(tension_label)

func _build_prompt_label() -> void:
	prompt_label = Label.new()
	prompt_label.name = "PromptLabel"
	prompt_label.anchor_left = 0.5
	prompt_label.anchor_right = 0.5
	prompt_label.anchor_top = 1.0
	prompt_label.anchor_bottom = 1.0
	prompt_label.offset_left = -280
	prompt_label.offset_right = 280
	prompt_label.offset_top = -86
	prompt_label.offset_bottom = -42
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prompt_label.add_theme_font_size_override("font_size", 18)
	add_child(prompt_label)

func _build_message_label() -> void:
	message_label = Label.new()
	message_label.name = "MessageLabel"
	message_label.anchor_left = 0.5
	message_label.anchor_right = 0.5
	message_label.anchor_top = 0.0
	message_label.anchor_bottom = 0.0
	message_label.offset_left = -320
	message_label.offset_right = 320
	message_label.offset_top = 28
	message_label.offset_bottom = 76
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 22)
	message_label.visible = false
	add_child(message_label)

func _build_note_panel() -> void:
	note_panel = PanelContainer.new()
	note_panel.name = "NotePanel"
	note_panel.anchor_left = 0.5
	note_panel.anchor_right = 0.5
	note_panel.anchor_top = 0.5
	note_panel.anchor_bottom = 0.5
	note_panel.offset_left = -300
	note_panel.offset_right = 300
	note_panel.offset_top = -180
	note_panel.offset_bottom = 180
	note_panel.visible = false
	add_child(note_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_bottom", 18)
	note_panel.add_child(margin)

	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 12)
	margin.add_child(stack)

	note_title_label = Label.new()
	note_title_label.add_theme_font_size_override("font_size", 24)
	stack.add_child(note_title_label)

	note_body_label = Label.new()
	note_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note_body_label.add_theme_font_size_override("font_size", 18)
	note_body_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(note_body_label)

	note_hint_label = Label.new()
	note_hint_label.text = "Press E or Esc to close"
	note_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	note_hint_label.add_theme_font_size_override("font_size", 16)
	stack.add_child(note_hint_label)

func _build_end_panel() -> void:
	end_panel = PanelContainer.new()
	end_panel.name = "EndPanel"
	end_panel.anchor_left = 0.5
	end_panel.anchor_right = 0.5
	end_panel.anchor_top = 0.5
	end_panel.anchor_bottom = 0.5
	end_panel.offset_left = -260
	end_panel.offset_right = 260
	end_panel.offset_top = -120
	end_panel.offset_bottom = 120
	end_panel.visible = false
	add_child(end_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	end_panel.add_child(margin)

	end_label = Label.new()
	end_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	end_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	end_label.add_theme_font_size_override("font_size", 22)
	end_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	end_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(end_label)

func _build_fail_panel() -> void:
	fail_panel = PanelContainer.new()
	fail_panel.name = "FailPanel"
	fail_panel.anchor_left = 0.5
	fail_panel.anchor_right = 0.5
	fail_panel.anchor_top = 0.5
	fail_panel.anchor_bottom = 0.5
	fail_panel.offset_left = -290
	fail_panel.offset_right = 290
	fail_panel.offset_top = -130
	fail_panel.offset_bottom = 130
	fail_panel.visible = false
	add_child(fail_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	fail_panel.add_child(margin)

	fail_label = Label.new()
	fail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	fail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	fail_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fail_label.add_theme_font_size_override("font_size", 22)
	fail_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fail_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(fail_label)
