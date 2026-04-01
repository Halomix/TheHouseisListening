extends Node

var _thresholds_fired: Dictionary = {}

func _ready() -> void:
    add_to_group("presence_director")
    call_deferred("_connect_tension")

func _connect_tension() -> void:
    var tension := get_tree().get_first_node_in_group("tension_manager")
    if tension != null and not tension.tension_changed.is_connected(_on_tension_changed):
        tension.tension_changed.connect(_on_tension_changed)

func _on_tension_changed(value: int) -> void:
    var level := get_tree().get_first_node_in_group("test_level")
    if level == null:
        return

    if value >= 25 and not _thresholds_fired.has("25"):
        _thresholds_fired["25"] = true
        if level.has_method("presence_glimpse"):
            level.presence_glimpse()

    if value >= 45 and not _thresholds_fired.has("45"):
        _thresholds_fired["45"] = true
        if level.has_method("blackout_pulse"):
            level.blackout_pulse()

    if value >= 70 and not _thresholds_fired.has("70"):
        _thresholds_fired["70"] = true
        if level.has_method("slam_sequence"):
            level.slam_sequence()
