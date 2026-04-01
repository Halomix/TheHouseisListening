extends Area3D

func _ready() -> void:
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    if not body.is_in_group("player"):
        return

    var state := get_tree().get_first_node_in_group("game_state")
    if state != null and state.has_method("win_game"):
        state.win_game()
