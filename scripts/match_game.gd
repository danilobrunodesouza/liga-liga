extends Node
class_name MatchGame
# Responsável por validar pares e controlar progresso (sem UI)

signal progress_changed(solved: int, total: int)
signal finished()

var _pairs: Dictionary = {} # left_key -> right_key
var _total: int = 0
var _solved: int = 0

func load_pairs(pairs_array: Array) -> void:
	_pairs.clear()
	_solved = 0

	for pv in pairs_array:
		if typeof(pv) != TYPE_DICTIONARY:
			continue
		var p: Dictionary = pv as Dictionary

		var left_text: String = str(p.get("left", ""))
		var right_text: String = str(p.get("right", ""))
		if left_text == "" or right_text == "":
			continue

		_pairs[_normalize(left_text)] = _normalize(right_text)

	_total = _pairs.size()
	progress_changed.emit(0, _total)

func is_match(left_key: String, right_key: String) -> bool:
	return _pairs.has(left_key) and str(_pairs[left_key]) == right_key

func mark_pair_solved() -> void:
	_solved += 1
	progress_changed.emit(_solved, _total)
	if _solved >= _total and _total > 0:
		finished.emit()

static func _normalize(s: String) -> String:
	var t := s.to_upper()
	t = t.replace("Á","A").replace("À","A").replace("Â","A").replace("Ã","A").replace("Ä","A")
	t = t.replace("É","E").replace("È","E").replace("Ê","E").replace("Ë","E")
	t = t.replace("Í","I").replace("Ì","I").replace("Î","I").replace("Ï","I")
	t = t.replace("Ó","O").replace("Ò","O").replace("Ô","O").replace("Õ","O").replace("Ö","O")
	t = t.replace("Ú","U").replace("Ù","U").replace("Û","U").replace("Ü","U")
	t = t.replace("Ç","C")
	return t
