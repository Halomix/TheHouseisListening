extends StaticBody3D

@export var powered_lights: Array[NodePath] = []
@export var interaction_text_off: String = "Press E to restore power"
@export var interaction_text_on: String = "The breaker is already on"
@export var first_use_tension: int = 10
@export var objective_after_use: String = "Find the house key."

@onready var indicator_light: OmniLight3D = $IndicatorLight

var _used := false

func _ready() -> void:
    _apply_power(false)

func get_interaction_text() -> String:
    return interaction_text_on if _used else interaction_text_off

func interact(_player: Node) -> void:
    if _used:
        var hud := get_tree().get_first_node_in_group("hud")
        if hud != null and hud.has_method("flash_message"):
            hud.flash_message("The power is already back.", 1.6)
        return

    _used = true
    _apply_power(true)

    var state := get_tree().get_first_node_in_group("game_state")
    if state != null:
        if state.has_method("set_power_restored"):
            state.set_power_restored(true)
        if state.has_method("set_objective") and not objective_after_use.is_empty():
            state.set_objective(objective_after_use)

    var hud := get_tree().get_first_node_in_group("hud")
    if hud != null and hud.has_method("flash_message"):
        hud.flash_message("The hallway wakes up.", 2.2)

    var tension := get_tree().get_first_node_in_group("tension_manager")
    if tension != null and tension.has_method("add_tension"):
        tension.add_tension(first_use_tension, "breaker_restored")

func _apply_power(value: bool) -> void:
    for path in powered_lights:
        var light := get_node_or_null(path) as Light3D
        if light != null:
            light.visible = value

    if is_instance_valid(indicator_light):
        indicator_light.light_energy = 0.8 if value else 0.0
