@tool
class_name TwitchLogDock
extends VBoxContainer
## Editor panel to watch Twitcher's logs and to switch the contexts on and off.
##
## Left: one row per context. The mode (off, info, debug) decides whether the
## component logs at all and is stored in the project settings, see
## [TwitchLogContexts]. The check box only hides the context in this panel.
## Right: the records, filtered by level, hidden contexts and a text query, see
## [LogfamiRecordFilter]. Records of the editor and of a game started from it
## ([TwitchLogDebuggerLink]) are merged by time; the source selector shows
## one of them only. Modes picked here reach the running game as well.
##
## The panel only collects the editor's records while it is part of the scene
## tree.

const LEVELS: Dictionary[String, int] = {
	"Debug": LogfamiLevel.Severity.DEBUG,
	"Info": LogfamiLevel.Severity.INFO,
	"Warn": LogfamiLevel.Severity.WARN,
	"Error": LogfamiLevel.Severity.ERROR,
}
const SOURCE_ALL: String = "All"
const SOURCE_EDITOR: String = "Editor"
const SOURCE_GAME: String = "Game"
const SOURCES: Array[String] = [SOURCE_ALL, SOURCE_EDITOR, SOURCE_GAME]
const EDITOR_TAG: String = "[color=gray]E[/color] "
const GAME_TAG: String = "[color=gray]G[/color] "
const CONTEXT_PANEL_WIDTH: int = 260
const SEARCH_PLACEHOLDER: String = "Filter: words, -excluded"
## Seconds between looking for new contexts and for modes changed elsewhere.
const SYNC_INTERVAL: float = 0.5

var feed: TwitchLogFeed = TwitchLogFeed.new()
var filter: LogfamiRecordFilter = LogfamiRecordFilter.new()
## Records of the running game, filled by [member debugger].
var game_buffer: LogfamiRecordBuffer = LogfamiRecordBuffer.new()
## The link to the running game; without one only the editor's records show.
var debugger: TwitchLogDebuggerLink

var _formatter: TwitchConsoleLogHandler = TwitchConsoleLogHandler.new()
var _rows: Dictionary[String, TwitchLogContextRow] = {}
var _source: String = SOURCE_ALL
var _last_version: int = -1
var _is_dirty: bool = true
var _since_sync: float = 0.0

var _level_select: OptionButton
var _source_select: OptionButton
var _search: LineEdit
var _autoscroll: CheckBox
var _status: Label
var _output: RichTextLabel
var _context_list: VBoxContainer


func _init() -> void:
	name = "Twitcher Logs"
	_formatter.escape_markup = true
	filter.min_level = LogfamiLevel.Severity.INFO
	_build()


func _enter_tree() -> void:
	feed.start()


func _exit_tree() -> void:
	feed.stop()


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	_since_sync += delta
	if _since_sync >= SYNC_INTERVAL:
		_sync_contexts()
	_render_if_changed()


## Looks for new contexts and redraws the records when something changed since
## the last call. Runs by itself while the panel is visible.
func refresh() -> void:
	_sync_contexts()
	_render_if_changed()
	_last_version = feed.buffer.version
	_is_dirty = false
	_render_records()


## The context row of [param context], null when it has none.
func get_row(context: String) -> TwitchLogContextRow:
	return _rows.get(context)


func get_context_names() -> PackedStringArray:
	var names: PackedStringArray = PackedStringArray(_rows.keys())
	names.sort()
	return names


## Number of lines the output shows.
func get_line_count() -> int:
	return _output.get_parsed_text().split("\n", false).size()


## Hides or shows the records of [param context]; the check box follows.
func set_context_visible(context: String, is_shown: bool) -> void:
	filter.set_muted(context, not is_shown)
	var row: TwitchLogContextRow = get_row(context)
	if row != null:
		row.set_shown(is_shown)
	_is_dirty = true


func set_min_level(level: int) -> void:
	filter.min_level = level
	_level_select.select(LEVELS.values().find(level))
	_is_dirty = true


