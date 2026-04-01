extends StaticBody3D

@export var interaction_text_closed: String = "Press E to search the drawer"
@export var interaction_text_opened: String = "The drawer is open"
@export var reveal_message: String = "Something glints inside."
@export var first_search_tension: int = 7
@export var hidden_item_path: NodePath
@export var objective_after_open: String = "Take the house key."
@export var slide_distance: float = 0.26

@onready var drawer_mesh: Node3D = $DrawerMesh

var _opened := false
var _closed_z := 0.0

func _ready() -> void:
	if is_instance_valid(drawer_mesh):
		_closed_z = drawer_mesh.position.z

func get_interaction_text() -> String:
	return interaction_text_opened if _opened else interaction_text_closed

func interact(_player: Node) -> void:
	if _opened:
		var item := get_node_or_null(hidden_item_path) as Node3D
		if item != null and item.visible:
			var hud := get_tree().get_first_node_in_group("hud")
			if hud != null and hud.has_method("flash_message"):
				hud.flash_message("The drawer hangs open.", 1.3)
		return

	_opened = true
	if is_instance_valid(drawer_mesh):
		drawer_mesh.position.z = _closed_z + slide_distance

	var item := get_node_or_null(hidden_item_path) as Node3D
	if item != null:
		item.visible = true
		for child in item.get_children():
			if child is CollisionShape3D:
				child.disabled = false

	var memory := get_tree().get_first_node_in_group("house_memory")
	if memory != null:
		if memory.has_method("record_object_interest"):
			memory.record_object_interest(name, 1.2)
		if memory.has_method("record_phrase_bucket"):
			memory.record_phrase_bucket("access_focus", 0.8)

	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("flash_message"):
		hud.flash_message(reveal_message, 2.1)

	var tension := get_tree().get_first_node_in_group("tension_manager")
	if tension != null and tension.has_method("add_tension"):
		tension.add_tension(first_search_tension, "drawer_search")

	var state := get_tree().get_first_node_in_group("game_state")
	if state != null and state.has_method("set_objective") and not objective_after_open.is_empty():
		state.set_objective(objective_after_open)

	var level := get_tree().get_first_node_in_group("test_level")
	if level != null and level.has_method("drawer_event"):
		level.drawer_event()
