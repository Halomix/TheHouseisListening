extends Node

signal archive_changed(entry_count: int, latest_title: String, latest_summary: String)

var _entries: Array[Dictionary] = []

func _ready() -> void:
	add_to_group("archive_log")

func record_entry(title: String, body: String, category: String = "", source: String = "") -> void:
	var normalized_title := title.strip_edges()
	var normalized_body := body.strip_edges()
	if normalized_title.is_empty() and normalized_body.is_empty():
		return

	var entry := {
		"title": normalized_title if not normalized_title.is_empty() else "Recovered note",
		"body": normalized_body,
		"category": category.strip_edges(),
		"source": source.strip_edges(),
		"summary": _summarize(normalized_body),
	}
	_entries.append(entry)
	archive_changed.emit(_entries.size(), str(entry["title"]), str(entry["summary"]))
	_sync_hud()

func get_entry_count() -> int:
	return _entries.size()

func get_latest_title() -> String:
	if _entries.is_empty():
		return ""
	return str(_entries.back().get("title", ""))

func get_latest_summary() -> String:
	if _entries.is_empty():
		return ""
	return str(_entries.back().get("summary", ""))

func get_archive_status() -> String:
	if _entries.is_empty():
		return "Archive: empty"
	return "Archive: %02d recovered | %s" % [_entries.size(), get_latest_title()]

func get_recent_lines(limit: int = 3) -> PackedStringArray:
	var lines := PackedStringArray()
	if _entries.is_empty():
		return lines

	var start_index := maxi(_entries.size() - max(limit, 1), 0)
	for i in range(start_index, _entries.size()):
		var entry := _entries[i]
		var title := str(entry.get("title", "Recovered note"))
		var summary := str(entry.get("summary", ""))
		if summary.is_empty():
			summary = _summarize(str(entry.get("body", "")))
		lines.append("%s: %s" % [title, summary])
	return lines

func _summarize(body: String) -> String:
	var cleaned := body.replace("\n", " ").strip_edges()
	if cleaned.is_empty():
		return "No excerpt"
	if cleaned.length() <= 72:
		return cleaned
	return "%s..." % cleaned.substr(0, 69).strip_edges()

func _sync_hud() -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud != null and hud.has_method("set_archive_status"):
		hud.set_archive_status(get_archive_status())
