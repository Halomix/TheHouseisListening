extends StaticBody3D

@export var interaction_text: String = "Press E to read the note"
@export var note_title: String = "A note taped to the stand"
@export_multiline var note_body: String = "Do not turn your back on the door.\n\nIf the light goes out, listen before you move."
@export var first_read_tension: int = 18
@export var objective_after_read: String = "Turn off the room light."

var _has_been_read := false

func get_interaction_text() -> String:
    return interaction_text

func interact(_player: Node) -> void:
    var hud := get_tree().get_first_node_in_group("hud")
    if hud != null and hud.has_method("show_note"):
        hud.show_note(note_title, note_body)

    if not _has_been_read:
        _has_been_read = true
        var tension := get_tree().get_first_node_in_group("tension_manager")
        if tension != null and tension.has_method("add_tension"):
            tension.add_tension(first_read_tension, "note_read")
        var state := get_tree().get_first_node_in_group("game_state")
        if state != null and state.has_method("set_objective") and not objective_after_read.is_empty():
            state.set_objective(objective_after_read)
