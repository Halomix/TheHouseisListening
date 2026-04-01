extends Node3D

@onready var room_light: OmniLight3D = $RoomLight
@onready var corridor_light: OmniLight3D = $CorridorLight
@onready var bedroom_light: OmniLight3D = $BedroomLight
@onready var bathroom_light: OmniLight3D = $BathroomLight
@onready var kitchen_light: OmniLight3D = $KitchenLight
@onready var linen_light: OmniLight3D = $LinenLight
@onready var hall_flash: OmniLight3D = $HallwayFlash
@onready var door_hinge: Node3D = $DoorHinge
@onready var exit_hinge: Node3D = $ExitDoorHinge
@onready var shadow_figure: MeshInstance3D = $ShadowFigure
@onready var hall_marker: Marker3D = $GlimpsePoints/HallMarker
@onready var bedroom_marker: Marker3D = $GlimpsePoints/BedroomMarker
@onready var bathroom_marker: Marker3D = $GlimpsePoints/BathroomMarker
@onready var kitchen_marker: Marker3D = $GlimpsePoints/KitchenMarker
@onready var linen_marker: Marker3D = $GlimpsePoints/LinenMarker

var reaction_fired: bool = false
var minor_event_fired: bool = false
var major_event_fired: bool = false
var glimpse_playing: bool = false
var _presence_eyes_left: MeshInstance3D
var _presence_eyes_right: MeshInstance3D
var _step_player: AudioStreamPlayer3D
var _breath_player: AudioStreamPlayer3D
var _rattle_player: AudioStreamPlayer3D
var _stinger_player: AudioStreamPlayer3D
var _ambient_player: AudioStreamPlayer

func _ready() -> void:
	add_to_group("test_level")
	if is_instance_valid(shadow_figure):
		shadow_figure.visible = false
	if is_instance_valid(hall_flash):
		hall_flash.visible = false
	_setup_presence_visuals()
	_setup_presence_audio()

func trigger_house_reaction() -> void:
	if reaction_fired:
		return
	reaction_fired = true
	_flash_message("The house heard that.", 2.4)
	await get_tree().create_timer(0.35).timeout
	await _flicker_light(room_light)
	await presence_glimpse_at(hall_marker)

func minor_house_event() -> void:
	if minor_event_fired:
		return
	minor_event_fired = true
	if door_hinge != null and door_hinge.has_method("nudge_once"):
		door_hinge.nudge_once()
	await presence_glimpse_at(bathroom_marker)

func major_house_event() -> void:
	if major_event_fired:
		return
	major_event_fired = true
	await blackout_pulse()
	if door_hinge != null and door_hinge.has_method("force_close"):
		door_hinge.force_close()
	await presence_glimpse_at(kitchen_marker)

func bedroom_event() -> void:
	_flash_message("A shape slips past the bedroom door.", 2.5)
	await presence_glimpse_at(bedroom_marker)

func bathroom_event() -> void:
	_flash_message("Two taps answer from the bathroom sink.", 2.3)
	if bathroom_light != null and bathroom_light.visible:
		await _flicker_light(bathroom_light)

func drawer_event() -> void:
	_flash_message("The drawer cracks open louder than it should.", 2.4)
	if corridor_light != null and corridor_light.visible:
		await _flicker_light(corridor_light)
	await presence_glimpse_at(bathroom_marker)

func kitchen_event() -> void:
	_flash_message("Something waits near the back door.", 2.2)
	await presence_glimpse_at(kitchen_marker)

func linen_event() -> void:
	_flash_message("Fabric shifts inside the closet before you touch it.", 2.3)
	if linen_light != null and linen_light.visible:
		await _flicker_light(linen_light)
	await presence_glimpse_at(linen_marker)

func key_pickup_event() -> void:
	_flash_message("The key feels warm. Something moves closer to the exit.", 2.6)
	if kitchen_light != null and kitchen_light.visible:
		await _flicker_light(kitchen_light)
	await presence_glimpse_at(kitchen_marker)

func pre_hunt_presence() -> void:
	_flash_message("Something stands between you and the front hall.", 1.6)
	await get_tree().create_timer(0.12).timeout
	await _presence_slide([hall_marker, bathroom_marker], 0.14, true)
	if corridor_light != null and corridor_light.visible:
		await _flicker_light(corridor_light)
	await get_tree().create_timer(0.08).timeout
	await presence_glimpse_at(linen_marker, 0.18)

