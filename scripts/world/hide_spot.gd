extends Node3D

@export var interaction_text: String = "Press E to hide in the closet"
@export var exit_text: String = "Press E to leave hiding spot"
@export var hide_point_path: NodePath
@export var exit_point_path: NodePath
@export var hide_message: String = "You slip into the closet."
@export var exit_message: String = "You step back out."
@export var spot_id: String = ""

@onready var hide_point: Marker3D = get_node_or_null(hide_point_path)
@onready var exit_point: Marker3D = get_node_or_null(exit_point_path)

var _occupant: Node = null

func _ready() -> void:
	if spot_id.is_empty():
		spot_id = name.to_lower()

func get_spot_id() -> String:
	return spot_id

func get_interaction_text() -> String:
	if _occupant != null:
		return ""
	return interaction_text

func interact(player: Node) -> void:
	if _occupant != null:
		return
	_occupant = player

	if player is Node3D and hide_point != null:
		var body := player as Node3D
		body.global_position = hide_point.global_position
		body.global_rotation = hide_point.global_rotation

	if player.has_method("enter_hide_spot"):
		player.enter_hide_spot(self)

	var memory := get_tree().get_first_node_in_group("house_memory")
	if memory != null and memory.has_method("record_hide_used"):
		memory.record_hide_used(spot_id)

	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("flash_message") and not hide_message.is_empty():
		hud.flash_message(hide_message, 1.1)

func leave_hide(player: Node) -> void:
	if _occupant != player:
		return

	if player is Node3D and exit_point != null:
		var body := player as Node3D
		body.global_position = exit_point.global_position
		body.global_rotation = exit_point.global_rotation

	_occupant = null

	if player.has_method("exit_hide_spot"):
		player.exit_hide_spot()

	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("flash_message") and not exit_message.is_empty():
		hud.flash_message(exit_message, 0.9)
