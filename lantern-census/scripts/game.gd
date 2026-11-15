extends Control

const Rules := preload("res://scripts/census_rules.gd")
const TownScript := preload("res://scripts/town_view.gd")
const DescentScript := preload("res://scripts/descent_view.gd")

var campaign
var town
var descent


func _ready() -> void:
	campaign = Rules.new_campaign()
	town = TownScript.new()
	town.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(town)
	town.descend_pressed.connect(_on_descend)
	town.buy_pressed.connect(_on_buy)
	town.restart_pressed.connect(_on_restart)
	descent = DescentScript.new()
	descent.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	descent.visible = false
	descent.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(descent)
	descent.run_finished.connect(_on_return)
	town.show_campaign(campaign)


func _on_descend() -> void:
	var state := Rules.new_run(campaign.flask_oil)
	town.visible = false
	town.process_mode = Node.PROCESS_MODE_DISABLED
	get_viewport().gui_release_focus()
	descent.process_mode = Node.PROCESS_MODE_INHERIT
	descent.visible = true
	descent.begin(state)


func _on_buy() -> void:
	Rules.buy_flask(campaign)
	town.show_campaign(campaign)


func _on_restart() -> void:
	campaign = Rules.new_campaign()
	town.show_campaign(campaign)


func _on_return(state: Rules.RunState) -> void:
	Rules.settle(campaign, state)
	descent.visible = false
	descent.process_mode = Node.PROCESS_MODE_DISABLED
	town.process_mode = Node.PROCESS_MODE_INHERIT
	town.visible = true
	town.show_campaign(campaign)