func start_hunt_sequence() -> void:
	if exit_hinge != null and exit_hinge.has_method("force_close"):
		exit_hinge.force_close()
	_flash_message("Something rushes the hall toward the exit.", 1.8)
	await blackout_pulse()
	await _presence_slide([hall_marker, kitchen_marker, linen_marker], 0.10, true)
	_play_breath_at(linen_marker.global_position)

func hunt_pulse(pulse_index: int, player_zone: String = "unknown") -> void:
	match pulse_index % 5:
		0:
			if corridor_light != null and corridor_light.visible:
				await _flicker_light(corridor_light)
			await _presence_slide([hall_marker, bedroom_marker], 0.12, false)
		1:
			if linen_light != null and linen_light.visible:
				await _flicker_light(linen_light)
			await _presence_slide([bedroom_marker, linen_marker], 0.11, true)
		2:
			if kitchen_light != null and kitchen_light.visible:
				await _flicker_light(kitchen_light)
			await _presence_slide([kitchen_marker, hall_marker], 0.12, false)
		3:
			await closet_handle_fake()
		_:
			if player_zone == "linen":
				await _presence_slide([hall_marker, linen_marker], 0.10, true)
			else:
				await blackout_pulse()

func clear_hunt_sequence() -> void:
	_flash_message("The steps drift toward the back of the house.", 2.0)
	await _presence_slide([linen_marker, kitchen_marker], 0.15, true)
	if corridor_light != null and corridor_light.visible:
		await _flicker_light(corridor_light)

func post_hunt_payoff(result: String) -> void:
	match result:
		"clean":
			_flash_message("You wait long enough to hear it recede.", 2.0)
			await get_tree().create_timer(0.14).timeout
			await _presence_slide([hall_marker, kitchen_marker], 0.16, true)
		"shaken":
			_flash_message("It lingers just long enough to make you doubt it left.", 2.2)
			await get_tree().create_timer(0.08).timeout
			await _presence_slide([linen_marker, hall_marker], 0.13, false)
			if linen_light != null and linen_light.visible:
				await _flicker_light(linen_light)
		_:
			_flash_message("It was right outside the door with you.", 2.3)
			await get_tree().create_timer(0.06).timeout
			await _presence_slide([linen_marker, hall_marker, linen_marker], 0.09, false)
			await closet_handle_fake()

func attack_sequence() -> void:
	if exit_hinge != null and exit_hinge.has_method("force_close"):
		exit_hinge.force_close()
	_flash_message("It is right there.", 0.8)
	_play_stinger_at(linen_marker.global_position)
	await blackout_pulse()
	await _presence_slide([hall_marker, linen_marker], 0.07, false)
	if is_instance_valid(hall_flash):
		hall_flash.global_position = linen_marker.global_position + Vector3(0, 0.9, 0)
		hall_flash.visible = true
	await get_tree().create_timer(0.20).timeout
	if is_instance_valid(hall_flash):
		hall_flash.visible = false

func closet_handle_fake() -> void:
	_flash_message("The closet handle gives once, then stops.", 0.9)
	_play_rattle_at(linen_marker.global_position)
	if linen_light != null and linen_light.visible:
		await _flicker_light(linen_light)
	await presence_glimpse_at(linen_marker, 0.14)

func presence_glimpse() -> void:
	await presence_glimpse_at(hall_marker)

func presence_glimpse_at(marker: Node3D, duration: float = 0.33) -> void:
	if glimpse_playing or not is_instance_valid(shadow_figure) or marker == null:
		return
	glimpse_playing = true
	_place_presence(marker.global_position)
	shadow_figure.visible = true
	_set_eyes_visible(true)
	_play_breath_at(marker.global_position)
	if is_instance_valid(hall_flash):
		hall_flash.global_position = marker.global_position + Vector3(0, 0.8, 0)
		hall_flash.visible = true
	await get_tree().create_timer(duration).timeout
	if is_instance_valid(hall_flash):
		hall_flash.visible = false
	shadow_figure.visible = false
	_set_eyes_visible(false)
	glimpse_playing = false

func blackout_pulse() -> void:
	for light in [room_light, corridor_light, bedroom_light, bathroom_light, kitchen_light, linen_light]:
		if light != null and light.visible:
			await _flicker_light(light)

func slam_sequence() -> void:
	if exit_hinge != null and exit_hinge.has_method("force_close"):
		exit_hinge.force_close()
	await blackout_pulse()
	await presence_glimpse_at(kitchen_marker)

