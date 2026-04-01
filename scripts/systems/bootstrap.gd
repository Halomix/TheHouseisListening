extends Node

const ACTIONS := {
    "move_forward": KEY_W,
    "move_backward": KEY_S,
    "move_left": KEY_A,
    "move_right": KEY_D,
    "jump": KEY_SPACE,
    "interact": KEY_E,
    "pause": KEY_ESCAPE,
    "sprint": KEY_SHIFT,
    "flashlight": KEY_F
}

func _ready() -> void:
    for action in ACTIONS.keys():
        if not InputMap.has_action(action):
            InputMap.add_action(action)
        var event := _make_key_event(ACTIONS[action])
        if InputMap.action_has_event(action, event):
            continue
        InputMap.action_add_event(action, event)

func _make_key_event(keycode: Key) -> InputEventKey:
    var event := InputEventKey.new()
    event.keycode = keycode
    event.physical_keycode = keycode
    return event
