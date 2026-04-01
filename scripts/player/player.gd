extends CharacterBody3D

@export var move_speed: float = 4.5
@export var sprint_speed: float = 7.0
@export var acceleration: float = 18.0
@export var air_control: float = 3.0
@export var jump_velocity: float = 4.5
@export var mouse_sensitivity: float = 0.0025
@export var gravity_multiplier: float = 1.0
@export var flashlight_starts_on: bool = true

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var interaction_ray: RayCast3D = $Head/InteractionRay
@onready var flashlight: SpotLight3D = $Head/Flashlight

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _hint_shown := false
var _hidden := false
var _active_hide_spot: Node = null
var _room_sample_timer: float = 0.0
var _footstep_timer: float = 0.0
var _current_room: String = "foyer"
var _last_flashlight_state: bool = false

func _ready() -> void:
	add_to_group("player")
	if is_instance_valid(flashlight):
		flashlight.visible = flashlight_starts_on
		_last_flashlight_state = flashlight.visible
	_capture_mouse()
	call_deferred("_show_start_hint")

func _process(delta: float) -> void:
	_update_interaction_prompt()
	_report_room_and_behavior(delta)

func _unhandled_input(event: InputEvent) -> void:
	if _is_note_open():
		if event.is_action_pressed("pause") or event.is_action_pressed("interact"):
			var hud := _get_hud()
			if hud != null and hud.has_method("hide_note"):
				hud.hide_note()
			return

	if _is_end_screen_open():
		if event.is_action_pressed("pause"):
			get_tree().quit()
		return

	if _is_fail_screen_open():
		if event.is_action_pressed("pause"):
			get_tree().quit()
		elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
			var state := get_tree().get_first_node_in_group("game_state")
			if state != null and state.has_method("restart_game"):
				state.restart_game()
		return

	if _hidden:
		if event.is_action_pressed("interact") and _active_hide_spot != null and _active_hide_spot.has_method("leave_hide"):
			_active_hide_spot.leave_hide(self)
			return

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80.0), deg_to_rad(80.0))

	if event.is_action_pressed("pause"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			_capture_mouse()

	if event.is_action_pressed("flashlight") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and not _is_note_open():
		_toggle_flashlight()

	if event.is_action_pressed("interact") and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_try_interact()

func _physics_process(delta: float) -> void:
	if _is_end_screen_open() or _is_fail_screen_open():
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y -= gravity * gravity_multiplier * delta

	if _hidden:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)
		move_and_slide()
		return

	var input_dir := Vector2.ZERO
	if not _is_note_open() and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	var direction := (global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	var sprinting := Input.is_action_pressed("sprint")
	var target_speed := sprint_speed if sprinting else move_speed
	var control := acceleration if is_on_floor() else air_control
	var target_velocity := direction * target_speed

	velocity.x = move_toward(velocity.x, target_velocity.x, control * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, control * delta)

	if not _is_note_open() and Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		_record_noise(2.2, "jump")

	move_and_slide()
	_report_movement_noise(delta, sprinting)

func _capture_mouse() -> void:
	if not _is_note_open() and not _is_end_screen_open() and not _is_fail_screen_open():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _update_interaction_prompt() -> void:
	var hud := _get_hud()
	if hud == null or not hud.has_method("show_prompt"):
		return

	if _is_note_open() or _is_end_screen_open() or _is_fail_screen_open():
		hud.show_prompt("")
		return

	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		hud.show_prompt("")
		return

	if _hidden:
		hud.show_prompt("Press E to leave hiding spot")
		return

	var target := _get_interactable_target()
	if target != null and target.has_method("get_interaction_text"):
		hud.show_prompt(target.get_interaction_text())
	else:
		hud.show_prompt("")

func _try_interact() -> void:
	if _hidden:
		if _active_hide_spot != null and _active_hide_spot.has_method("leave_hide"):
			_active_hide_spot.leave_hide(self)
		return

	var target := _get_interactable_target()
	if target != null and target.has_method("interact"):
		target.interact(self)

func _get_interactable_target() -> Node:
	if not interaction_ray.is_colliding():
		return null

	var collider := interaction_ray.get_collider() as Node
	while collider != null:
		if collider.has_method("interact") or collider.has_method("get_interaction_text"):
			return collider
		collider = collider.get_parent()

	return null

func _toggle_flashlight() -> void:
	if not is_instance_valid(flashlight):
		return
	flashlight.visible = not flashlight.visible
	_record_noise(1.2, "flashlight")
	var hud := _get_hud()
	if hud != null and hud.has_method("flash_message"):
		hud.flash_message("Flashlight %s" % ("on" if flashlight.visible else "off"), 1.2)

func _show_start_hint() -> void:
	if _hint_shown:
		return
	_hint_shown = true
	var hud := _get_hud()
	if hud != null and hud.has_method("flash_message"):
		hud.flash_message("WASD move   Shift sprint   F flashlight   E interact", 3.0)

func enter_hide_spot(hide_spot: Node) -> void:
	_hidden = true
	_active_hide_spot = hide_spot
	velocity = Vector3.ZERO
	var state := get_tree().get_first_node_in_group("game_state")
	if state != null and state.has_method("set_hidden"):
		state.set_hidden(true)
	var hud := _get_hud()
	if hud != null and hud.has_method("flash_message"):
		hud.flash_message("You hold still and listen.", 1.0)

func exit_hide_spot() -> void:
	_hidden = false
	_active_hide_spot = null
	var state := get_tree().get_first_node_in_group("game_state")
	if state != null and state.has_method("set_hidden"):
		state.set_hidden(false)

func _get_hud() -> Node:
	return get_tree().get_first_node_in_group("hud")

func _is_note_open() -> bool:
	var hud := _get_hud()
	return hud != null and hud.has_method("is_note_open") and hud.is_note_open()

func _is_end_screen_open() -> bool:
	var hud := _get_hud()
	return hud != null and hud.has_method("is_end_screen_open") and hud.is_end_screen_open()

func _is_fail_screen_open() -> bool:
	var hud := _get_hud()
	return hud != null and hud.has_method("is_fail_screen_open") and hud.is_fail_screen_open()

func is_flashlight_on() -> bool:
	return is_instance_valid(flashlight) and flashlight.visible

func get_current_room_name() -> String:
	return _current_room

func get_active_hide_spot_id() -> String:
	if _active_hide_spot != null and _active_hide_spot.has_method("get_spot_id"):
		return _active_hide_spot.get_spot_id()
	return ""

func _report_room_and_behavior(delta: float) -> void:
	var level := get_tree().get_first_node_in_group("test_level")
	var memory := get_tree().get_first_node_in_group("house_memory")
	if level == null or memory == null or not level.has_method("get_zone_name_for_position"):
		return

	_room_sample_timer += delta
	if _room_sample_timer < 0.25:
		if is_flashlight_on():
			_record_noise(delta * 0.2, "flashlight")
		return

	_room_sample_timer = 0.0
	_current_room = level.get_zone_name_for_position(global_position)
	if memory.has_method("set_current_room"):
		memory.set_current_room(_current_room)
	if memory.has_method("add_room_dwell"):
		memory.add_room_dwell(_current_room, 0.25)
	if is_flashlight_on():
		_record_noise(0.08, "flashlight")

func _report_movement_noise(delta: float, sprinting: bool) -> void:
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	if not is_on_floor() or horizontal_speed < 0.2:
		_footstep_timer = 0.0
		return

	var interval := 0.28 if sprinting else 0.45
	_footstep_timer += delta
	if _footstep_timer >= interval:
		_footstep_timer = 0.0
		_record_noise(1.6 if sprinting else 0.8, "sprint" if sprinting else "walk")

func _record_noise(amount: float, source: String) -> void:
	var memory := get_tree().get_first_node_in_group("house_memory")
	if memory != null and memory.has_method("record_noise"):
		memory.record_noise(amount, source)