func get_zone_name_for_position(pos: Vector3) -> String:
	if pos.z < -39.0:
		return "exit"
	if pos.z < -28.0:
		return "kitchen"
	if pos.x < -5.0 and pos.z < -12.0:
		return "bedroom"
	if pos.x > 4.0 and pos.z < -17.0:
		return "bathroom"
	if pos.x > 4.5 and pos.z < -12.0:
		return "linen"
	if pos.z < -11.0:
		return "hall"
	return "foyer"

func _flicker_light(light: Light3D) -> void:
	if light == null:
		return
	var final_visible: bool = light.visible
	for _i in range(4):
		light.visible = false
		await get_tree().create_timer(0.06).timeout
		light.visible = true
		await get_tree().create_timer(0.08).timeout
	light.visible = final_visible

func _flash_message(text: String, duration: float = 2.0) -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("flash_message"):
		hud.flash_message(text, duration)

func _setup_presence_visuals() -> void:
	if not is_instance_valid(shadow_figure):
		return
	shadow_figure.scale = Vector3(0.72, 1.58, 0.72)
	shadow_figure.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON

	var eye_mesh := SphereMesh.new()
	eye_mesh.radius = 0.045
	eye_mesh.height = 0.09

	var eye_material := StandardMaterial3D.new()
	eye_material.albedo_color = Color(0.15, 0.15, 0.15, 1.0)
	eye_material.emission_enabled = true
	eye_material.emission = Color(0.62, 0.68, 0.95, 1.0)
	eye_material.emission_energy_multiplier = 1.9
	eye_material.no_depth_test = true

	_presence_eyes_left = MeshInstance3D.new()
	_presence_eyes_left.mesh = eye_mesh
	_presence_eyes_left.material_override = eye_material
	_presence_eyes_left.position = Vector3(-0.09, 0.56, -0.19)
	shadow_figure.add_child(_presence_eyes_left)

	_presence_eyes_right = MeshInstance3D.new()
	_presence_eyes_right.mesh = eye_mesh
	_presence_eyes_right.material_override = eye_material
	_presence_eyes_right.position = Vector3(0.09, 0.56, -0.19)
	shadow_figure.add_child(_presence_eyes_right)

	_set_eyes_visible(false)

func _setup_presence_audio() -> void:
	_step_player = _make_audio_player("PresenceSteps", 8.0)
	_breath_player = _make_audio_player("PresenceBreath", 6.0)
	_rattle_player = _make_audio_player("ClosetRattle", 5.0)
	_stinger_player = _make_audio_player("PresenceStinger", 10.0)
	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.name = "AmbientWind"
	_ambient_player.volume_db = -18.0
	add_child(_ambient_player)

	_assign_stream(_step_player, "res://assets/audio/presence_step.wav")
	_assign_stream(_breath_player, "res://assets/audio/presence_breath.wav")
	_assign_stream(_rattle_player, "res://assets/audio/closet_rattle.wav")
	if ResourceLoader.exists("res://assets/audio/monster_growl_01.mp3"):
		_assign_stream(_stinger_player, "res://assets/audio/monster_growl_01.mp3")
	else:
		_assign_stream(_stinger_player, "res://assets/audio/presence_stinger.wav")
	if ResourceLoader.exists("res://assets/audio/ambient_wind_01.mp3"):
		_ambient_player.stream = load("res://assets/audio/ambient_wind_01.mp3")
		if _ambient_player.stream is AudioStreamMP3:
			(_ambient_player.stream as AudioStreamMP3).loop = true
		_ambient_player.play()

func _make_audio_player(node_name: String, max_distance: float) -> AudioStreamPlayer3D:
	var p := AudioStreamPlayer3D.new()
	p.name = node_name
	p.max_distance = max_distance
	p.unit_size = 1.0
	p.attenuation_filter_cutoff_hz = 7000.0
	p.volume_db = -6.0
	add_child(p)
	return p

func _assign_stream(player: AudioStreamPlayer3D, path: String) -> void:
	if player == null:
		return
	if ResourceLoader.exists(path):
		player.stream = load(path)

func _place_presence(pos: Vector3) -> void:
	if not is_instance_valid(shadow_figure):
		return
	shadow_figure.global_position = pos
	var player := get_tree().get_first_node_in_group("player")
	if player is Node3D:
		shadow_figure.look_at(player.global_position + Vector3(0, 1.0, 0), Vector3.UP)
		shadow_figure.rotation.x = 0.0
		shadow_figure.rotation.z = 0.0

func _set_eyes_visible(value: bool) -> void:
	if is_instance_valid(_presence_eyes_left):
		_presence_eyes_left.visible = value
	if is_instance_valid(_presence_eyes_right):
		_presence_eyes_right.visible = value

