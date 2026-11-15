class_name LampSession
extends RefCounted

const Rules = preload("res://rules/rules.gd")

var state: Dictionary = {}
var undo_stack: Array = []


func reset(rows: PackedStringArray, lamps: Array, guards: Array) -> void:
	state = Rules.build(rows, lamps, guards)
	undo_stack.clear()


func act(action: Dictionary, allow_toggle: bool = true) -> Dictionary:
	var out: Dictionary = Rules.apply(state, action, allow_toggle)
	if out["result"] == Rules.Result.ILLEGAL:
		return out
	undo_stack.append(Rules.clone(state))
	state = out["state"]
	return out


func undo() -> bool:
	if undo_stack.is_empty():
		return false
	state = undo_stack.pop_back()
	return true
