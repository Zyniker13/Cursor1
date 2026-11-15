extends Control

const Rules := preload("res://scripts/census_rules.gd")
const TownScript := preload("res://scripts/town_view.gd")
const SelectScript := preload("res://scripts/floor_select_view.gd")
const DescentScript := preload("res://scripts/descent_view.gd")

var campaign
var town
var floor_select
var descent


func _ready() -> void:
	campaign = Rules.new_campaign()
	town = TownScript.new()
	town.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(town)
	town.floors_pressed.connect(_on_floors)
	town.buy_pressed.connect(_on_buy)
	town.restart_pressed.connect(_on_restart)
	floor_select = SelectScript.new()
	floor_select.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	floor_select.visible = false
	floor_select.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(floor_select)
	floor_select.descend_requested.connect(_on_descend_floor)
	floor_select.back_pressed.connect(_show_town)
	descent = DescentScript.new()
	descent.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	descent.visible = false
	descent.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(descent)
	descent.run_finished.connect(_on_return)
	town.show_campaign(campaign)


func _on_floors() -> void:
	_show_select()


func _show_town() -> void:
	floor_select.visible = false
	floor_select.process_mode = Node.PROCESS_MODE_DISABLED
	descent.visible = false
	descent.process_mode = Node.PROCESS_MODE_DISABLED
	town.process_mode = Node.PROCESS_MODE_INHERIT
	town.visible = true
	town.show_campaign(campaign)


func _show_select() -> void:
	town.visible = false
	town.process_mode = Node.PROCESS_MODE_DISABLED
	descent.visible = false
	descent.process_mode = Node.PROCESS_MODE_DISABLED
	floor_select.process_mode = Node.PROCESS_MODE_INHERIT
	floor_select.visible = true
	floor_select.show_board(campaign)


func _on_descend_floor(floor_id: String) -> void:
	var floor = Rules.floor_named(floor_id)
	if floor == null:
		return
	var state := Rules.new_run(campaign.flask_oil, floor)
	town.visible = false
	town.process_mode = Node.PROCESS_MODE_DISABLED
	floor_select.visible = false
	floor_select.process_mode = Node.PROCESS_MODE_DISABLED
	var viewport := get_viewport()
	if viewport != null:
		viewport.gui_release_focus()
	descent.process_mode = Node.PROCESS_MODE_INHERIT
	descent.visible = true
	descent.begin(state)


func _on_buy() -> void:
	Rules.buy_flask(campaign)
	town.show_campaign(campaign)


func _on_restart() -> void:
	campaign = Rules.new_campaign()
	town.show_campaign(campaign)
	if floor_select.visible:
		floor_select.show_board(campaign)


func _on_return(state: Rules.RunState) -> void:
	Rules.settle(campaign, state)
	descent.visible = false
	descent.process_mode = Node.PROCESS_MODE_DISABLED
	var finished := state.end_reason == Rules.EndReason.EXTRACTED and Rules.census_accepted(state.marks, state.floor)
	if finished:
		_show_select()
	else:
		_show_town()