func _presence_slide(markers: Array, segment_time: float = 0.12, show_flash: bool = false) -> void:
	if not is_instance_valid(shadow_figure) or markers.size() == 0:
		return

	glimpse_playing = true
	shadow_figure.visible = true
	_set_eyes_visible(true)
	_place_presence((markers[0] as Node3D).global_position)

	for i in range(markers.size()):
		var marker := markers[i] as Node3D
		if marker == null:
			continue
		_place_presence(marker.global_position)
		_play_step_at(marker.global_position)
		if show_flash and is_instance_valid(hall_flash):
			hall_flash.global_position = marker.global_position + Vector3(0, 0.8, 0)
			hall_flash.visible = true
		await get_tree().create_timer(segment_time).timeout
		if show_flash and is_instance_valid(hall_flash):
			hall_flash.visible = false

	shadow_figure.visible = false
	_set_eyes_visible(false)
	glimpse_playing = false

func _play_step_at(pos: Vector3) -> void:
	if _step_player != null and _step_player.stream != null:
		_step_player.global_position = pos + Vector3(0, 0.2, 0)
		_step_player.pitch_scale = randf_range(0.92, 1.05)
		_step_player.play()

func _play_breath_at(pos: Vector3) -> void:
	if _breath_player != null and _breath_player.stream != null:
		_breath_player.global_position = pos + Vector3(0, 1.0, 0)
		_breath_player.pitch_scale = randf_range(0.92, 1.08)
		_breath_player.play()

func _play_rattle_at(pos: Vector3) -> void:
	if _rattle_player != null and _rattle_player.stream != null:
		_rattle_player.global_position = pos + Vector3(0, 1.0, 0)
		_rattle_player.pitch_scale = randf_range(0.95, 1.06)
		_rattle_player.play()

func _play_stinger_at(pos: Vector3) -> void:
	if _stinger_player != null and _stinger_player.stream != null:
		_stinger_player.global_position = pos + Vector3(0, 0.8, 0)
		_stinger_player.pitch_scale = 1.0
		_stinger_player.play()


func start_targeted_hunt_sequence(target_zone: String, repeat_index: int = 0) -> void:
	if exit_hinge != null and exit_hinge.has_method("force_close"):
		exit_hinge.force_close()
	_flash_message("Something rushes toward %s." % target_zone, 1.9)
	await blackout_pulse()
	var marker := _marker_for_room(target_zone)
	if marker == null:
		marker = hall_marker
	await _presence_slide([hall_marker, marker, linen_marker], 0.10 - minf(float(repeat_index) * 0.01, 0.02), true)
	_play_breath_at(marker.global_position)

func false_safe_room_event(room_name: String) -> void:
	var marker := _marker_for_room(room_name)
	var light := _light_for_room(room_name)
	_flash_message("The room you trusted answers back.", 2.1)
	if light != null and light.visible:
		await _flicker_light(light)
	await presence_glimpse_at(marker if marker != null else hall_marker, 0.2)

func framed_room_event(room_name: String) -> void:
	var marker := _marker_for_room(room_name)
	_flash_message("It leaves your trail where it wants it.", 2.0)
	await _presence_slide([marker if marker != null else hall_marker, hall_marker], 0.12, true)

func obsession_whisper_event(room_name: String) -> void:
	var marker := _marker_for_room(room_name)
	_flash_message("It keeps returning to %s." % room_name, 1.9)
	_play_breath_at((marker if marker != null else hall_marker).global_position)
	await presence_glimpse_at(marker if marker != null else hall_marker, 0.16)

func soft_room_shift(room_name: String) -> void:
	var marker := _marker_for_room(room_name)
	var light := _light_for_room(room_name)
	if light != null and light.visible:
		await _flicker_light(light)
	_flash_message("The house settles in %s, but wrong." % room_name, 1.6)
	await presence_glimpse_at(marker if marker != null else hall_marker, 0.12)

func _marker_for_room(room_name: String) -> Marker3D:
	match room_name:
		"bedroom":
			return bedroom_marker
		"bathroom":
			return bathroom_marker
		"kitchen":
			return kitchen_marker
		"linen":
			return linen_marker
		"hall":
			return hall_marker
		_:
			return hall_marker

func _light_for_room(room_name: String) -> OmniLight3D:
	match room_name:
		"bedroom":
			return bedroom_light
		"bathroom":
			return bathroom_light
		"kitchen":
			return kitchen_light
		"linen":
			return linen_light
		"hall":
			return corridor_light
		_:
			return room_light