func set_query(text: String) -> void:
	filter.query = text
	_search.text = text
	_is_dirty = true


## Sets the mode of every known context, see [method TwitchLogContexts.set_mode].
func set_all_modes(mode: String) -> void:
	for context: String in _all_contexts():
		_apply_mode(context, mode)
	_sync_contexts()


## Chooses which records show: [constant SOURCE_ALL], [constant SOURCE_EDITOR]
## or [constant SOURCE_GAME].
func set_source(source: String) -> void:
	var index: int = SOURCES.find(source)
	if index < 0:
		return
	_source = source
	_source_select.select(index)
	_is_dirty = true


func clear() -> void:
	feed.buffer.clear()
	game_buffer.clear()
	_is_dirty = true


func _build() -> void:
	add_child(_build_toolbar())
	var split: HSplitContainer = HSplitContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	split.add_child(_build_context_panel())
	split.add_child(_build_output())
	add_child(split)


func _build_toolbar() -> HBoxContainer:
	var toolbar: HBoxContainer = HBoxContainer.new()
	_source_select = OptionButton.new()
	for source: String in SOURCES:
		_source_select.add_item(source)
	_source_select.tooltip_text = "Records of the editor, of the running game, or both"
	_source_select.item_selected.connect(_on_source_selected)
	toolbar.add_child(_source_select)

	_level_select = OptionButton.new()
	for label: String in LEVELS:
		_level_select.add_item(label)
	_level_select.select(LEVELS.values().find(filter.min_level))
	_level_select.tooltip_text = "Lowest level shown"
	_level_select.item_selected.connect(_on_level_selected)
	toolbar.add_child(_level_select)

	_search = LineEdit.new()
	_search.placeholder_text = SEARCH_PLACEHOLDER
	_search.clear_button_enabled = true
	_search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search.text_changed.connect(_on_query_changed)
	toolbar.add_child(_search)

	_autoscroll = CheckBox.new()
	_autoscroll.text = "Autoscroll"
	_autoscroll.button_pressed = true
	_autoscroll.toggled.connect(_on_autoscroll_toggled)
	toolbar.add_child(_autoscroll)

	toolbar.add_child(_build_button("Clear", clear))
	toolbar.add_child(_build_button("Open Folder", TwitchLogfamiBridge.open_log_folder))
	_status = Label.new()
	toolbar.add_child(_status)
	return toolbar


func _build_context_panel() -> VBoxContainer:
	var panel: VBoxContainer = VBoxContainer.new()
	panel.custom_minimum_size.x = CONTEXT_PANEL_WIDTH

	var bulk: HBoxContainer = HBoxContainer.new()
	bulk.add_child(_build_button("Show all", _show_all_contexts))
	bulk.add_child(_build_button("Hide all", _hide_all_contexts))
	bulk.add_child(_build_all_modes_menu())
	panel.add_child(bulk)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_context_list = VBoxContainer.new()
	_context_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_context_list)
	panel.add_child(scroll)
	return panel


func _build_all_modes_menu() -> MenuButton:
	var menu: MenuButton = MenuButton.new()
	menu.text = "Set all…"
	menu.tooltip_text = "Switch every context to the same mode"
	var popup: PopupMenu = menu.get_popup()
	for mode: String in TwitchLogContexts.MODES:
		popup.add_item(mode)
	popup.index_pressed.connect(_on_all_modes_selected)
	return menu


func _build_output() -> RichTextLabel:
	_output = RichTextLabel.new()
	_output.bbcode_enabled = true
	_output.selection_enabled = true
	_output.scroll_following = true
	_output.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return _output


func _build_button(text: String, action: Callable) -> Button:
	var button: Button = Button.new()
	button.text = text
	button.pressed.connect(action)
	return button


