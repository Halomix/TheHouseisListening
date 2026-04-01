extends Node

signal tension_changed(value: int)

@export var starting_tension: int = 0

var tension: int = 0
var _thresholds_fired := {}

func _ready() -> void:
    add_to_group("tension_manager")
    set_tension(starting_tension)

func add_tension(amount: int, source: String = "") -> void:
    set_tension(tension + amount, source)

func set_tension(value: int, source: String = "") -> void:
    var previous := tension
    tension = clampi(value, 0, 100)

    var hud := get_tree().get_first_node_in_group("hud")
    if hud != null and hud.has_method("set_tension"):
        hud.set_tension(tension)

    if previous != tension:
        tension_changed.emit(tension)
        _check_thresholds(source)

func get_tension() -> int:
    return tension

func _check_thresholds(_source: String) -> void:
    if tension >= 15 and not _thresholds_fired.has("15"):
        _thresholds_fired["15"] = true
        _flash("It noticed you.", 2.0)

    if tension >= 35 and not _thresholds_fired.has("35"):
        _thresholds_fired["35"] = true
        _flash("Something shifts deeper in the hall.", 2.8)
        var level := get_tree().get_first_node_in_group("test_level")
        if level != null and level.has_method("minor_house_event"):
            level.minor_house_event()

    if tension >= 60 and not _thresholds_fired.has("60"):
        _thresholds_fired["60"] = true
        _flash("The house tries to close around you.", 3.0)
        var level := get_tree().get_first_node_in_group("test_level")
        if level != null and level.has_method("major_house_event"):
            level.major_house_event()

func _flash(text: String, duration: float) -> void:
    var hud := get_tree().get_first_node_in_group("hud")
    if hud != null and hud.has_method("flash_message"):
        hud.flash_message(text, duration)
