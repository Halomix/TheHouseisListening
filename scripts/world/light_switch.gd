extends StaticBody3D

@export var target_light_path: NodePath
@export var interaction_text_on: String = "Press E to turn off the light"
@export var interaction_text_off: String = "Press E to turn on the light"
@export var trigger_house_reaction_on_first_use: bool = true
@export var first_use_tension: int = 12
@export var repeat_use_tension: int = 2

var target_light: Light3D
var has_been_used := false

func _ready() -> void:
    target_light = get_node_or_null(target_light_path) as Light3D

func get_interaction_text() -> String:
    if target_light != null and target_light.visible:
        return interaction_text_on
    return interaction_text_off

func interact(_player: Node) -> void:
    if target_light != null:
        target_light.visible = not target_light.visible

    var tension := get_tree().get_first_node_in_group("tension_manager")
    if tension != null and tension.has_method("add_tension"):
        if not has_been_used:
            tension.add_tension(first_use_tension, "switch_first_use")
        else:
            tension.add_tension(repeat_use_tension, "switch_repeat_use")

    var state := get_tree().get_first_node_in_group("game_state")
    if state != null and state.has_method("set_objective") and target_light != null and not target_light.visible:
        state.set_objective("Open the door.")

    if trigger_house_reaction_on_first_use and not has_been_used:
        has_been_used = true
        var level := get_tree().get_first_node_in_group("test_level")
        if level != null and level.has_method("trigger_house_reaction"):
            level.trigger_house_reaction()
