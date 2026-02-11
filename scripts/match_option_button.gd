extends Button
class_name MatchOptionButton
# Botão de opção do "Liga-Liga" (lado esquerdo ou direito)

signal picked(option: MatchOptionButton)

var side: String = ""       # "left" ou "right"
var raw_text: String = ""   # texto exibido (com acento)
var key: String = ""        # texto normalizado (sem acento) para validação

var _solved: bool = false

func setup(p_side: String, p_raw_text: String, p_key: String) -> void:
	side = p_side
	raw_text = p_raw_text
	key = p_key

	text = raw_text
	custom_minimum_size = Vector2(520, 92)

	ChalkTheme.style_button(self, 38)

	# leve imperfeição para parecer "giz"
	rotation = randf_range(-0.01, 0.01)

	pressed.connect(_on_pressed)

func set_selected_visual() -> void:
	ChalkTheme.apply_border(self, Color(0.97, 0.98, 0.98, 0.85))

func flash_feedback(color: Color) -> void:
	ChalkTheme.apply_border(self, color)

func reset_visual() -> void:
	ChalkTheme.apply_border(self, ChalkTheme.CHALK_BORDER)

func lock_as_solved() -> void:
	_solved = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var m := modulate
	m.a = 0.5
	modulate = m

func is_solved() -> bool:
	return _solved

func _on_pressed() -> void:
	if _solved:
		return
	picked.emit(self)