func _all_contexts() -> PackedStringArray:
	var seen: Dictionary[String, bool] = {}
	for context: String in TwitchLogContexts.known_contexts():
		seen[context] = true
	for context: String in feed.buffer.scopes():
		seen[context] = true
	for context: String in game_buffer.scopes():
		seen[context] = true
	var sorted: PackedStringArray = PackedStringArray(seen.keys())
	sorted.sort()
	return sorted


## Adds rows for new contexts and lets the mode selectors follow changes made
## elsewhere, e.g. in the Project Settings.
func _sync_contexts() -> void:
	_since_sync = 0.0
	for context: String in _all_contexts():
		var row: TwitchLogContextRow = _rows.get(context)
		if row == null:
			row = _add_row(context)
		row.set_mode(TwitchLogContexts.get_mode(context))


func _add_row(context: String) -> TwitchLogContextRow:
	var row: TwitchLogContextRow = TwitchLogContextRow.new(context)
	row.set_shown(not filter.is_muted(context))
	row.shown_changed.connect(_on_row_shown_changed)
	row.mode_changed.connect(_on_row_mode_changed)
	_rows[context] = row
	_context_list.add_child(row)
	_sort_rows()
	return row


func _sort_rows() -> void:
	var index: int = 0
	for context: String in get_context_names():
		_context_list.move_child(_rows[context], index)
		index += 1


func _render_if_changed() -> void:
	var version: int = feed.buffer.version + game_buffer.version
	if version == _last_version and not _is_dirty:
		return
	_last_version = version
	_is_dirty = false
	_render_records()


func _render_records() -> void:
	var game_records: Array[LogfamiRecord] = []
	var editor_records: Array[LogfamiRecord] = []
	var total: int = 0
	if _source != SOURCE_GAME:
		editor_records = feed.buffer.get_records(filter)
		total += feed.buffer.size()
	if _source != SOURCE_EDITOR:
		game_records = game_buffer.get_records(filter)
		total += game_buffer.size()
	var records: Array[LogfamiRecord] = LogfamiRecordBuffer.merge(editor_records, game_records)
	var game_set: Dictionary[LogfamiRecord, bool] = {}
	for record: LogfamiRecord in game_records:
		game_set[record] = true
	var lines: PackedStringArray = []
	for record: LogfamiRecord in records:
		var line: String = _formatter.format(record.to_dict())
		if _source == SOURCE_ALL:
			line = _origin_tag(game_set.has(record)) + line
		lines.append(line)
	var scroll_bar: VScrollBar = _output.get_v_scroll_bar()
	var scroll_value: float = scroll_bar.value
	_output.text = "\n".join(lines)
	if not _autoscroll.button_pressed:
		scroll_bar.value = scroll_value
	_status.text = "%d / %d" % [records.size(), total]
	if debugger != null and debugger.is_game_running():
		_status.text += " · game running"


func _origin_tag(is_game: bool) -> String:
	return GAME_TAG if is_game else EDITOR_TAG


## Switches the context here and in the running game.
func _apply_mode(context: String, mode: String) -> void:
	TwitchLogContexts.set_mode(context, mode)
	if debugger != null:
		debugger.send_mode(context, mode)


func _show_all_contexts() -> void:
	for context: String in get_context_names():
		set_context_visible(context, true)


func _hide_all_contexts() -> void:
	for context: String in get_context_names():
		set_context_visible(context, false)


func _on_all_modes_selected(index: int) -> void:
	set_all_modes(TwitchLogContexts.MODES[index])


func _on_row_shown_changed(context: String, is_shown: bool) -> void:
	filter.set_muted(context, not is_shown)
	_is_dirty = true


func _on_row_mode_changed(context: String, mode: String) -> void:
	_apply_mode(context, mode)


func _on_source_selected(index: int) -> void:
	set_source(SOURCES[index])


func _on_level_selected(index: int) -> void:
	filter.min_level = LEVELS.values()[index]
	_is_dirty = true


func _on_query_changed(text: String) -> void:
	filter.query = text
	_is_dirty = true


func _on_autoscroll_toggled(is_enabled: bool) -> void:
	_output.scroll_following = is_enabled
