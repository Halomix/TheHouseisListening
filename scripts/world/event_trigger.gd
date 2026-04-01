extends Area3D

@export var message: String = ""
@export var message_duration: float = 2.2
@export var tension_amount: int = 0
@export var level_method: String = ""
@export var objective_text: String = ""
@export var fire_once: bool = true

var _fired := false

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    if not body.is_in_group("player"):
        return
    if fire_once and _fired:
        return
    _fired = true

    if not message.is_empty():
        var hud := get_tree().get_first_node_in_group("hud")
        if hud != null and hud.has_method("flash_message"):
            hud.flash_message(message, message_duration)

    if tension_amount != 0:
        var tension := get_tree().get_first_node_in_group("tension_manager")
        if tension != null and tension.has_method("add_tension"):
            tension.add_tension(tension_amount, "trigger_%s" % name.to_lower())

    if not objective_text.is_empty():
        var state := get_tree().get_first_node_in_group("game_state")
        if state != null and state.has_method("set_objective"):
            state.set_objective(objective_text)

    if not level_method.is_empty():
        var level := get_tree().get_first_node_in_group("test_level")
        if level != null and level.has_method(level_method):
            level.call(level_method)
