extends Node
class_name ChalkTheme
# Tema centralizado: fonte + cores + bordas (padrão para todos os jogos)

static var font: Font = preload("res://assets/fonts/chawp.ttf")
static var background_texture: Texture2D = preload("res://assets/backgrounds/chalkboard.png")

const CHALK_TEXT: Color   = Color(0.97, 0.98, 0.98, 0.92)
const CHALK_BORDER: Color = Color(0.97, 0.98, 0.98, 0.55)

const OK_GREEN: Color     = Color(0.65, 1.0, 0.65, 0.95)
const BAD_RED: Color      = Color(1.0, 0.55, 0.55, 0.95)

static func style_label(l: Label, size: int) -> void:
	if l == null:
		return
	l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", CHALK_TEXT)

static func style_button(b: Button, size: int) -> void:
	if b == null:
		return
	b.add_theme_font_override("font", font)
	b.add_theme_font_size_override("font_size", size)
	b.add_theme_color_override("font_color", CHALK_TEXT)
	apply_border(b, CHALK_BORDER)

static func apply_border(ctrl: Control, border_color: Color, width: int = 3, radius: int = 14) -> void:
	if ctrl == null:
		return
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.border_width_left = width
	sb.border_width_top = width
	sb.border_width_right = width
	sb.border_width_bottom = width
	sb.border_color = border_color
	sb.corner_radius_top_left = radius
	sb.corner_radius_top_right = radius
	sb.corner_radius_bottom_left = radius
	sb.corner_radius_bottom_right = radius

	ctrl.add_theme_stylebox_override("normal", sb)
	ctrl.add_theme_stylebox_override("hover", sb)
	ctrl.add_theme_stylebox_override("pressed", sb)
	ctrl.add_theme_stylebox_override("focus", sb)

static func apply_tree(root: Node, default_label_size: int = 28, default_button_size: int = 38) -> void:
	if root == null:
		return

	if root is Label:
		style_label(root as Label, default_label_size)
	elif root is Button:
		style_button(root as Button, default_button_size)

	for c in root.get_children():
		apply_tree(c, default_label_size, default_button_size)
