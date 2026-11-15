extends RefCounted

const CaseData = preload("res://scripts/case_data.gd")


static func enumerate(exhibits: Array) -> Array:
	var found: Array = []
	var current := {}
	_walk(CaseData.fields(), 0, current, exhibits, found)
	return found


static func _walk(
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
	for value in CaseData.domain(field):
		current[field] = value
		_walk(fields, index + 1, current, exhibits, found)
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
