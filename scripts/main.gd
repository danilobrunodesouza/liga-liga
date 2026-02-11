extends Control
# Liga-Liga (16:9) — PROMPT MESTRE v2 (1920x1080, SafeArea, fonte padrão, lousa)
# # consumir da url: https://www.bellazuanon.com.br/liga-liga/jogo1.json
@export var local_json_path: String = "res://data/ligaliga.json"

@onready var title_label: Label = $UI/SafeArea/Root/Top/Title
@onready var instructions_label: Label = $UI/SafeArea/Root/Top/Instructions
@onready var progress_label: Label = $UI/SafeArea/Root/Top/Progress

@onready var left_col: VBoxContainer = $UI/SafeArea/Root/Center/LeftColumn
@onready var right_col: VBoxContainer = $UI/SafeArea/Root/Center/RightColumn

@onready var restart_button: Button = $UI/SafeArea/Root/Bottom/RestartButton

var _game: MatchGame
var _selected_left: MatchOptionButton = null
var _selected_right: MatchOptionButton = null
var _locked: bool = false

func _ready() -> void:
	randomize()
	_setup_background()
	_setup_safe_area()
	_setup_game()
	_load_and_build()

func _setup_background() -> void:
	# A lousa 1920x1080 deve cobrir a tela mantendo proporção (sem distorção)
	var bg := $Background as TextureRect
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.texture = ChalkTheme.background_texture
	bg.expand = true
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _setup_safe_area() -> void:
	# Margens para manter o conteúdo dentro da área verde da lousa (fora da madeira)
	var safe := $UI/SafeArea as MarginContainer
	safe.add_theme_constant_override("margin_left", 240)
	safe.add_theme_constant_override("margin_right", 240)
	safe.add_theme_constant_override("margin_top", 80)
	safe.add_theme_constant_override("margin_bottom", 170)

func _setup_game() -> void:
	_game = MatchGame.new()
	add_child(_game)
	_game.progress_changed.connect(_on_progress_changed)
	_game.finished.connect(_on_finished)

func _load_and_build() -> void:
	var data := _load_json(local_json_path)
	if data.is_empty():
		_show_json_error("Não foi possível carregar o JSON.")
		return

	title_label.text = str(data.get("title", "Liga-Liga"))
	instructions_label.text = str(data.get("instructions", ""))

	var pairs_v: Variant = data.get("pairs", [])
	if typeof(pairs_v) != TYPE_ARRAY:
		_show_json_error("JSON inválido: 'pairs' deve ser Array.")
		return

	var pairs: Array = pairs_v as Array
	_game.load_pairs(pairs)
	_build_columns(pairs)

	restart_button.visible = false
	ChalkTheme.apply_tree($UI)

func _build_columns(pairs: Array) -> void:
	_clear_columns()
	_selected_left = null
	_selected_right = null
	_locked = false

	var left_texts: Array[String] = []
	var right_texts: Array[String] = []
	for pv in pairs:
		if typeof(pv) != TYPE_DICTIONARY:
			continue
		var p: Dictionary = pv as Dictionary
		left_texts.append(str(p.get("left", "")))
		right_texts.append(str(p.get("right", "")))

	left_texts.shuffle()
	right_texts.shuffle()

	for t in left_texts:
		_add_option(left_col, "left", t)
	for t in right_texts:
		_add_option(right_col, "right", t)

func _add_option(parent_box: VBoxContainer, side: String, text_value: String) -> void:
	var key := MatchGame._normalize(text_value)
	var b := MatchOptionButton.new()
	b.setup(side, text_value, key)
	b.picked.connect(_on_option_picked)
	parent_box.add_child(b)

func _on_option_picked(btn: MatchOptionButton) -> void:
	if _locked or btn.is_solved():
		return

	if btn.side == "left":
		_select_left(btn)
	else:
		_select_right(btn)

	if _selected_left != null and _selected_right != null:
		await _validate_pair()

func _select_left(btn: MatchOptionButton) -> void:
	if _selected_left != null and _selected_left != btn:
		_selected_left.reset_visual()
	_selected_left = btn
	_selected_left.set_selected_visual()

func _select_right(btn: MatchOptionButton) -> void:
	if _selected_right != null and _selected_right != btn:
		_selected_right.reset_visual()
	_selected_right = btn
	_selected_right.set_selected_visual()

func _validate_pair() -> void:
	_locked = true

	var left_key := _selected_left.key
	var right_key := _selected_right.key

	if _game.is_match(left_key, right_key):
		_selected_left.flash_feedback(ChalkTheme.OK_GREEN)
		_selected_right.flash_feedback(ChalkTheme.OK_GREEN)
		await get_tree().create_timer(1.0).timeout

		_selected_left.lock_as_solved()
		_selected_right.lock_as_solved()
		_selected_left.reset_visual()
		_selected_right.reset_visual()

		_game.mark_pair_solved()
	else:
		_selected_left.flash_feedback(ChalkTheme.BAD_RED)
		_selected_right.flash_feedback(ChalkTheme.BAD_RED)
		await get_tree().create_timer(1.0).timeout

		_selected_left.reset_visual()
		_selected_right.reset_visual()

	_selected_left = null
	_selected_right = null
	_locked = false

func _on_progress_changed(solved: int, total: int) -> void:
	progress_label.text = "PARES: %d / %d" % [solved, total]

func _on_finished() -> void:
	instructions_label.text = "Parabéns! Você completou todas as associações!"
	restart_button.text = "RECOMEÇAR"
	restart_button.visible = true

func _on_restart_button_pressed() -> void:
	_load_and_build()

func _clear_columns() -> void:
	for c in left_col.get_children():
		c.queue_free()
	for c in right_col.get_children():
		c.queue_free()

func _show_json_error(msg: String) -> void:
	title_label.text = "Liga-Liga"
	instructions_label.text = msg
	progress_label.text = ""
	restart_button.visible = true
	ChalkTheme.apply_tree($UI)

func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("JSON não encontrado: " + path)
		return {}
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	var text: String = f.get_as_text()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("JSON inválido: " + path)
		return {}
	return parsed as Dictionary
