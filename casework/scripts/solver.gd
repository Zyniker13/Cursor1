extends RefCounted

const CaseData = preload("res://scripts/case_data.gd")


static func enumerate(exhibits: Array, case_data = null) -> Array:
	var book = CaseData if case_data == null else case_data
	var found: Array = []
	var current := {}
	_walk(book, book.fields(), 0, current, exhibits, found)
	return found


static func _walk(
	book,
	fields: Array[String],
	index: int,
	current: Dictionary,
	exhibits: Array,
	found: Array
) -> void:
	if not _consistent(current, exhibits):
		return
	if index == fields.size():
		found.append(current.duplicate(true))
		return
	var field := fields[index]
	for value in book.domain(field):
		current[field] = value
		_walk(book, fields, index + 1, current, exhibits, found)
	current.erase(field)


static func _consistent(current: Dictionary, exhibits: Array) -> bool:
	for exhibit in exhibits:
		for literal in exhibit["literals"]:
			var field := str(literal["field"])
			if not current.has(field):
				continue
			if str(current[field]) != str(literal["value"]):
				return false
	return true
