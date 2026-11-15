# Headless Night Stamp checks. Exits 0 on success and 1 on failure.
extends SceneTree

const Rules = preload("res://rules/rules.gd")
const Policy = preload("res://tests/policy.gd")

var failures: Array = []


func _init() -> void:
	print("Night Stamp tests")
	test_scripts_parse()
	test_pool_and_playable()
	test_zero_ink()
	test_chain_cap()
	test_position_matters()
	test_progress_cap()
	test_traveler_rules()
	test_late_shift_rules()
	test_late_shift_opens()
	test_closing_bell_rules()
	test_closing_bell_opens()
	test_ash_watch_rules()
	test_ash_watch_opens()
	test_gutter_lamp_rules()
	test_gutter_lamp_opens()
	test_vellum_bell_rules()
	test_vellum_bell_opens()
	test_quire_watch_rules()
	test_quire_watch_opens()
	test_salt_watch_rules()
	test_salt_watch_opens()
	test_quay_bell_rules()
	test_quay_bell_opens()
	test_folio_bell_rules()
	test_folio_bell_opens()
	test_wick_bell_rules()
	test_wick_bell_opens()
	test_margin_bell_rules()
	test_margin_bell_opens()
	test_index_bell_rules()
	test_index_bell_opens()
	test_ledger_bell_rules()
	test_ledger_bell_opens()
	test_spine_bell_rules()
	test_spine_bell_opens()
	test_headband_bell_rules()
	test_headband_bell_opens()
	test_clasp_bell_rules()
	test_clasp_bell_opens()
	test_reward_flow_and_restart()
	test_policy_clears_act()
	test_policy_clears_late_shift()
	test_policy_clears_closing_bell()
	test_policy_clears_ash_watch()
	test_policy_clears_gutter_lamp()
	test_policy_clears_vellum_bell()
	test_policy_clears_quire_watch()
	test_policy_clears_salt_watch()
	test_policy_clears_quay_bell()
	test_policy_clears_folio_bell()
	test_policy_clears_wick_bell()
	test_policy_clears_margin_bell()
	test_policy_clears_index_bell()
	test_policy_clears_ledger_bell()
	test_policy_clears_spine_bell()
	test_policy_clears_headband_bell()
	test_policy_clears_clasp_bell()
	if failures.is_empty():
		print("ALL TESTS PASSED")
		quit(0)
	else:
		printerr("%d TEST FAILURES" % failures.size())
		for message in failures:
			printerr(" - " + String(message))
		quit(1)


func check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: " + message)
	else:
		failures.append(message)
		printerr("FAIL: " + message)


func play_named(state, card_id: String, row: int, col: int) -> bool:
	for i in state.hand.size():
		if Rules.card_id_of(state, int(state.hand[i])) == card_id:
			return Rules.play_stamp(state, i, row, col)
	failures.append("hand is missing %s" % card_id)
	return false


func test_scripts_parse() -> void:
	var rules_script = load("res://rules/rules.gd")
	var board_script = load("res://game/form_board.gd")
	var main_script = load("res://game/main.gd")
	var scene = load("res://game/main.tscn")
	check(rules_script != null, "rules script parses")
	check(board_script != null, "form board parses")
	check(main_script != null, "main scene script parses")
	check(scene != null, "main scene loads")


func test_pool_and_playable() -> void:
	check(Rules.POOL.size() == 20, "pool has 20 cards")
	var seen := {}
	for card_id in Rules.POOL:
		var id = String(card_id)
		check(not seen.has(id), "pool id %s is unique" % id)
		seen[id] = true
		check(Rules.CARDS.has(id), "pool card %s has a definition" % id)
		if not Rules.CARDS.has(id):
			continue
		var cost = int(Rules.CARDS[id]["cost"])
		check(cost >= 1, "%s costs at least 1 ink" % id)
		var state = Rules.scripted_encounter(7, 0, [id, "entry_mark", "entry_mark"], 3)
		check(Rules.can_play(state, 0, 1, 1), "%s is legally playable on the center cell" % id)
		var accepted = Rules.play_stamp(state, 0, 1, 1)
		check(accepted, "%s is accepted by play_stamp" % id)
		var stamp = state.form[1][1]
		check(stamp != null and String(stamp["card_id"]) == id, "%s occupies the center cell" % id)
		check(state.ink == 3 - cost, "%s spends its ink cost" % id)
		check(state.phase == "play" and state.turn_number == 1, "%s does not end a turn that still has ink" % id)


func test_zero_ink() -> void:
	var state = Rules.scripted_encounter(1, 0, ["entry_mark"], 0)
	check(not Rules.can_play(state, 0, 1, 1), "0 ink cannot play a stamp")
	check(not Rules.play_stamp(state, 0, 1, 1), "0 ink rejects play_stamp")
	check(state.form[1][1] == null, "rejected stamp leaves the cell empty")
	check(state.ink == 0 and state.hand.size() == 1, "rejected stamp does not spend a card")
	var poor = Rules.scripted_encounter(1, 0, ["wax_seal"], 1)
	check(not Rules.can_play(poor, 0, 1, 1), "ink 1 rejects a 2-ink stamp")


func test_chain_cap() -> void:
	# Echo retriggers the stamp below. Reply retriggers the stamp above.
	# Bram does not change either stamp's own progress, and column 1 does not yield.
	var state = Rules.scripted_encounter(3, 1, ["echo", "reply"], 2)
	check(play_named(state, "echo", 0, 0), "echo is played on the top cell")
	check(state.phase == "play", "one ink remains, so the turn stays open")
	check(play_named(state, "reply", 1, 0), "reply is played under echo and spends the last ink")
	check(state.last_chain_count == Rules.CHAIN_CAP, "echo/reply retriggers stop at the chain cap (%d)" % state.last_chain_count)
	check(state.last_chain_stopped, "a further retrigger is refused")
	check(state.last_resolver_steps == 10, "resolution stops at 10 stamp steps, not the hard backstop (%d)" % state.last_resolver_steps)
	check(state.last_resolver_steps < Rules.HARD_STEP_LIMIT, "the hard step limit is not what stopped the chain")
	check(state.last_progress_gained == 10, "capped echo/reply progress is 10 (%d)" % state.last_progress_gained)
	check(state.progress == 10, "encounter progress stays finite")


func test_position_matters() -> void:
	# Same Duty card. Bram's rule does not alter Duty's own number, and column 1
	# does not trigger his yield, so the only difference is the row.
	var top = Rules.scripted_encounter(5, 1, ["duty"], 1)
	check(play_named(top, "duty", 0, 0), "duty resolves on the top row")
	var bottom = Rules.scripted_encounter(5, 1, ["duty"], 1)
	check(play_named(bottom, "duty", 2, 0), "duty resolves on the bottom row")
	check(top.last_progress_gained != bottom.last_progress_gained, "duty on two cells produces different progress")
	check(top.last_progress_gained == 2, "duty on the top row grants 2 (%d)" % top.last_progress_gained)
	check(bottom.last_progress_gained == 4, "duty on the bottom row grants 4 (%d)" % bottom.last_progress_gained)


func test_progress_cap() -> void:
	var state = Rules.scripted_encounter(9, 1, ["wax_seal", "wax_seal", "wax_seal", "wax_seal", "ripple"], 10)
	check(play_named(state, "wax_seal", 0, 1), "wax seal on the top of column 2")
	check(play_named(state, "wax_seal", 1, 0), "wax seal left of center")
	check(play_named(state, "wax_seal", 1, 2), "wax seal right of center")
	check(play_named(state, "wax_seal", 2, 1), "wax seal below center")
	check(state.phase == "play", "ink remains before the ripple")
	check(play_named(state, "ripple", 1, 1), "ripple spends the last ink and resolves")
	check(state.last_uncapped_progress > Rules.PROGRESS_CAP, "the wax/ripple burst wants more than the cap (%d)" % state.last_uncapped_progress)
	check(state.last_progress_gained == Rules.PROGRESS_CAP, "granted progress is clamped to %d" % state.last_progress_gained)


func test_traveler_rules() -> void:
	var refused = Rules.scripted_encounter(2, 0, ["duty"], 1)
	check(play_named(refused, "duty", 0, 0), "ada receives a top-row duty")
	check(refused.last_progress_gained == 0, "ada refuses the top row (%d)" % refused.last_progress_gained)

	var cancelled = Rules.scripted_encounter(2, 0, ["exemption", "duty"], 2)
	check(play_named(cancelled, "exemption", 0, 1), "exemption is placed on ada's top row")
	check(cancelled.phase == "play", "exemption leaves the turn open")
	check(play_named(cancelled, "duty", 0, 0), "duty follows on the cancelled top row")
	check(cancelled.last_progress_gained == 3, "exemption cancels ada and both stamps count (%d)" % cancelled.last_progress_gained)

	var yielded = Rules.scripted_encounter(2, 1, ["entry_mark"], 1)
	check(play_named(yielded, "entry_mark", 1, 1), "entry mark in bram's column 2")
	check(yielded.last_progress_gained == 6, "bram yields +4 when column 2 is stamped (%d)" % yielded.last_progress_gained)
	var quiet = Rules.scripted_encounter(2, 1, ["entry_mark"], 1)
	check(play_named(quiet, "entry_mark", 1, 0), "entry mark outside column 2")
	check(quiet.last_progress_gained == 2, "bram does not yield for column 1 (%d)" % quiet.last_progress_gained)

	var taxed = Rules.scripted_encounter(2, 2, ["entry_mark"], 1)
	check(play_named(taxed, "entry_mark", 0, 0), "cira with an empty bottom row")
	check(taxed.last_patience_loss == 2, "cira's patience drops by 2 (%d)" % taxed.last_patience_loss)
	check(taxed.patience == 3, "cira's patience is 3 after the double drop")
	var grounded = Rules.scripted_encounter(2, 2, ["entry_mark"], 1)
	check(play_named(grounded, "entry_mark", 2, 1), "cira with a bottom-row stamp")
	check(grounded.last_patience_loss == 1, "a filled bottom row keeps cira's drop at 1")

	var held = Rules.scripted_encounter(2, 0, ["hold"], 1)
	check(play_named(held, "hold", 1, 0), "hold in ada's column")
	check(held.last_patience_loss == 0 and held.patience == 5, "hold delays the traveler in that column")
	var missed = Rules.scripted_encounter(2, 0, ["hold"], 1)
	check(play_named(missed, "hold", 1, 2), "hold outside ada's column")
	check(missed.last_patience_loss == 1, "hold in another column does not delay ada")

	var lone = Rules.scripted_encounter(2, 3, ["entry_mark"], 1)
	check(play_named(lone, "entry_mark", 1, 1), "a lone stamp for doss")
	check(lone.last_progress_gained == 0, "doss ignores a stamp with no neighbor")
	var pair = Rules.scripted_encounter(2, 3, ["entry_mark", "entry_mark"], 2)
	check(play_named(pair, "entry_mark", 1, 1), "first of two neighboring stamps")
	check(play_named(pair, "entry_mark", 1, 2), "second stamp beside the first")
	check(pair.last_progress_gained == 4, "doss counts stamps that touch (%d)" % pair.last_progress_gained)


func test_late_shift_rules() -> void:
	var nell = Rules.scripted_encounter(8, 0, ["duty"], 3, Rules.SHIFT_LATE)
	check(String(Rules.traveler(nell)["name"]) == "Nell Parr", "the late shift's first form is Nell Parr")
	check(String(Rules.traveler(nell)["form_name"]) == "Struck Margin", "Nell brings the Struck Margin")
	check(String(Rules.traveler(nell)["rule_text"]) == "Refuses stamps in column 1.", "Nell's form states the column rule")
	check(Rules.can_play(nell, 0, 2, 0), "rules accept a column-1 duty as a placement")
	check(Rules.preview_progress(nell, "duty", 2, 0) == 0, "preview rejects a column-1 duty for Nell")
	check(Rules.preview_progress(nell, "duty", 2, 1) == 4, "preview accepts a bottom-row duty outside column 1")
	check(Rules.preview_progress(nell, "duty", 0, 1) == 2, "preview still reads Nell's top row")

	var refused = Rules.scripted_encounter(8, 0, ["duty"], 1, Rules.SHIFT_LATE)
	check(play_named(refused, "duty", 2, 0), "Nell receives a column-1 duty")
	check(refused.last_progress_gained == 0, "Nell refuses column 1 (%d)" % refused.last_progress_gained)
	check(refused.turn_number == 2 and refused.progress == 0, "the refused duty resolved and scored nothing")
	check(refused.last_patience_loss == 1, "a refused stamp still spends the turn")

	var accepted = Rules.scripted_encounter(8, 0, ["duty"], 1, Rules.SHIFT_LATE)
	check(play_named(accepted, "duty", 2, 1), "Nell receives a bottom-row duty in column 2")
	check(accepted.last_progress_gained == 4, "Nell counts that duty (%d)" % accepted.last_progress_gained)

	var top = Rules.scripted_encounter(8, 0, ["duty"], 1, Rules.SHIFT_LATE)
	check(play_named(top, "duty", 0, 1), "Nell receives a top-row duty outside column 1")
	check(top.last_progress_gained == 2, "Nell does not refuse the top row (%d)" % top.last_progress_gained)

	var cleared = Rules.scripted_encounter(8, 0, ["exemption", "duty"], 2, Rules.SHIFT_LATE)
	check(play_named(cleared, "exemption", 1, 0), "exemption is placed on Nell's middle row")
	check(cleared.phase == "play", "Nell's exemption leaves the turn open")
	check(play_named(cleared, "duty", 2, 0), "column-1 duty follows the exemption")
	check(cleared.last_progress_gained == 5, "exemption lets Nell's column 1 count (%d)" % cleared.last_progress_gained)

	var sol_quiet = Rules.scripted_encounter(11, 1, ["entry_mark"], 1, Rules.SHIFT_LATE)
	check(String(Rules.traveler(sol_quiet)["rule_text"]) == "Yields if the middle row is full.", "Sol's Band Ledger states the full-row rule")
	check(play_named(sol_quiet, "entry_mark", 1, 1), "one stamp in Sol's column 2")
	check(sol_quiet.last_progress_gained == 2, "one middle stamp does not make Sol yield (%d)" % sol_quiet.last_progress_gained)

	var sol_gap = Rules.scripted_encounter(11, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LATE)
	check(play_named(sol_gap, "entry_mark", 1, 0), "first stamp of an incomplete middle row")
	check(play_named(sol_gap, "entry_mark", 1, 2), "second stamp of an incomplete middle row")
	check(play_named(sol_gap, "entry_mark", 0, 1), "the third stamp leaves the middle row short")
	check(sol_gap.last_progress_gained == 6, "Sol does not yield for a short middle row (%d)" % sol_gap.last_progress_gained)

	var sol_full = Rules.scripted_encounter(11, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LATE)
	check(play_named(sol_full, "entry_mark", 1, 0), "first stamp of Sol's middle row")
	check(play_named(sol_full, "entry_mark", 1, 1), "second stamp of Sol's middle row")
	check(play_named(sol_full, "entry_mark", 1, 2), "the middle row is filled")
	check(sol_full.last_progress_gained == 10, "Sol yields +4 for a full middle row (%d)" % sol_full.last_progress_gained)

	var sol_band = Rules.scripted_encounter(11, 1, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LATE)
	check(play_named(sol_band, "exemption", 1, 1), "exemption sits in the middle band, not Sol's exemption row")
	check(play_named(sol_band, "entry_mark", 1, 0), "middle row left of that exemption")
	check(play_named(sol_band, "entry_mark", 1, 2), "middle row right of that exemption")
	check(sol_band.last_progress_gained == 9, "a full middle row still yields when exemption is not on the top row (%d)" % sol_band.last_progress_gained)

	var sol_muted = Rules.scripted_encounter(11, 1, ["exemption", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_LATE)
	check(play_named(sol_muted, "exemption", 0, 1), "exemption is placed on Sol's top row")
	check(sol_muted.phase == "play", "Sol's exemption leaves the turn open")
	check(play_named(sol_muted, "entry_mark", 1, 0), "first middle stamp under a cancelled yield")
	check(play_named(sol_muted, "entry_mark", 1, 1), "second middle stamp under a cancelled yield")
	check(play_named(sol_muted, "entry_mark", 1, 2), "full middle row under a cancelled yield")
	check(sol_muted.last_progress_gained == 7, "exemption cancels Sol's yield (%d)" % sol_muted.last_progress_gained)

	var pim_empty = Rules.scripted_encounter(12, 2, ["entry_mark"], 1, Rules.SHIFT_LATE)
	check(String(Rules.traveler(pim_empty)["rule_text"]) == "Patience drops twice when column 3 is empty.", "Pim's Third-Bell Chit states the column rule")
	check(play_named(pim_empty, "entry_mark", 2, 0), "Pim gets a bottom-row stamp outside column 3")
	check(pim_empty.last_progress_gained == 2, "the bottom-row stamp still scores for Pim")
	check(pim_empty.last_patience_loss == 2, "an empty column 3 drops Pim's patience by 2 (%d)" % pim_empty.last_patience_loss)

	var pim_marked = Rules.scripted_encounter(12, 2, ["entry_mark"], 1, Rules.SHIFT_LATE)
	check(play_named(pim_marked, "entry_mark", 0, 2), "Pim gets a stamp in column 3")
	check(pim_marked.last_patience_loss == 1, "column 3 keeps Pim's drop at 1")

	var pim_held = Rules.scripted_encounter(12, 2, ["hold"], 1, Rules.SHIFT_LATE)
	check(play_named(pim_held, "hold", 0, 2), "hold in Pim's column")
	check(pim_held.last_patience_loss == 0 and pim_held.patience == 5, "hold delays Pim")

	var pim_missed = Rules.scripted_encounter(12, 2, ["hold"], 1, Rules.SHIFT_LATE)
	check(play_named(pim_missed, "hold", 0, 0), "hold outside Pim's column")
	check(pim_missed.last_patience_loss == 2, "hold in another column does not spare Pim")

	var pim_spared = Rules.scripted_encounter(12, 2, ["exemption"], 1, Rules.SHIFT_LATE)
	check(play_named(pim_spared, "exemption", 2, 0), "exemption on Pim's bottom row, column 3 still empty")
	check(pim_spared.last_patience_loss == 1, "exemption keeps Pim's drop at 1")
	check(pim_spared.last_progress_gained == 1, "the exemption itself scores 1")

	var rue_corner = Rules.scripted_encounter(13, 3, ["entry_mark"], 1, Rules.SHIFT_LATE)
	check(String(Rules.traveler(rue_corner)["rule_text"]) == "Ignores stamps in the corner boxes.", "Rue's Corner Ornament states the corner rule")
	check(Rules.can_play(rue_corner, 0, 0, 0), "rules accept a corner stamp as a placement")
	check(Rules.preview_progress(rue_corner, "entry_mark", 0, 0) == 0, "preview rejects a corner for Rue")
	check(Rules.preview_progress(rue_corner, "entry_mark", 1, 1) == 2, "preview accepts Rue's center")
	check(play_named(rue_corner, "entry_mark", 0, 0), "Rue receives a corner stamp")
	check(rue_corner.last_progress_gained == 0, "Rue ignores a corner box (%d)" % rue_corner.last_progress_gained)

	var rue_center = Rules.scripted_encounter(13, 3, ["entry_mark"], 1, Rules.SHIFT_LATE)
	check(play_named(rue_center, "entry_mark", 1, 1), "Rue receives a lone center stamp")
	check(rue_center.last_progress_gained == 2, "Rue counts a lone center stamp (%d)" % rue_center.last_progress_gained)

	var rue_edge = Rules.scripted_encounter(13, 3, ["entry_mark"], 1, Rules.SHIFT_LATE)
	check(play_named(rue_edge, "entry_mark", 1, 2), "Rue receives a side stamp that is not a corner")
	check(rue_edge.last_progress_gained == 2, "Rue counts a non-corner edge (%d)" % rue_edge.last_progress_gained)

	var rue_other = Rules.scripted_encounter(13, 3, ["entry_mark"], 1, Rules.SHIFT_LATE)
	check(play_named(rue_other, "entry_mark", 2, 2), "Rue receives the opposite corner")
	check(rue_other.last_progress_gained == 0, "Rue ignores the bottom-right corner")

	var rue_freed = Rules.scripted_encounter(13, 3, ["exemption", "entry_mark"], 2, Rules.SHIFT_LATE)
	check(play_named(rue_freed, "exemption", 2, 1), "exemption is placed on Rue's bottom row")
	check(rue_freed.phase == "play", "Rue's exemption leaves the turn open")
	check(play_named(rue_freed, "entry_mark", 2, 0), "a corner stamp follows the exemption")
	check(rue_freed.last_progress_gained == 3, "exemption lets Rue's corner count (%d)" % rue_freed.last_progress_gained)

	var refused_echo = Rules.scripted_encounter(13, 3, ["echo", "entry_mark"], 2, Rules.SHIFT_LATE)
	check(play_named(refused_echo, "echo", 0, 0), "echo is placed in a corner box")
	check(refused_echo.phase == "play", "the corner echo leaves the turn open")
	check(play_named(refused_echo, "entry_mark", 1, 0), "entry mark is placed under the corner echo")
	check(refused_echo.last_chain_count == 1, "the refused echo still retriggers")
	check(refused_echo.last_progress_gained == 4, "the corner echo scores 0 and the retrigger still pays (%d)" % refused_echo.last_progress_gained)

	var read_echo = Rules.scripted_encounter(13, 3, ["echo", "entry_mark"], 2, Rules.SHIFT_LATE)
	check(play_named(read_echo, "echo", 0, 1), "echo is placed outside the corners")
	check(play_named(read_echo, "entry_mark", 1, 1), "entry mark is placed under that echo")
	check(read_echo.last_progress_gained == 5, "an echo outside the corners scores its own 1 (%d)" % read_echo.last_progress_gained)


func test_late_shift_opens() -> void:
	check(Rules.LATE_SHIFT.size() == 4, "the late shift has four travelers")
	var first = Rules.new_run(99)
	check(first.shift == Rules.SHIFT_FIRST, "a new run opens the first bell")
	check(String(Rules.traveler(first)["name"]) == "Ada Quill", "the first bell still begins with Ada")
	var late = Rules.new_run(99, Rules.SHIFT_LATE)
	check(late.shift == Rules.SHIFT_LATE, "the late shift is a separate night")
	check(String(Rules.traveler(late)["name"]) == "Nell Parr", "the late shift begins with Nell Parr")
	check(late.hand.size() == Rules.HAND_SIZE, "the late shift draws 5")
	check(late.ink == Rules.BASE_INK, "the late shift starts at 3 ink")
	check(late.library.size() == Rules.STARTING_DECK.size(), "the late shift deals the starting deck")
	check(late.phase == "play", "the late shift opens in play")
	var before = late.library.size()
	late.progress = 4
	late.patience = 1
	Rules.restart_encounter(late)
	check(late.shift == Rules.SHIFT_LATE and late.traveler_index == 0, "restart encounter stays on the late shift")
	check(late.progress == 0 and late.patience == int(Rules.LATE_SHIFT[0]["patience"]), "restart encounter resets Nell")
	check(late.library.size() == before and late.hand.size() == 5 and late.phase == "play", "restart keeps the late-shift deck and deals a hand")

	var packed = load("res://game/main.tscn")
	var desk = packed.instantiate()
	root.add_child(desk)
	# SceneTree setup has not entered _ready yet, so open the desk directly.
	if desk.state == null:
		desk._ready()
	check(desk.state.shift == Rules.SHIFT_FIRST, "the desk opens on Act 1")
	check(desk.shift_button.text == "Late shift", "the desk offers the late shift")
	desk._toggle_shift()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_LATE, "the desk can open the late shift")
	check(String(Rules.traveler(desk.state)["name"]) == "Nell Parr", "the open desk shows Nell")
	check(String(desk.desk_label.text).begins_with("Late shift"), "the desk title follows the night")
	check(desk.meta_label.text.contains("Struck Margin"), "the desk shows Nell's form")
	check(desk.shift_button.text == "First bell", "the desk can return to the first bell")
	desk._begin_first_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "first bell returns to Ada")
	root.remove_child(desk)
	desk.free()


func test_reward_flow_and_restart() -> void:
	var state = Rules.new_run(99)
	check(state.hand.size() == Rules.HAND_SIZE, "a new run draws 5")
	check(state.ink == Rules.BASE_INK, "a new run starts at 3 ink")
	state.progress = int(Rules.TRAVELERS[0]["goal"]) - 1
	var played = false
	for i in state.hand.size():
		var card_id = Rules.card_id_of(state, int(state.hand[i]))
		if Rules.can_play(state, i, 2, 0):
			played = Rules.play_stamp(state, i, 2, 0)
			break
	check(played, "a bottom-row stamp can finish ada")
	if state.phase == "play":
		Rules.end_turn(state)
	check(state.phase == "draft" and state.draft_options.size() == 3, "ada's win offers 3 cards")
	check(Rules.choose_draft(state, 0), "draft adds a card and advances")
	check(state.traveler_index == 1 and state.phase == "play", "bram's encounter starts")
	check(state.library.size() == Rules.STARTING_DECK.size() + 1, "the drafted card joins the deck")

	state.progress = int(Rules.TRAVELERS[1]["goal"]) - 1
	played = false
	for i in state.hand.size():
		if Rules.can_play(state, i, 2, 1):
			played = Rules.play_stamp(state, i, 2, 1)
			break
	check(played, "a stamp can finish bram")
	if state.phase == "play":
		Rules.end_turn(state)
	check(state.phase == "relic" and state.relic_options.size() == 2, "encounter 2 offers two relics")
	check(Rules.choose_relic(state, Rules.RELIC_DEEP_WELL), "deep well can be taken")
	check(state.phase == "draft" and state.relic_id == Rules.RELIC_DEEP_WELL, "the relic persists into the draft")
	check(Rules.choose_draft(state, 0), "the post-relic draft advances to cira")
	check(state.traveler_index == 2 and state.ink == 4, "deep well sets the next turn to 4 ink")

	var before = state.library.size()
	state.progress = 7
	state.patience = 1
	Rules.restart_encounter(state)
	check(state.progress == 0 and state.patience == int(Rules.TRAVELERS[2]["patience"]), "restart encounter resets the traveler")
	check(state.traveler_index == 2 and state.relic_id == Rules.RELIC_DEEP_WELL, "restart keeps the relic and the traveler")
	check(state.library.size() == before and state.phase == "play" and state.hand.size() == 5, "restart keeps the deck and deals a hand")
	var again = Rules.new_run(99)
	check(again.encounters_cleared == 0 and again.relic_id == "" and again.traveler_index == 0, "restart act is a fresh seeded run")


func test_policy_clears_act() -> void:
	var started = Time.get_ticks_msec()
	var state = Rules.new_run(12345)
	var steps = 0
	var seen = 0
	while state.phase != "victory":
		steps += 1
		if steps > 500 or state.phase == "defeat":
			check(false, "policy lost or stalled on seed 12345: " + Rules.debug_summary(state))
			return
		var action = Policy.choose(state)
		if not Rules.apply_action(state, action):
			check(false, "policy action was rejected: %s / %s" % [str(action), Rules.debug_summary(state)])
			return
		if state.encounters_cleared != seen:
			seen = state.encounters_cleared
			print("cleared encounter %d after %d actions" % [seen, steps])
	var elapsed = Time.get_ticks_msec() - started
	check(state.encounters_cleared == 4, "policy cleared all 4 encounters on seed 12345")
	check(state.phase == "victory", "policy ends in victory")
	print("policy finished in %d actions, %d ms" % [steps, elapsed])


func test_policy_clears_late_shift() -> void:
	var started = Time.get_ticks_msec()
	var state = Rules.new_run(12345, Rules.SHIFT_LATE)
	var steps = 0
	var seen = 0
	while state.phase != "victory":
		steps += 1
		if steps > 500 or state.phase == "defeat":
			check(false, "policy lost or stalled on the late shift, seed 12345: " + Rules.debug_summary(state))
			return
		var action = Policy.choose(state)
		if not Rules.apply_action(state, action):
			check(false, "late-shift policy action was rejected: %s / %s" % [str(action), Rules.debug_summary(state)])
			return
		if state.encounters_cleared != seen:
			seen = state.encounters_cleared
			print("cleared late encounter %d after %d actions" % [seen, steps])
	var elapsed = Time.get_ticks_msec() - started
	check(state.encounters_cleared == 4, "policy cleared all 4 late-shift encounters on seed 12345")
	check(state.phase == "victory", "late shift ends in victory")
	check(state.shift == Rules.SHIFT_LATE, "the clear stayed on the late shift")
	print("late shift finished in %d actions, %d ms" % [steps, elapsed])


func test_closing_bell_rules() -> void:
	var moss = Rules.scripted_encounter(21, 0, ["duty"], 3, Rules.SHIFT_CLOSING)
	check(String(Rules.traveler(moss)["name"]) == "Moss Quen", "the closing bell's first form is Moss Quen")
	check(String(Rules.traveler(moss)["form_name"]) == "Folded Band", "Moss brings the Folded Band")
	check(String(Rules.traveler(moss)["rule_text"]) == "Refuses stamps on the middle row.", "Moss's form states the middle-row rule")
	check(Rules.can_play(moss, 0, 1, 1), "rules accept a middle-row duty as a placement")
	check(Rules.preview_progress(moss, "duty", 1, 1) == 0, "preview rejects a middle-row duty for Moss")
	check(Rules.preview_progress(moss, "duty", 2, 1) == 4, "preview accepts Moss's bottom row")
	check(Rules.preview_progress(moss, "duty", 0, 1) == 2, "preview still reads Moss's top row")

	var refused = Rules.scripted_encounter(21, 0, ["duty"], 1, Rules.SHIFT_CLOSING)
	check(play_named(refused, "duty", 1, 1), "Moss receives a middle-row duty, the wrong stamp")
	check(refused.last_progress_gained == 0, "Moss refuses the middle row (%d)" % refused.last_progress_gained)
	check(refused.turn_number == 2 and refused.progress == 0, "the refused duty resolved and scored nothing")
	check(refused.last_patience_loss == 1, "a refused middle-row stamp still spends the turn")

	var accepted = Rules.scripted_encounter(21, 0, ["duty"], 1, Rules.SHIFT_CLOSING)
	check(play_named(accepted, "duty", 2, 1), "Moss receives a bottom-row duty, the correct stamp")
	check(accepted.last_progress_gained == 4, "Moss counts that duty (%d)" % accepted.last_progress_gained)

	var top = Rules.scripted_encounter(21, 0, ["duty"], 1, Rules.SHIFT_CLOSING)
	check(play_named(top, "duty", 0, 1), "Moss receives a top-row duty")
	check(top.last_progress_gained == 2, "Moss does not refuse the top row (%d)" % top.last_progress_gained)

	var cleared = Rules.scripted_encounter(21, 0, ["exemption", "duty"], 2, Rules.SHIFT_CLOSING)
	check(play_named(cleared, "exemption", 1, 0), "exemption is placed on Moss's middle row")
	check(cleared.phase == "play", "Moss's exemption leaves the turn open")
	check(play_named(cleared, "duty", 1, 2), "a middle-row duty follows the exemption")
	check(cleared.last_progress_gained == 3, "exemption lets Moss's middle row count (%d)" % cleared.last_progress_gained)

	var kel_one = Rules.scripted_encounter(22, 1, ["entry_mark"], 1, Rules.SHIFT_CLOSING)
	check(String(Rules.traveler(kel_one)["name"]) == "Kel Breck", "the closing bell's second form is Kel Breck")
	check(String(Rules.traveler(kel_one)["form_name"]) == "Twin Margin", "Kel brings the Twin Margin")
	check(String(Rules.traveler(kel_one)["rule_text"]) == "Yields if column 1 and column 3 are both stamped.", "Kel's form states the margin rule")
	check(play_named(kel_one, "entry_mark", 1, 0), "Kel receives one stamp in column 1, a wrong stamp for the yield")
	check(kel_one.last_progress_gained == 2, "one margin does not make Kel yield (%d)" % kel_one.last_progress_gained)

	var kel_other = Rules.scripted_encounter(22, 1, ["entry_mark"], 1, Rules.SHIFT_CLOSING)
	check(play_named(kel_other, "entry_mark", 1, 2), "Kel receives one stamp in column 3")
	check(kel_other.last_progress_gained == 2, "column 3 alone does not make Kel yield (%d)" % kel_other.last_progress_gained)

	var kel_center = Rules.scripted_encounter(22, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_CLOSING)
	check(play_named(kel_center, "entry_mark", 0, 1), "first stamp in Kel's column 2")
	check(play_named(kel_center, "entry_mark", 2, 1), "second stamp in Kel's column 2")
	check(kel_center.last_progress_gained == 4, "column 2 does not satisfy either margin (%d)" % kel_center.last_progress_gained)

	var kel_same = Rules.scripted_encounter(22, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_CLOSING)
	check(play_named(kel_same, "entry_mark", 0, 0), "first stamp of a single margin")
	check(play_named(kel_same, "entry_mark", 2, 0), "second stamp of that same margin")
	check(kel_same.last_progress_gained == 4, "two stamps in column 1 still leave Kel short (%d)" % kel_same.last_progress_gained)

	var kel_yield = Rules.scripted_encounter(22, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_CLOSING)
	check(play_named(kel_yield, "entry_mark", 0, 0), "Kel receives the correct stamp in column 1")
	check(play_named(kel_yield, "entry_mark", 2, 2), "Kel receives the correct stamp in column 3")
	check(kel_yield.last_progress_gained == 8, "Kel yields +4 when both margins are stamped (%d)" % kel_yield.last_progress_gained)

	var kel_band = Rules.scripted_encounter(22, 1, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_CLOSING)
	check(play_named(kel_band, "exemption", 1, 1), "exemption sits off Kel's top row")
	check(play_named(kel_band, "entry_mark", 1, 0), "column 1 beside that exemption")
	check(play_named(kel_band, "entry_mark", 1, 2), "column 3 beside that exemption")
	check(kel_band.last_progress_gained == 9, "both margins still yield when exemption is not on the top row (%d)" % kel_band.last_progress_gained)

	var kel_muted = Rules.scripted_encounter(22, 1, ["exemption", "entry_mark", "entry_mark"], 4, Rules.SHIFT_CLOSING)
	check(play_named(kel_muted, "exemption", 0, 1), "exemption is placed on Kel's top row")
	check(kel_muted.phase == "play", "Kel's exemption leaves the turn open")
	check(play_named(kel_muted, "entry_mark", 1, 0), "column 1 under a cancelled yield")
	check(play_named(kel_muted, "entry_mark", 1, 2), "column 3 under a cancelled yield")
	check(kel_muted.last_progress_gained == 5, "exemption cancels Kel's yield (%d)" % kel_muted.last_progress_gained)

	var tansy_empty = Rules.scripted_encounter(23, 2, ["entry_mark"], 1, Rules.SHIFT_CLOSING)
	check(String(Rules.traveler(tansy_empty)["name"]) == "Tansy Pell", "the closing bell's third form is Tansy Pell")
	check(String(Rules.traveler(tansy_empty)["form_name"]) == "Center Void", "Tansy brings the Center Void")
	check(String(Rules.traveler(tansy_empty)["rule_text"]) == "Patience drops twice when the center cell is empty.", "Tansy's form states the center rule")
	check(play_named(tansy_empty, "entry_mark", 2, 0), "Tansy receives a stamp outside the center, the wrong stamp")
	check(tansy_empty.last_progress_gained == 2, "the outside stamp still scores for Tansy")
	check(tansy_empty.last_patience_loss == 2, "an empty center drops Tansy's patience by 2 (%d)" % tansy_empty.last_patience_loss)
	check(tansy_empty.patience == 3, "Tansy's patience is 3 after the double drop")

	var tansy_center = Rules.scripted_encounter(23, 2, ["entry_mark"], 1, Rules.SHIFT_CLOSING)
	check(play_named(tansy_center, "entry_mark", 1, 1), "Tansy receives a center stamp, the correct stamp")
	check(tansy_center.last_progress_gained == 2, "the center stamp scores for Tansy")
	check(tansy_center.last_patience_loss == 1, "the center keeps Tansy's drop at 1")

	var tansy_held = Rules.scripted_encounter(23, 2, ["hold"], 1, Rules.SHIFT_CLOSING)
	check(play_named(tansy_held, "hold", 0, 0), "hold in Tansy's column")
	check(tansy_held.last_patience_loss == 0 and tansy_held.patience == 5, "hold delays Tansy before the double drop")

	var tansy_missed = Rules.scripted_encounter(23, 2, ["hold"], 1, Rules.SHIFT_CLOSING)
	check(play_named(tansy_missed, "hold", 0, 2), "hold outside Tansy's column")
	check(tansy_missed.last_patience_loss == 2, "hold in another column does not spare Tansy")

	var tansy_spared = Rules.scripted_encounter(23, 2, ["exemption"], 1, Rules.SHIFT_CLOSING)
	check(play_named(tansy_spared, "exemption", 2, 1), "exemption on Tansy's bottom row, center still empty")
	check(tansy_spared.last_patience_loss == 1, "exemption keeps Tansy's drop at 1")
	check(tansy_spared.last_progress_gained == 1, "the exemption itself scores 1")

	var lumen = Rules.scripted_encounter(24, 3, ["entry_mark", "duty"], 3, Rules.SHIFT_CLOSING)
	check(String(Rules.traveler(lumen)["name"]) == "Lumen Peck", "the closing bell's fourth form is Lumen Peck")
	check(String(Rules.traveler(lumen)["form_name"]) == "Overprint Slip", "Lumen brings the Overprint Slip")
	check(String(Rules.traveler(lumen)["rule_text"]) == "Ignores a stamp with a stamp directly above it.", "Lumen's form states the covered-stamp rule")
	check(play_named(lumen, "entry_mark", 0, 1), "a stamp is placed above the cell Lumen will judge")
	check(lumen.phase == "play", "the covering stamp leaves the turn open")
	check(Rules.can_play(lumen, 0, 1, 1), "rules accept a covered duty as a placement")
	check(Rules.preview_progress(lumen, "duty", 1, 1) == 0, "preview rejects a duty with a stamp directly above")
	check(Rules.preview_progress(lumen, "duty", 1, 2) == 2, "preview accepts a duty with an empty cell above")
	check(Rules.preview_progress(lumen, "duty", 2, 1) == 4, "preview accepts a bottom-row duty when the middle cell is empty")

	var covered = Rules.scripted_encounter(24, 3, ["entry_mark", "duty"], 2, Rules.SHIFT_CLOSING)
	check(play_named(covered, "entry_mark", 0, 1), "Lumen's covering stamp is on the top row")
	check(play_named(covered, "duty", 1, 1), "Lumen receives a covered duty, the wrong stamp")
	check(covered.last_progress_gained == 2, "Lumen ignores the covered duty (%d)" % covered.last_progress_gained)

	var open_bottom = Rules.scripted_encounter(24, 3, ["duty"], 1, Rules.SHIFT_CLOSING)
	check(play_named(open_bottom, "duty", 2, 1), "Lumen receives an uncovered bottom-row duty, the correct stamp")
	check(open_bottom.last_progress_gained == 4, "Lumen counts a duty with nothing directly above (%d)" % open_bottom.last_progress_gained)

	var gap = Rules.scripted_encounter(24, 3, ["entry_mark", "duty"], 2, Rules.SHIFT_CLOSING)
	check(play_named(gap, "entry_mark", 0, 0), "the top of the column is filled")
	check(play_named(gap, "duty", 2, 0), "the bottom stamp has an empty cell directly above")
	check(gap.last_progress_gained == 6, "Lumen counts a stamp when only the top of the column is filled (%d)" % gap.last_progress_gained)

	var stacked = Rules.scripted_encounter(24, 3, ["entry_mark", "duty"], 2, Rules.SHIFT_CLOSING)
	check(play_named(stacked, "entry_mark", 1, 0), "a middle-row stamp covers the cell below")
	check(play_named(stacked, "duty", 2, 0), "the bottom duty sits directly under that stamp")
	check(stacked.last_progress_gained == 2, "Lumen ignores a stamp directly under another (%d)" % stacked.last_progress_gained)

	var freed = Rules.scripted_encounter(24, 3, ["entry_mark", "duty", "exemption"], 3, Rules.SHIFT_CLOSING)
	check(play_named(freed, "entry_mark", 1, 0), "a stamp covers the bottom of column 1")
	check(play_named(freed, "exemption", 2, 1), "exemption is placed on Lumen's bottom row")
	check(freed.phase == "play", "Lumen's exemption leaves the turn open")
	check(play_named(freed, "duty", 2, 0), "the covered duty follows the exemption")
	check(freed.last_progress_gained == 7, "exemption lets Lumen's covered stamp count (%d)" % freed.last_progress_gained)

	var covered_reply = Rules.scripted_encounter(24, 3, ["entry_mark", "reply"], 2, Rules.SHIFT_CLOSING)
	check(play_named(covered_reply, "entry_mark", 0, 1), "entry mark covers the reply")
	check(play_named(covered_reply, "reply", 1, 1), "reply is placed directly under that stamp")
	check(covered_reply.last_chain_count == 1, "the ignored reply still retriggers")
	check(covered_reply.last_progress_gained == 4, "the covered reply scores 0 and the retrigger still pays (%d)" % covered_reply.last_progress_gained)

	var open_reply = Rules.scripted_encounter(24, 3, ["reply", "entry_mark"], 2, Rules.SHIFT_CLOSING)
	check(play_named(open_reply, "reply", 0, 1), "reply is placed on the top row")
	check(play_named(open_reply, "entry_mark", 1, 2), "entry mark is placed beside the column under that reply")
	check(open_reply.last_chain_count == 0, "a top-row reply has no stamp above to retrigger")
	check(open_reply.last_progress_gained == 3, "Lumen counts both uncovered stamps (%d)" % open_reply.last_progress_gained)

	var covered_hold = Rules.scripted_encounter(24, 3, ["entry_mark", "hold"], 2, Rules.SHIFT_CLOSING)
	check(play_named(covered_hold, "entry_mark", 0, 2), "a stamp covers Lumen's lane")
	check(play_named(covered_hold, "hold", 1, 2), "hold is placed in that lane, under the stamp")
	check(covered_hold.last_progress_gained == 2, "the covered hold grants no progress")
	check(covered_hold.last_patience_loss == 0 and covered_hold.patience == 5, "a covered hold still delays Lumen")

	var bram = Rules.scripted_encounter(5, 1, ["duty"], 1)
	check(play_named(bram, "duty", 1, 0), "Bram still receives a middle-row duty")
	check(bram.last_progress_gained == 2, "Act 1 does not refuse the middle row (%d)" % bram.last_progress_gained)
	var nell = Rules.scripted_encounter(8, 0, ["duty"], 1, Rules.SHIFT_LATE)
	check(play_named(nell, "duty", 1, 1), "Nell still receives a middle-row duty outside column 1")
	check(nell.last_progress_gained == 2, "the late shift does not refuse the middle row (%d)" % nell.last_progress_gained)


func test_closing_bell_opens() -> void:
	check(Rules.CLOSING_BELL.size() == 4, "the closing bell has four travelers")
	check(Rules.TRAVELERS.size() == 4 and String(Rules.TRAVELERS[0]["name"]) == "Ada Quill", "Act 1 still begins with Ada Quill")
	check(Rules.LATE_SHIFT.size() == 4 and String(Rules.LATE_SHIFT[0]["name"]) == "Nell Parr", "the late shift still begins with Nell Parr")
	check(String(Rules.LATE_SHIFT[3]["name"]) == "Rue Calder", "the late shift still ends with Rue Calder")
	var closing = Rules.new_run(77, Rules.SHIFT_CLOSING)
	check(closing.shift == Rules.SHIFT_CLOSING, "the closing bell is a separate night")
	check(String(Rules.traveler(closing)["name"]) == "Moss Quen", "the closing bell begins with Moss Quen")
	check(closing.hand.size() == Rules.HAND_SIZE, "the closing bell draws 5")
	check(closing.ink == Rules.BASE_INK, "the closing bell starts at 3 ink")
	check(closing.library.size() == Rules.STARTING_DECK.size(), "the closing bell deals the starting deck")
	check(closing.relic_id == "", "an earlier night's relic does not carry")
	check(closing.phase == "play", "the closing bell opens in play")
	var dealt: Array = []
	for iid in closing.hand:
		dealt.append(Rules.card_id_of(closing, int(iid)))
	var before = closing.library.size()
	closing.progress = 4
	closing.patience = 1
	Rules.restart_encounter(closing)
	check(closing.shift == Rules.SHIFT_CLOSING and closing.traveler_index == 0, "restart encounter stays on the closing bell")
	check(closing.progress == 0 and closing.patience == int(Rules.CLOSING_BELL[0]["patience"]), "restart encounter resets Moss")
	check(closing.library.size() == before and closing.hand.size() == 5 and closing.phase == "play", "restart keeps the closing-bell deck and deals a hand")
	var redealt: Array = []
	for iid in closing.hand:
		redealt.append(Rules.card_id_of(closing, int(iid)))
	check(redealt == dealt, "restart deals Moss the same hand")

	var packed = load("res://game/main.tscn")
	var desk = packed.instantiate()
	root.add_child(desk)
	if desk.state == null:
		desk._ready()
	check(desk.state.shift == Rules.SHIFT_FIRST, "the desk still opens on Act 1")
	check(desk.closing_button.text == "Closing bell", "the desk offers the closing bell")
	check(desk.shift_button.text == "Late shift", "the desk still offers the late shift")
	desk.closing_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_CLOSING, "the desk can open the closing bell")
	check(String(Rules.traveler(desk.state)["name"]) == "Moss Quen", "the open desk shows Moss")
	check(String(desk.desk_label.text).begins_with("Closing bell"), "the desk title follows the closing bell")
	check(desk.meta_label.text.contains("Folded Band"), "the desk shows Moss's form")
	check(desk.closing_button.text == "First bell", "the closing bell can return to the first bell")
	check(desk.shift_button.text == "Late shift", "the late shift stays available from the closing bell")
	desk._restart_act()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_CLOSING and String(Rules.traveler(desk.state)["name"]) == "Moss Quen", "restart act replays the closing bell")
	desk.closing_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the closing bell returns to Ada")
	desk._toggle_shift()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_LATE and String(Rules.traveler(desk.state)["name"]) == "Nell Parr", "the late shift still opens from the first bell")
	check(desk.closing_button.text == "Closing bell", "the late shift offers the closing bell")
	desk._begin_closing_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_CLOSING and String(Rules.traveler(desk.state)["name"]) == "Moss Quen", "the late shift can open the closing bell")
	desk._toggle_shift()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_LATE and String(Rules.traveler(desk.state)["name"]) == "Nell Parr", "the closing bell can open the late shift")
	desk._begin_first_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "first bell still returns to Ada")
	root.remove_child(desk)
	desk.free()


func test_policy_clears_closing_bell() -> void:
	var started = Time.get_ticks_msec()
	var state = Rules.new_run(12345, Rules.SHIFT_CLOSING)
	var steps = 0
	var seen = 0
	while state.phase != "victory":
		steps += 1
		if steps > 500 or state.phase == "defeat":
			check(false, "policy lost or stalled on the closing bell, seed 12345: " + Rules.debug_summary(state))
			return
		var action = Policy.choose(state)
		if not Rules.apply_action(state, action):
			check(false, "closing-bell policy action was rejected: %s / %s" % [str(action), Rules.debug_summary(state)])
			return
		if state.encounters_cleared != seen:
			seen = state.encounters_cleared
			print("cleared closing encounter %d after %d actions" % [seen, steps])
	var elapsed = Time.get_ticks_msec() - started
	check(state.encounters_cleared == 4, "policy cleared all 4 closing-bell encounters on seed 12345")
	check(state.phase == "victory", "closing bell ends in victory")
	check(state.shift == Rules.SHIFT_CLOSING, "the clear stayed on the closing bell")
	print("closing bell finished in %d actions, %d ms" % [steps, elapsed])


func test_ash_watch_rules() -> void:
	var orla = Rules.scripted_encounter(31, 0, ["duty"], 3, Rules.SHIFT_ASH)
	check(String(Rules.traveler(orla)["name"]) == "Orla Fen", "the ash watch's first form is Orla Fen")
	check(String(Rules.traveler(orla)["form_name"]) == "Sealed Foot", "Orla brings the Sealed Foot")
	check(String(Rules.traveler(orla)["rule_text"]) == "Refuses stamps on the bottom row.", "Orla's form states the bottom-row rule")
	check(Rules.can_play(orla, 0, 2, 1), "rules accept a bottom-row duty as a placement")
	check(Rules.preview_progress(orla, "duty", 2, 1) == 0, "preview rejects a bottom-row duty for Orla")
	check(Rules.preview_progress(orla, "duty", 1, 1) == 2, "preview accepts Orla's middle row")
	check(Rules.preview_progress(orla, "duty", 0, 1) == 2, "preview still reads Orla's top row")

	var refused = Rules.scripted_encounter(31, 0, ["duty"], 1, Rules.SHIFT_ASH)
	check(play_named(refused, "duty", 2, 1), "Orla receives a bottom-row duty, the wrong stamp")
	check(refused.last_progress_gained == 0, "Orla refuses the bottom row (%d)" % refused.last_progress_gained)
	check(refused.turn_number == 2 and refused.progress == 0, "the refused bottom-row duty resolved and scored nothing")
	check(refused.last_patience_loss == 1, "a refused bottom-row stamp still spends the turn")

	var accepted = Rules.scripted_encounter(31, 0, ["duty"], 1, Rules.SHIFT_ASH)
	check(play_named(accepted, "duty", 1, 1), "Orla receives a middle-row duty, the correct stamp")
	check(accepted.last_progress_gained == 2, "Orla counts that duty (%d)" % accepted.last_progress_gained)

	var top = Rules.scripted_encounter(31, 0, ["duty"], 1, Rules.SHIFT_ASH)
	check(play_named(top, "duty", 0, 1), "Orla receives a top-row duty")
	check(top.last_progress_gained == 2, "Orla does not refuse the top row (%d)" % top.last_progress_gained)

	var cleared = Rules.scripted_encounter(31, 0, ["exemption", "duty"], 2, Rules.SHIFT_ASH)
	check(play_named(cleared, "exemption", 2, 0), "exemption is placed on Orla's bottom row")
	check(cleared.phase == "play", "Orla's exemption leaves the turn open")
	check(play_named(cleared, "duty", 2, 1), "a bottom-row duty follows the exemption")
	check(cleared.last_progress_gained == 5, "exemption lets Orla's bottom row count (%d)" % cleared.last_progress_gained)

	var still_sealed = Rules.scripted_encounter(31, 0, ["exemption", "duty"], 2, Rules.SHIFT_ASH)
	check(play_named(still_sealed, "exemption", 0, 1), "exemption sits off Orla's bottom row")
	check(play_named(still_sealed, "duty", 2, 1), "the bottom-row duty stays sealed")
	check(still_sealed.last_progress_gained == 1, "an exemption off the bottom row does not unseal it (%d)" % still_sealed.last_progress_gained)

	var refused_reply = Rules.scripted_encounter(31, 0, ["entry_mark", "reply"], 2, Rules.SHIFT_ASH)
	check(play_named(refused_reply, "entry_mark", 1, 0), "entry mark is placed above a bottom-row reply")
	check(play_named(refused_reply, "reply", 2, 0), "reply is placed on Orla's bottom row")
	check(refused_reply.last_chain_count == 1, "the refused reply still retriggers")
	check(refused_reply.last_progress_gained == 4, "the bottom reply scores 0 and the retrigger still pays (%d)" % refused_reply.last_progress_gained)

	var refused_hold = Rules.scripted_encounter(31, 0, ["hold"], 1, Rules.SHIFT_ASH)
	check(play_named(refused_hold, "hold", 2, 1), "hold is placed on the bottom row of Orla's column")
	check(refused_hold.last_progress_gained == 0, "the refused hold grants no progress")
	check(refused_hold.last_patience_loss == 0 and refused_hold.patience == 5, "a refused hold still delays Orla")

	var missed_hold = Rules.scripted_encounter(31, 0, ["hold"], 1, Rules.SHIFT_ASH)
	check(play_named(missed_hold, "hold", 0, 0), "hold outside Orla's column")
	check(missed_hold.last_patience_loss == 1, "hold in another column does not delay Orla")

	var joss_one = Rules.scripted_encounter(32, 1, ["entry_mark"], 1, Rules.SHIFT_ASH)
	check(String(Rules.traveler(joss_one)["name"]) == "Joss Mire", "the ash watch's second form is Joss Mire")
	check(String(Rules.traveler(joss_one)["form_name"]) == "Pair Chit", "Joss brings the Pair Chit")
	check(String(Rules.traveler(joss_one)["rule_text"]) == "Yields if the form holds exactly two stamps.", "Joss's form states the pair rule")
	check(play_named(joss_one, "entry_mark", 1, 1), "Joss receives one stamp, the wrong stamp")
	check(joss_one.last_progress_gained == 2, "one stamp does not make Joss yield (%d)" % joss_one.last_progress_gained)

	var joss_three = Rules.scripted_encounter(32, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_ASH)
	check(play_named(joss_three, "entry_mark", 1, 0), "first stamp of a full middle row")
	check(play_named(joss_three, "entry_mark", 1, 1), "second stamp of a full middle row")
	check(play_named(joss_three, "entry_mark", 1, 2), "a third stamp fills the middle row")
	check(joss_three.last_progress_gained == 6, "three stamps do not make Joss yield (%d)" % joss_three.last_progress_gained)

	var joss_pair = Rules.scripted_encounter(32, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_ASH)
	check(play_named(joss_pair, "entry_mark", 0, 1), "Joss receives the first correct stamp")
	check(play_named(joss_pair, "entry_mark", 2, 1), "Joss receives the second correct stamp")
	check(joss_pair.last_progress_gained == 8, "Joss yields +4 for exactly two stamps (%d)" % joss_pair.last_progress_gained)

	var joss_column = Rules.scripted_encounter(32, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_ASH)
	check(play_named(joss_column, "entry_mark", 0, 0), "first stamp of one column")
	check(play_named(joss_column, "entry_mark", 2, 0), "second stamp of that same column")
	check(joss_column.last_progress_gained == 8, "exactly two stamps yield even in one column (%d)" % joss_column.last_progress_gained)

	var joss_kept = Rules.scripted_encounter(32, 1, ["exemption", "entry_mark"], 2, Rules.SHIFT_ASH)
	check(play_named(joss_kept, "exemption", 1, 1), "exemption sits off Joss's top row")
	check(play_named(joss_kept, "entry_mark", 1, 0), "the second stamp beside that exemption")
	check(joss_kept.last_progress_gained == 7, "exactly two stamps still yield when exemption is not on the top row (%d)" % joss_kept.last_progress_gained)

	var joss_muted = Rules.scripted_encounter(32, 1, ["exemption", "entry_mark"], 2, Rules.SHIFT_ASH)
	check(play_named(joss_muted, "exemption", 0, 1), "exemption is placed on Joss's top row")
	check(joss_muted.phase == "play", "Joss's exemption leaves the turn open")
	check(play_named(joss_muted, "entry_mark", 1, 0), "the second stamp under a cancelled yield")
	check(joss_muted.last_progress_gained == 3, "exemption cancels Joss's yield (%d)" % joss_muted.last_progress_gained)

	var vetch_one = Rules.scripted_encounter(33, 2, ["entry_mark"], 1, Rules.SHIFT_ASH)
	check(String(Rules.traveler(vetch_one)["name"]) == "Vetch Rowan", "the ash watch's third form is Vetch Rowan")
	check(String(Rules.traveler(vetch_one)["form_name"]) == "Row Seal", "Vetch brings the Row Seal")
	check(String(Rules.traveler(vetch_one)["rule_text"]) == "Patience does not fall when every row is stamped.", "Vetch's form states the row rule")
	check(play_named(vetch_one, "entry_mark", 2, 0), "Vetch receives one stamp, the wrong stamp")
	check(vetch_one.last_progress_gained == 2, "the single stamp still scores for Vetch")
	check(vetch_one.last_patience_loss == 1, "one row does not hold Vetch's patience (%d)" % vetch_one.last_patience_loss)
	check(vetch_one.patience == 4, "Vetch's patience is 4 after one row")

	var vetch_two = Rules.scripted_encounter(33, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_ASH)
	check(play_named(vetch_two, "entry_mark", 0, 0), "first of two rows for Vetch")
	check(play_named(vetch_two, "entry_mark", 1, 0), "second of two rows for Vetch")
	check(vetch_two.last_progress_gained == 4, "two rows still score")
	check(vetch_two.last_patience_loss == 1, "two rows leave Vetch's drop at 1")

	var vetch_all = Rules.scripted_encounter(33, 2, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_ASH)
	check(play_named(vetch_all, "entry_mark", 0, 0), "Vetch's top row is stamped")
	check(play_named(vetch_all, "entry_mark", 1, 0), "Vetch's middle row is stamped")
	check(vetch_all.phase == "play", "the third row is still open")
	check(play_named(vetch_all, "entry_mark", 2, 0), "Vetch receives the bottom-row stamp, the correct stamp")
	check(vetch_all.last_progress_gained == 6, "every row still scores for Vetch (%d)" % vetch_all.last_progress_gained)
	check(vetch_all.last_patience_loss == 0 and vetch_all.patience == 5, "every row keeps Vetch's patience")

	var vetch_short = Rules.scripted_encounter(33, 2, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_ASH)
	check(play_named(vetch_short, "entry_mark", 0, 0), "top row of a short seal")
	check(play_named(vetch_short, "entry_mark", 1, 0), "middle row of a short seal")
	check(play_named(vetch_short, "entry_mark", 1, 1), "a second middle stamp leaves the bottom row empty")
	check(vetch_short.last_patience_loss == 1, "a missing row keeps Vetch's drop at 1")

	var vetch_held = Rules.scripted_encounter(33, 2, ["hold"], 1, Rules.SHIFT_ASH)
	check(play_named(vetch_held, "hold", 0, 2), "hold in Vetch's column")
	check(vetch_held.last_patience_loss == 0 and vetch_held.patience == 5, "hold delays Vetch before the row seal")

	var vetch_missed = Rules.scripted_encounter(33, 2, ["hold"], 1, Rules.SHIFT_ASH)
	check(play_named(vetch_missed, "hold", 0, 0), "hold outside Vetch's column")
	check(vetch_missed.last_patience_loss == 1, "hold in another column does not spare Vetch")

	var vetch_muted = Rules.scripted_encounter(33, 2, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_ASH)
	check(play_named(vetch_muted, "entry_mark", 0, 0), "top row under a cancelled row seal")
	check(play_named(vetch_muted, "exemption", 1, 1), "exemption is placed on Vetch's middle row")
	check(vetch_muted.phase == "play", "Vetch's exemption leaves the turn open")
	check(play_named(vetch_muted, "entry_mark", 2, 2), "the bottom row is stamped while the seal is cancelled")
	check(vetch_muted.last_progress_gained == 5, "the stamps still score when the row seal is cancelled (%d)" % vetch_muted.last_progress_gained)
	check(vetch_muted.last_patience_loss == 1, "exemption keeps Vetch's drop at 1")

	var nim = Rules.scripted_encounter(34, 3, ["entry_mark", "duty"], 3, Rules.SHIFT_ASH)
	check(String(Rules.traveler(nim)["name"]) == "Nim Harth", "the ash watch's fourth form is Nim Harth")
	check(String(Rules.traveler(nim)["form_name"]) == "Tail Slip", "Nim brings the Tail Slip")
	check(String(Rules.traveler(nim)["rule_text"]) == "The last stamp in the queue scores twice.", "Nim's form states the queue-tail rule")
	check(Rules.preview_progress(nim, "duty", 2, 2) == 8, "preview doubles a lone bottom-row duty")
	check(Rules.preview_progress(nim, "duty", 0, 0) == 4, "preview doubles a lone top-row duty")
	check(play_named(nim, "entry_mark", 2, 2), "a later cell is filled before the preview")
	check(nim.phase == "play", "the tail stamp leaves the turn open")
	check(Rules.can_play(nim, 0, 2, 0), "rules accept an earlier duty as a placement")
	check(Rules.preview_progress(nim, "duty", 2, 0) == 4, "preview does not double a duty with a stamp later in the queue")
	check(Rules.preview_progress(nim, "duty", 0, 0) == 2, "preview does not double a top-row duty once a later stamp exists")

	var early = Rules.scripted_encounter(34, 3, ["duty", "entry_mark"], 2, Rules.SHIFT_ASH)
	check(play_named(early, "duty", 2, 0), "Nim receives a bottom-row duty, the wrong stamp")
	check(play_named(early, "entry_mark", 2, 1), "a stamp is placed later in that row")
	check(early.last_progress_gained == 8, "the earlier bottom-row duty is not doubled (%d)" % early.last_progress_gained)

	var tail = Rules.scripted_encounter(34, 3, ["duty"], 1, Rules.SHIFT_ASH)
	check(play_named(tail, "duty", 2, 2), "Nim receives a lone bottom-row duty, the correct stamp")
	check(tail.last_progress_gained == 8, "Nim doubles the last stamp (%d)" % tail.last_progress_gained)

	var split = Rules.scripted_encounter(34, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_ASH)
	check(play_named(split, "entry_mark", 0, 0), "the earlier entry mark")
	check(play_named(split, "entry_mark", 0, 1), "the later entry mark in that row")
	check(split.last_progress_gained == 6, "only the later entry mark is doubled (%d)" % split.last_progress_gained)

	var muted = Rules.scripted_encounter(34, 3, ["exemption", "duty"], 2, Rules.SHIFT_ASH)
	check(play_named(muted, "exemption", 2, 1), "exemption is placed on Nim's bottom row")
	check(muted.phase == "play", "Nim's exemption leaves the turn open")
	check(play_named(muted, "duty", 2, 2), "the tail duty follows the exemption")
	check(muted.last_progress_gained == 5, "exemption cancels Nim's doubling (%d)" % muted.last_progress_gained)

	var doubled_reply = Rules.scripted_encounter(34, 3, ["entry_mark", "reply"], 2, Rules.SHIFT_ASH)
	check(play_named(doubled_reply, "entry_mark", 1, 1), "entry mark sits above the reply")
	check(play_named(doubled_reply, "reply", 2, 1), "reply is the last stamp in the queue")
	check(doubled_reply.last_chain_count == 1, "the doubled reply still retriggers")
	check(doubled_reply.last_progress_gained == 6, "the tail reply scores twice and the earlier retrigger does not (%d)" % doubled_reply.last_progress_gained)

	var plain_reply = Rules.scripted_encounter(34, 3, ["entry_mark", "reply", "entry_mark"], 3, Rules.SHIFT_ASH)
	check(play_named(plain_reply, "entry_mark", 1, 1), "entry mark sits above a reply that is not last")
	check(play_named(plain_reply, "reply", 2, 1), "reply is placed before the last cell")
	check(play_named(plain_reply, "entry_mark", 2, 2), "a later stamp keeps the reply off the tail")
	check(plain_reply.last_chain_count == 1, "a reply that is not last still retriggers")
	check(plain_reply.last_progress_gained == 9, "the reply scores 1 and the later stamp is doubled (%d)" % plain_reply.last_progress_gained)

	var doubled_hold = Rules.scripted_encounter(34, 3, ["hold"], 1, Rules.SHIFT_ASH)
	check(play_named(doubled_hold, "hold", 2, 0), "hold is the last stamp in Nim's column")
	check(doubled_hold.last_progress_gained == 2, "the tail hold scores twice")
	check(doubled_hold.last_patience_loss == 0 and doubled_hold.patience == 5, "a doubled hold still delays Nim")

	var bram = Rules.scripted_encounter(5, 1, ["duty"], 1)
	check(play_named(bram, "duty", 2, 2), "Bram still receives a lone bottom-row duty")
	check(bram.last_progress_gained == 4, "Act 1 does not double the last stamp (%d)" % bram.last_progress_gained)
	var ada = Rules.scripted_encounter(5, 0, ["entry_mark", "entry_mark"], 2)
	check(play_named(ada, "entry_mark", 1, 0), "Ada receives the first middle-row stamp")
	check(play_named(ada, "entry_mark", 1, 2), "Ada receives the second middle-row stamp")
	check(ada.last_progress_gained == 4, "Act 1 does not yield for exactly two stamps (%d)" % ada.last_progress_gained)
	var cira = Rules.scripted_encounter(5, 2, ["entry_mark", "entry_mark", "entry_mark"], 3)
	check(play_named(cira, "entry_mark", 0, 0), "Cira's top row")
	check(play_named(cira, "entry_mark", 1, 0), "Cira's middle row")
	check(play_named(cira, "entry_mark", 2, 0), "Cira's bottom row")
	check(cira.last_patience_loss == 1, "Act 1 does not spare patience when every row is stamped")
	var moss = Rules.scripted_encounter(21, 0, ["duty"], 1, Rules.SHIFT_CLOSING)
	check(play_named(moss, "duty", 2, 1), "Moss still receives a lone bottom-row duty")
	check(moss.last_progress_gained == 4, "the closing bell does not double the last stamp (%d)" % moss.last_progress_gained)


func test_ash_watch_opens() -> void:
	check(Rules.ASH_WATCH.size() == 4, "the ash watch has four travelers")
	check(Rules.TRAVELERS.size() == 4 and String(Rules.TRAVELERS[0]["name"]) == "Ada Quill", "Act 1 still begins with Ada Quill")
	check(String(Rules.TRAVELERS[3]["name"]) == "Doss Kite", "Act 1 still ends with Doss Kite")
	check(Rules.LATE_SHIFT.size() == 4 and String(Rules.LATE_SHIFT[0]["name"]) == "Nell Parr", "the late shift still begins with Nell Parr")
	check(String(Rules.LATE_SHIFT[3]["name"]) == "Rue Calder", "the late shift still ends with Rue Calder")
	check(Rules.CLOSING_BELL.size() == 4 and String(Rules.CLOSING_BELL[0]["name"]) == "Moss Quen", "the closing bell still begins with Moss Quen")
	check(String(Rules.CLOSING_BELL[3]["name"]) == "Lumen Peck", "the closing bell still ends with Lumen Peck")
	var ash = Rules.new_run(77, Rules.SHIFT_ASH)
	check(ash.shift == Rules.SHIFT_ASH, "the ash watch is a separate night")
	check(String(Rules.traveler(ash)["name"]) == "Orla Fen", "the ash watch begins with Orla Fen")
	check(ash.hand.size() == Rules.HAND_SIZE, "the ash watch draws 5")
	check(ash.ink == Rules.BASE_INK, "the ash watch starts at 3 ink")
	check(ash.library.size() == Rules.STARTING_DECK.size(), "the ash watch deals the starting deck")
	check(ash.relic_id == "", "an earlier night's relic does not carry")
	check(ash.phase == "play", "the ash watch opens in play")
	var dealt: Array = []
	for iid in ash.hand:
		dealt.append(Rules.card_id_of(ash, int(iid)))
	var before = ash.library.size()
	ash.progress = 4
	ash.patience = 1
	Rules.restart_encounter(ash)
	check(ash.shift == Rules.SHIFT_ASH and ash.traveler_index == 0, "restart encounter stays on the ash watch")
	check(ash.progress == 0 and ash.patience == int(Rules.ASH_WATCH[0]["patience"]), "restart encounter resets Orla")
	check(ash.library.size() == before and ash.hand.size() == 5 and ash.phase == "play", "restart keeps the ash-watch deck and deals a hand")
	var redealt: Array = []
	for iid in ash.hand:
		redealt.append(Rules.card_id_of(ash, int(iid)))
	check(redealt == dealt, "restart deals Orla the same hand")

	var packed = load("res://game/main.tscn")
	var desk = packed.instantiate()
	root.add_child(desk)
	if desk.state == null:
		desk._ready()
	check(desk.state.shift == Rules.SHIFT_FIRST, "the desk still opens on Act 1")
	check(desk.ash_button.text == "Ash watch", "the desk offers the ash watch")
	check(desk.shift_button.text == "Late shift", "the desk still offers the late shift")
	check(desk.closing_button.text == "Closing bell", "the desk still offers the closing bell")
	desk.ash_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_ASH, "the desk can open the ash watch")
	check(String(Rules.traveler(desk.state)["name"]) == "Orla Fen", "the open desk shows Orla")
	check(String(desk.desk_label.text).begins_with("Ash watch"), "the desk title follows the ash watch")
	check(desk.meta_label.text.contains("Sealed Foot"), "the desk shows Orla's form")
	check(desk.ash_button.text == "First bell", "the ash watch can return to the first bell")
	check(desk.shift_button.text == "Late shift", "the late shift stays available from the ash watch")
	check(desk.closing_button.text == "Closing bell", "the closing bell stays available from the ash watch")
	desk._restart_act()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_ASH and String(Rules.traveler(desk.state)["name"]) == "Orla Fen", "restart act replays the ash watch")
	desk.ash_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the ash watch returns to Ada")
	desk._toggle_shift()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_LATE and String(Rules.traveler(desk.state)["name"]) == "Nell Parr", "the late shift still opens from the first bell")
	check(desk.ash_button.text == "Ash watch", "the late shift offers the ash watch")
	desk._begin_ash_watch()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_ASH and String(Rules.traveler(desk.state)["name"]) == "Orla Fen", "the late shift can open the ash watch")
	desk._toggle_closing()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_CLOSING and String(Rules.traveler(desk.state)["name"]) == "Moss Quen", "the ash watch can open the closing bell")
	check(desk.ash_button.text == "Ash watch", "the closing bell offers the ash watch")
	desk.ash_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_ASH and String(Rules.traveler(desk.state)["name"]) == "Orla Fen", "the closing bell can open the ash watch")
	desk._toggle_shift()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_LATE and String(Rules.traveler(desk.state)["name"]) == "Nell Parr", "the ash watch can open the late shift")
	desk._begin_first_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "first bell still returns to Ada")
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_ash = _button_named(desk, "Open the ash watch")
	check(victory_ash != null, "Act 1's victory desk offers the ash watch")
	if victory_ash != null:
		victory_ash.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_ASH and String(Rules.traveler(desk.state)["name"]) == "Orla Fen", "the victory desk opens the ash watch")
	root.remove_child(desk)
	desk.free()


func _button_named(node: Node, label: String) -> Button:
	if node is Button and String((node as Button).text) == label:
		return node
	for child in node.get_children():
		var found = _button_named(child, label)
		if found != null:
			return found
	return null


func test_policy_clears_ash_watch() -> void:
	var started = Time.get_ticks_msec()
	var state = Rules.new_run(12345, Rules.SHIFT_ASH)
	var steps = 0
	var seen = 0
	while state.phase != "victory":
		steps += 1
		if steps > 500 or state.phase == "defeat":
			check(false, "policy lost or stalled on the ash watch, seed 12345: " + Rules.debug_summary(state))
			return
		var action = Policy.choose(state)
		if not Rules.apply_action(state, action):
			check(false, "ash-watch policy action was rejected: %s / %s" % [str(action), Rules.debug_summary(state)])
			return
		if state.encounters_cleared != seen:
			seen = state.encounters_cleared
			print("cleared ash encounter %d after %d actions" % [seen, steps])
	var elapsed = Time.get_ticks_msec() - started
	check(state.encounters_cleared == 4, "policy cleared all 4 ash-watch encounters on seed 12345")
	check(state.phase == "victory", "ash watch ends in victory")
	check(state.shift == Rules.SHIFT_ASH, "the clear stayed on the ash watch")
	print("ash watch finished in %d actions, %d ms" % [steps, elapsed])


func test_gutter_lamp_rules() -> void:
	var ivo = Rules.scripted_encounter(41, 0, ["duty"], 3, Rules.SHIFT_GUTTER)
	check(String(Rules.traveler(ivo)["name"]) == "Ivo Dane", "the gutter lamp's first form is Ivo Dane")
	check(String(Rules.traveler(ivo)["form_name"]) == "Blank Spine", "Ivo brings the Blank Spine")
	check(String(Rules.traveler(ivo)["rule_text"]) == "Refuses stamps in column 2.", "Ivo's form states the spine rule")
	check(Rules.can_play(ivo, 0, 2, 1), "rules accept a column-2 duty as a placement")
	check(Rules.preview_progress(ivo, "duty", 2, 1) == 0, "preview rejects a column-2 duty for Ivo")
	check(Rules.preview_progress(ivo, "duty", 2, 0) == 4, "preview accepts a bottom-row duty outside column 2")
	check(Rules.preview_progress(ivo, "duty", 0, 0) == 2, "preview still reads Ivo's top row outside column 2")
	check(Rules.preview_progress(ivo, "duty", 0, 1) == 0, "preview rejects Ivo's top row when it is column 2")

	var refused = Rules.scripted_encounter(41, 0, ["duty"], 1, Rules.SHIFT_GUTTER)
	check(play_named(refused, "duty", 2, 1), "Ivo receives a column-2 duty, the wrong stamp")
	check(refused.last_progress_gained == 0, "Ivo refuses column 2 (%d)" % refused.last_progress_gained)
	check(refused.turn_number == 2 and refused.progress == 0, "the refused spine duty resolved and scored nothing")
	check(refused.last_patience_loss == 1, "a refused spine stamp still spends the turn")

	var accepted = Rules.scripted_encounter(41, 0, ["duty"], 1, Rules.SHIFT_GUTTER)
	check(play_named(accepted, "duty", 2, 2), "Ivo receives a bottom-row duty in column 3, the correct stamp")
	check(accepted.last_progress_gained == 4, "Ivo counts that duty (%d)" % accepted.last_progress_gained)

	var top = Rules.scripted_encounter(41, 0, ["duty"], 1, Rules.SHIFT_GUTTER)
	check(play_named(top, "duty", 0, 0), "Ivo receives a top-row duty outside column 2")
	check(top.last_progress_gained == 2, "Ivo does not refuse the top row (%d)" % top.last_progress_gained)

	var cleared = Rules.scripted_encounter(41, 0, ["exemption", "duty"], 2, Rules.SHIFT_GUTTER)
	check(play_named(cleared, "exemption", 0, 0), "exemption is placed on Ivo's top row")
	check(cleared.phase == "play", "Ivo's exemption leaves the turn open")
	check(play_named(cleared, "duty", 2, 1), "a column-2 duty follows the exemption")
	check(cleared.last_progress_gained == 5, "exemption lets Ivo's column 2 count (%d)" % cleared.last_progress_gained)

	var spine_exempt = Rules.scripted_encounter(41, 0, ["exemption", "duty"], 2, Rules.SHIFT_GUTTER)
	check(play_named(spine_exempt, "exemption", 0, 1), "exemption sits in column 2 on Ivo's top row")
	check(play_named(spine_exempt, "duty", 2, 1), "the later column-2 duty follows that exemption")
	check(spine_exempt.last_progress_gained == 5, "an exemption on the refused spine still cancels it (%d)" % spine_exempt.last_progress_gained)

	var still_blank = Rules.scripted_encounter(41, 0, ["exemption", "duty"], 2, Rules.SHIFT_GUTTER)
	check(play_named(still_blank, "exemption", 1, 0), "exemption sits off Ivo's top row")
	check(play_named(still_blank, "duty", 2, 1), "the column-2 duty stays refused")
	check(still_blank.last_progress_gained == 1, "an exemption off the top row does not open the spine (%d)" % still_blank.last_progress_gained)

	var refused_ripple = Rules.scripted_encounter(41, 0, ["entry_mark", "ripple"], 3, Rules.SHIFT_GUTTER)
	check(play_named(refused_ripple, "entry_mark", 1, 0), "entry mark is placed beside a column-2 ripple")
	check(refused_ripple.phase == "play", "the entry mark leaves the turn open")
	check(play_named(refused_ripple, "ripple", 1, 1), "ripple is placed on Ivo's spine")
	check(refused_ripple.last_chain_count == 1, "the refused ripple still retriggers")
	check(refused_ripple.last_progress_gained == 4, "the spine ripple scores 0 and the retrigger still pays (%d)" % refused_ripple.last_progress_gained)

	var refused_hold = Rules.scripted_encounter(41, 0, ["hold"], 1, Rules.SHIFT_GUTTER)
	check(play_named(refused_hold, "hold", 0, 1), "hold is placed in column 2, Ivo's lane")
	check(refused_hold.last_progress_gained == 0, "the refused hold grants no progress")
	check(refused_hold.last_patience_loss == 0 and refused_hold.patience == 5, "a refused hold still delays Ivo")

	var missed_hold = Rules.scripted_encounter(41, 0, ["hold"], 1, Rules.SHIFT_GUTTER)
	check(play_named(missed_hold, "hold", 1, 0), "hold outside Ivo's column")
	check(missed_hold.last_progress_gained == 1, "hold outside column 2 still scores")
	check(missed_hold.last_patience_loss == 1, "hold in another column does not delay Ivo")

	var sera_one = Rules.scripted_encounter(42, 1, ["entry_mark"], 1, Rules.SHIFT_GUTTER)
	check(String(Rules.traveler(sera_one)["name"]) == "Sera Dodd", "the gutter lamp's second form is Sera Dodd")
	check(String(Rules.traveler(sera_one)["form_name"]) == "Triad Chit", "Sera brings the Triad Chit")
	check(String(Rules.traveler(sera_one)["rule_text"]) == "Yields if every column is stamped.", "Sera's form states the column rule")
	check(play_named(sera_one, "entry_mark", 1, 1), "Sera receives one stamp, the wrong stamp")
	check(sera_one.last_progress_gained == 2, "one column does not make Sera yield (%d)" % sera_one.last_progress_gained)

	var sera_two = Rules.scripted_encounter(42, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_GUTTER)
	check(play_named(sera_two, "entry_mark", 0, 0), "first of two columns for Sera")
	check(play_named(sera_two, "entry_mark", 0, 2), "second of two columns, the spine still empty")
	check(sera_two.last_progress_gained == 4, "two columns do not make Sera yield (%d)" % sera_two.last_progress_gained)

	var sera_stack = Rules.scripted_encounter(42, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_GUTTER)
	check(play_named(sera_stack, "entry_mark", 0, 0), "first stamp of one column")
	check(play_named(sera_stack, "entry_mark", 1, 0), "second stamp of that column")
	check(play_named(sera_stack, "entry_mark", 2, 0), "a full column leaves the other columns empty")
	check(sera_stack.last_progress_gained == 6, "one full column does not make Sera yield (%d)" % sera_stack.last_progress_gained)

	var sera_triad = Rules.scripted_encounter(42, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_GUTTER)
	check(play_named(sera_triad, "entry_mark", 0, 0), "Sera's column 1 is stamped")
	check(play_named(sera_triad, "entry_mark", 1, 1), "Sera's column 2 is stamped")
	check(sera_triad.phase == "play", "the third column is still open")
	check(play_named(sera_triad, "entry_mark", 2, 2), "Sera receives the stamp that completes every column, the correct stamp")
	check(sera_triad.last_progress_gained == 10, "Sera yields +4 when every column is stamped (%d)" % sera_triad.last_progress_gained)

	var sera_row = Rules.scripted_encounter(42, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_GUTTER)
	check(play_named(sera_row, "entry_mark", 1, 0), "first stamp of a full middle row")
	check(play_named(sera_row, "entry_mark", 1, 1), "second stamp of a full middle row")
	check(play_named(sera_row, "entry_mark", 1, 2), "the middle row touches every column")
	check(sera_row.last_progress_gained == 10, "a full row yields because every column is stamped (%d)" % sera_row.last_progress_gained)

	var sera_kept = Rules.scripted_encounter(42, 1, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_GUTTER)
	check(play_named(sera_kept, "exemption", 0, 0), "exemption sits off Sera's middle row")
	check(play_named(sera_kept, "entry_mark", 1, 1), "column 2 under that exemption")
	check(play_named(sera_kept, "entry_mark", 2, 2), "column 3 under that exemption")
	check(sera_kept.last_progress_gained == 9, "every column still yields when exemption is not on the middle row (%d)" % sera_kept.last_progress_gained)

	var sera_muted = Rules.scripted_encounter(42, 1, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_GUTTER)
	check(play_named(sera_muted, "exemption", 1, 0), "exemption is placed on Sera's middle row")
	check(sera_muted.phase == "play", "Sera's exemption leaves the turn open")
	check(play_named(sera_muted, "entry_mark", 0, 1), "column 2 under a cancelled yield")
	check(play_named(sera_muted, "entry_mark", 2, 2), "column 3 under a cancelled yield")
	check(sera_muted.last_progress_gained == 5, "exemption cancels Sera's yield (%d)" % sera_muted.last_progress_gained)

	var sera_held = Rules.scripted_encounter(42, 1, ["hold"], 1, Rules.SHIFT_GUTTER)
	check(play_named(sera_held, "hold", 1, 0), "hold in Sera's column")
	check(sera_held.last_progress_gained == 1, "one hold does not complete Sera's columns")
	check(sera_held.last_patience_loss == 0 and sera_held.patience == 5, "hold delays Sera")

	var wren_empty = Rules.scripted_encounter(43, 2, ["duty"], 1, Rules.SHIFT_GUTTER)
	check(String(Rules.traveler(wren_empty)["name"]) == "Wren Hale", "the gutter lamp's third form is Wren Hale")
	check(String(Rules.traveler(wren_empty)["form_name"]) == "Open Margin", "Wren brings the Open Margin")
	check(String(Rules.traveler(wren_empty)["rule_text"]) == "Patience drops twice when column 1 is empty.", "Wren's form states the margin rule")
	check(play_named(wren_empty, "duty", 2, 2), "Wren receives a bottom-row duty outside column 1, the wrong stamp")
	check(wren_empty.last_progress_gained == 4, "the bottom-row duty still scores for Wren")
	check(wren_empty.last_patience_loss == 2, "an empty column 1 drops Wren's patience by 2 (%d)" % wren_empty.last_patience_loss)
	check(wren_empty.patience == 3, "Wren's patience is 3 after the double drop")

	var wren_marked = Rules.scripted_encounter(43, 2, ["entry_mark"], 1, Rules.SHIFT_GUTTER)
	check(play_named(wren_marked, "entry_mark", 0, 0), "Wren receives a stamp in column 1, the correct stamp")
	check(wren_marked.last_progress_gained == 2, "the column-1 stamp scores for Wren")
	check(wren_marked.last_patience_loss == 1, "column 1 keeps Wren's drop at 1")

	var wren_held = Rules.scripted_encounter(43, 2, ["hold"], 1, Rules.SHIFT_GUTTER)
	check(play_named(wren_held, "hold", 0, 2), "hold in Wren's column while column 1 is empty")
	check(wren_held.last_patience_loss == 0 and wren_held.patience == 5, "hold delays Wren before the double drop")

	var wren_missed = Rules.scripted_encounter(43, 2, ["hold"], 1, Rules.SHIFT_GUTTER)
	check(play_named(wren_missed, "hold", 0, 1), "hold outside Wren's column and outside column 1")
	check(wren_missed.last_patience_loss == 2, "hold in another column does not spare Wren")

	var wren_spared = Rules.scripted_encounter(43, 2, ["exemption"], 1, Rules.SHIFT_GUTTER)
	check(play_named(wren_spared, "exemption", 2, 2), "exemption on Wren's bottom row, column 1 still empty")
	check(wren_spared.last_patience_loss == 1, "exemption keeps Wren's drop at 1")
	check(wren_spared.last_progress_gained == 1, "the exemption itself scores 1")

	var wren_open = Rules.scripted_encounter(43, 2, ["exemption"], 1, Rules.SHIFT_GUTTER)
	check(play_named(wren_open, "exemption", 0, 1), "exemption sits off Wren's bottom row")
	check(wren_open.last_patience_loss == 2, "an exemption off the bottom row leaves the double drop")

	var kit = Rules.scripted_encounter(44, 3, ["entry_mark", "entry_mark"], 3, Rules.SHIFT_GUTTER)
	check(String(Rules.traveler(kit)["name"]) == "Kit Yarrow", "the gutter lamp's fourth form is Kit Yarrow")
	check(String(Rules.traveler(kit)["form_name"]) == "Neighbor Slip", "Kit brings the Neighbor Slip")
	check(String(Rules.traveler(kit)["rule_text"]) == "Ignores a stamp with an orthogonal neighbor.", "Kit's form states the neighbor rule")
	check(Rules.preview_progress(kit, "entry_mark", 1, 1) == 2, "preview accepts a lone center for Kit")
	check(play_named(kit, "entry_mark", 1, 0), "a stamp is placed left of center")
	check(kit.phase == "play", "the first neighbor leaves the turn open")
	check(Rules.can_play(kit, 0, 1, 1), "rules accept the neighboring cell as a placement")
	check(Rules.preview_progress(kit, "entry_mark", 1, 1) == 0, "preview rejects a stamp beside another stamp")
	check(Rules.preview_progress(kit, "entry_mark", 0, 2) == 2, "preview accepts a stamp that does not share a side")
	check(play_named(kit, "entry_mark", 1, 1), "Kit receives a stamp with an orthogonal neighbor, the wrong stamp")
	check(kit.last_progress_gained == 0, "Kit ignores both stamps that share a side (%d)" % kit.last_progress_gained)

	var kit_lone = Rules.scripted_encounter(44, 3, ["duty"], 1, Rules.SHIFT_GUTTER)
	check(play_named(kit_lone, "duty", 2, 2), "Kit receives a lone bottom-row duty, the correct stamp")
	check(kit_lone.last_progress_gained == 4, "Kit counts a lone stamp once (%d)" % kit_lone.last_progress_gained)

	var kit_corner = Rules.scripted_encounter(44, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_GUTTER)
	check(play_named(kit_corner, "entry_mark", 0, 0), "first stamp of a diagonal pair")
	check(play_named(kit_corner, "entry_mark", 1, 1), "the second stamp meets the first only at a corner")
	check(kit_corner.last_progress_gained == 4, "Kit counts stamps that only meet at a corner (%d)" % kit_corner.last_progress_gained)

	var kit_below = Rules.scripted_encounter(44, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_GUTTER)
	check(play_named(kit_below, "entry_mark", 0, 1), "a stamp is placed above another cell")
	check(play_named(kit_below, "entry_mark", 1, 1), "the stamp directly below shares a side")
	check(kit_below.last_progress_gained == 0, "Kit ignores a stamp directly below another (%d)" % kit_below.last_progress_gained)

	var kit_freed = Rules.scripted_encounter(44, 3, ["exemption", "entry_mark"], 2, Rules.SHIFT_GUTTER)
	check(play_named(kit_freed, "exemption", 1, 1), "exemption is placed on Kit's middle row")
	check(kit_freed.phase == "play", "Kit's exemption leaves the turn open")
	check(Rules.preview_progress(kit_freed, "entry_mark", 1, 0) == 2, "preview counts a neighbor once the rule is cancelled")
	check(play_named(kit_freed, "entry_mark", 1, 0), "a neighboring stamp follows the exemption")
	check(kit_freed.last_progress_gained == 3, "exemption lets Kit's neighbors count (%d)" % kit_freed.last_progress_gained)

	var kit_kept = Rules.scripted_encounter(44, 3, ["exemption", "entry_mark"], 2, Rules.SHIFT_GUTTER)
	check(play_named(kit_kept, "exemption", 0, 0), "exemption sits off Kit's middle row")
	check(play_named(kit_kept, "entry_mark", 0, 1), "a neighbor beside that exemption")
	check(kit_kept.last_progress_gained == 0, "an exemption off the middle row does not let neighbors count (%d)" % kit_kept.last_progress_gained)

	var kit_echo = Rules.scripted_encounter(44, 3, ["echo", "entry_mark"], 2, Rules.SHIFT_GUTTER)
	check(play_named(kit_echo, "echo", 0, 0), "echo is placed above an entry mark")
	check(kit_echo.phase == "play", "the echo leaves the turn open")
	check(play_named(kit_echo, "entry_mark", 1, 0), "entry mark is placed under the echo")
	check(kit_echo.last_chain_count == 1, "the ignored echo still retriggers")
	check(kit_echo.last_progress_gained == 0, "both ends of the retrigger share a side and score 0 (%d)" % kit_echo.last_progress_gained)

	var kit_diagonal = Rules.scripted_encounter(44, 3, ["echo", "entry_mark"], 2, Rules.SHIFT_GUTTER)
	check(play_named(kit_diagonal, "echo", 0, 0), "echo is placed on a corner")
	check(play_named(kit_diagonal, "entry_mark", 1, 1), "entry mark meets the echo only at a corner")
	check(kit_diagonal.last_chain_count == 0, "echo does not retrigger a diagonal cell")
	check(kit_diagonal.last_progress_gained == 3, "a diagonal pair still scores for Kit (%d)" % kit_diagonal.last_progress_gained)

	var kit_hold = Rules.scripted_encounter(44, 3, ["hold", "entry_mark"], 2, Rules.SHIFT_GUTTER)
	check(play_named(kit_hold, "hold", 2, 0), "hold is placed in Kit's column")
	check(play_named(kit_hold, "entry_mark", 2, 1), "a neighbor is placed beside the hold")
	check(kit_hold.last_progress_gained == 0, "the neighboring hold grants no progress")
	check(kit_hold.last_patience_loss == 0 and kit_hold.patience == 5, "an ignored hold still delays Kit")

	var bram = Rules.scripted_encounter(5, 1, ["entry_mark"], 1)
	check(play_named(bram, "entry_mark", 1, 1), "Bram still receives a column-2 stamp")
	check(bram.last_progress_gained == 6, "Act 1 does not refuse column 2 (%d)" % bram.last_progress_gained)
	var ada = Rules.scripted_encounter(5, 0, ["entry_mark", "entry_mark"], 2)
	check(play_named(ada, "entry_mark", 1, 0), "Ada receives the first of two neighbors")
	check(play_named(ada, "entry_mark", 1, 1), "Ada receives the stamp beside it")
	check(ada.last_progress_gained == 4, "Act 1 does not ignore orthogonal neighbors (%d)" % ada.last_progress_gained)
	var sol = Rules.scripted_encounter(11, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LATE)
	check(play_named(sol, "entry_mark", 0, 0), "Sol's falling diagonal, top")
	check(play_named(sol, "entry_mark", 1, 1), "Sol's falling diagonal, center")
	check(play_named(sol, "entry_mark", 2, 2), "Sol's falling diagonal, bottom")
	check(sol.last_progress_gained == 6, "the late shift does not yield for every column (%d)" % sol.last_progress_gained)
	var kel = Rules.scripted_encounter(22, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_CLOSING)
	check(play_named(kel, "entry_mark", 0, 0), "Kel's column 1")
	check(play_named(kel, "entry_mark", 1, 1), "Kel's column 2")
	check(play_named(kel, "entry_mark", 2, 2), "Kel's column 3")
	check(kel.last_progress_gained == 10, "the closing bell yields once for the margins (%d)" % kel.last_progress_gained)
	var lumen = Rules.scripted_encounter(24, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_CLOSING)
	check(play_named(lumen, "entry_mark", 1, 0), "Lumen receives a side stamp")
	check(play_named(lumen, "entry_mark", 1, 1), "Lumen receives the stamp beside it")
	check(lumen.last_progress_gained == 4, "the closing bell still counts stamps that share a side (%d)" % lumen.last_progress_gained)
	var cira = Rules.scripted_encounter(5, 2, ["entry_mark"], 1)
	check(play_named(cira, "entry_mark", 0, 0), "Cira receives a column-1 stamp on an empty bottom row")
	check(cira.last_patience_loss == 2, "Act 1 still drops twice for an empty bottom row")


func test_gutter_lamp_opens() -> void:
	check(Rules.GUTTER_LAMP.size() == 4, "the gutter lamp has four travelers")
	check(Rules.TRAVELERS.size() == 4 and String(Rules.TRAVELERS[0]["name"]) == "Ada Quill", "Act 1 still begins with Ada Quill")
	check(String(Rules.TRAVELERS[3]["name"]) == "Doss Kite", "Act 1 still ends with Doss Kite")
	check(Rules.LATE_SHIFT.size() == 4 and String(Rules.LATE_SHIFT[0]["name"]) == "Nell Parr", "the late shift still begins with Nell Parr")
	check(String(Rules.LATE_SHIFT[3]["name"]) == "Rue Calder", "the late shift still ends with Rue Calder")
	check(Rules.CLOSING_BELL.size() == 4 and String(Rules.CLOSING_BELL[0]["name"]) == "Moss Quen", "the closing bell still begins with Moss Quen")
	check(String(Rules.CLOSING_BELL[3]["name"]) == "Lumen Peck", "the closing bell still ends with Lumen Peck")
	check(Rules.ASH_WATCH.size() == 4 and String(Rules.ASH_WATCH[0]["name"]) == "Orla Fen", "the ash watch still begins with Orla Fen")
	check(String(Rules.ASH_WATCH[3]["name"]) == "Nim Harth", "the ash watch still ends with Nim Harth")
	var gutter = Rules.new_run(77, Rules.SHIFT_GUTTER)
	check(gutter.shift == Rules.SHIFT_GUTTER, "the gutter lamp is a separate night")
	check(String(Rules.traveler(gutter)["name"]) == "Ivo Dane", "the gutter lamp begins with Ivo Dane")
	check(gutter.hand.size() == Rules.HAND_SIZE, "the gutter lamp draws 5")
	check(gutter.ink == Rules.BASE_INK, "the gutter lamp starts at 3 ink")
	check(gutter.library.size() == Rules.STARTING_DECK.size(), "the gutter lamp deals the starting deck")
	check(gutter.relic_id == "", "an earlier night's relic does not carry")
	check(gutter.phase == "play", "the gutter lamp opens in play")
	var dealt: Array = []
	for iid in gutter.hand:
		dealt.append(Rules.card_id_of(gutter, int(iid)))
	var before = gutter.library.size()
	gutter.progress = 4
	gutter.patience = 1
	Rules.restart_encounter(gutter)
	check(gutter.shift == Rules.SHIFT_GUTTER and gutter.traveler_index == 0, "restart encounter stays on the gutter lamp")
	check(gutter.progress == 0 and gutter.patience == int(Rules.GUTTER_LAMP[0]["patience"]), "restart encounter resets Ivo")
	check(gutter.library.size() == before and gutter.hand.size() == 5 and gutter.phase == "play", "restart keeps the gutter-lamp deck and deals a hand")
	var redealt: Array = []
	for iid in gutter.hand:
		redealt.append(Rules.card_id_of(gutter, int(iid)))
	check(redealt == dealt, "restart deals Ivo the same hand")

	var packed = load("res://game/main.tscn")
	var desk = packed.instantiate()
	root.add_child(desk)
	if desk.state == null:
		desk._ready()
	check(desk.state.shift == Rules.SHIFT_FIRST, "the desk still opens on Act 1")
	check(desk.gutter_button.text == "Gutter lamp", "the desk offers the gutter lamp")
	check(desk.shift_button.text == "Late shift", "the desk still offers the late shift")
	check(desk.closing_button.text == "Closing bell", "the desk still offers the closing bell")
	check(desk.ash_button.text == "Ash watch", "the desk still offers the ash watch")
	desk.gutter_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_GUTTER, "the desk can open the gutter lamp")
	check(String(Rules.traveler(desk.state)["name"]) == "Ivo Dane", "the open desk shows Ivo")
	check(String(desk.desk_label.text).begins_with("Gutter lamp"), "the desk title follows the gutter lamp")
	check(desk.meta_label.text.contains("Blank Spine"), "the desk shows Ivo's form")
	check(desk.gutter_button.text == "First bell", "the gutter lamp can return to the first bell")
	check(desk.shift_button.text == "Late shift", "the late shift stays available from the gutter lamp")
	check(desk.closing_button.text == "Closing bell", "the closing bell stays available from the gutter lamp")
	check(desk.ash_button.text == "Ash watch", "the ash watch stays available from the gutter lamp")
	desk._restart_act()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_GUTTER and String(Rules.traveler(desk.state)["name"]) == "Ivo Dane", "restart act replays the gutter lamp")
	desk.gutter_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the gutter lamp returns to Ada")
	desk._toggle_shift()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_LATE and String(Rules.traveler(desk.state)["name"]) == "Nell Parr", "the late shift still opens from the first bell")
	check(desk.gutter_button.text == "Gutter lamp", "the late shift offers the gutter lamp")
	desk._begin_gutter_lamp()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_GUTTER and String(Rules.traveler(desk.state)["name"]) == "Ivo Dane", "the late shift can open the gutter lamp")
	desk._toggle_closing()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_CLOSING and String(Rules.traveler(desk.state)["name"]) == "Moss Quen", "the gutter lamp can open the closing bell")
	check(desk.gutter_button.text == "Gutter lamp", "the closing bell offers the gutter lamp")
	desk.gutter_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_GUTTER and String(Rules.traveler(desk.state)["name"]) == "Ivo Dane", "the closing bell can open the gutter lamp")
	desk._toggle_ash()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_ASH and String(Rules.traveler(desk.state)["name"]) == "Orla Fen", "the gutter lamp can open the ash watch")
	check(desk.gutter_button.text == "Gutter lamp", "the ash watch offers the gutter lamp")
	desk._begin_gutter_lamp()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_GUTTER and String(Rules.traveler(desk.state)["name"]) == "Ivo Dane", "the ash watch can open the gutter lamp")
	desk._toggle_shift()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_LATE and String(Rules.traveler(desk.state)["name"]) == "Nell Parr", "the gutter lamp can open the late shift")
	desk._begin_first_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "first bell still returns to Ada")
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_gutter = _button_named(desk, "Open the gutter lamp")
	check(victory_gutter != null, "Act 1's victory desk offers the gutter lamp")
	if victory_gutter != null:
		victory_gutter.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_GUTTER and String(Rules.traveler(desk.state)["name"]) == "Ivo Dane", "the victory desk opens the gutter lamp")
	root.remove_child(desk)
	desk.free()


func test_policy_clears_gutter_lamp() -> void:
	var started = Time.get_ticks_msec()
	var state = Rules.new_run(12345, Rules.SHIFT_GUTTER)
	var steps = 0
	var seen = 0
	while state.phase != "victory":
		steps += 1
		if steps > 500 or state.phase == "defeat":
			check(false, "policy lost or stalled on the gutter lamp, seed 12345: " + Rules.debug_summary(state))
			return
		var action = Policy.choose(state)
		if not Rules.apply_action(state, action):
			check(false, "gutter-lamp policy action was rejected: %s / %s" % [str(action), Rules.debug_summary(state)])
			return
		if state.encounters_cleared != seen:
			seen = state.encounters_cleared
			print("cleared gutter encounter %d after %d actions" % [seen, steps])
	var elapsed = Time.get_ticks_msec() - started
	check(state.encounters_cleared == 4, "policy cleared all 4 gutter-lamp encounters on seed 12345")
	check(state.phase == "victory", "gutter lamp ends in victory")
	check(state.shift == Rules.SHIFT_GUTTER, "the clear stayed on the gutter lamp")
	print("gutter lamp finished in %d actions, %d ms" % [steps, elapsed])


func test_vellum_bell_rules() -> void:
	var edda = Rules.scripted_encounter(51, 0, ["duty"], 3, Rules.SHIFT_VELLUM)
	check(String(Rules.traveler(edda)["name"]) == "Edda Voss", "the vellum bell's first form is Edda Voss")
	check(String(Rules.traveler(edda)["form_name"]) == "Quiet Center", "Edda brings the Quiet Center")
	check(String(Rules.traveler(edda)["rule_text"]) == "Refuses the center cell.", "Edda's form states the center rule")
	check(Rules.can_play(edda, 0, 1, 1), "rules accept a center duty as a placement")
	check(Rules.preview_progress(edda, "duty", 1, 1) == 0, "preview rejects the center for Edda")
	check(Rules.preview_progress(edda, "duty", 2, 0) == 4, "preview accepts a bottom-row duty outside the center")
	check(Rules.preview_progress(edda, "duty", 1, 0) == 2, "preview accepts the middle row outside the center")
	check(Rules.preview_progress(edda, "duty", 0, 1) == 2, "preview accepts column 2 outside the center")

	var refused = Rules.scripted_encounter(51, 0, ["duty"], 1, Rules.SHIFT_VELLUM)
	check(play_named(refused, "duty", 1, 1), "Edda receives a center duty, the wrong stamp")
	check(refused.last_progress_gained == 0, "Edda refuses the center cell (%d)" % refused.last_progress_gained)
	check(refused.turn_number == 2 and refused.progress == 0, "the refused center duty resolved and scored nothing")
	check(refused.last_patience_loss == 1, "a refused center stamp still spends the turn")

	var accepted = Rules.scripted_encounter(51, 0, ["duty"], 1, Rules.SHIFT_VELLUM)
	check(play_named(accepted, "duty", 2, 2), "Edda receives a bottom-row duty in column 3, the correct stamp")
	check(accepted.last_progress_gained == 4, "Edda counts that duty (%d)" % accepted.last_progress_gained)

	var beside = Rules.scripted_encounter(51, 0, ["duty"], 1, Rules.SHIFT_VELLUM)
	check(play_named(beside, "duty", 1, 2), "Edda receives a middle-row duty outside the center")
	check(beside.last_progress_gained == 2, "Edda does not refuse the rest of the middle row (%d)" % beside.last_progress_gained)

	var spine = Rules.scripted_encounter(51, 0, ["duty"], 1, Rules.SHIFT_VELLUM)
	check(play_named(spine, "duty", 0, 1), "Edda receives a top-row duty in column 2")
	check(spine.last_progress_gained == 2, "Edda does not refuse the rest of column 2 (%d)" % spine.last_progress_gained)

	var cleared = Rules.scripted_encounter(51, 0, ["exemption", "duty"], 2, Rules.SHIFT_VELLUM)
	check(play_named(cleared, "exemption", 1, 0), "exemption is placed on Edda's middle row")
	check(cleared.phase == "play", "Edda's exemption leaves the turn open")
	check(play_named(cleared, "duty", 1, 1), "a center duty follows the exemption")
	check(cleared.last_progress_gained == 3, "exemption lets Edda's center count (%d)" % cleared.last_progress_gained)

	var center_exempt = Rules.scripted_encounter(51, 0, ["exemption", "duty"], 2, Rules.SHIFT_VELLUM)
	check(play_named(center_exempt, "exemption", 1, 1), "exemption sits in the center on Edda's middle row")
	check(play_named(center_exempt, "duty", 2, 1), "a bottom-row duty follows that exemption")
	check(center_exempt.last_progress_gained == 5, "an exemption in the refused center still cancels it (%d)" % center_exempt.last_progress_gained)

	var still_quiet = Rules.scripted_encounter(51, 0, ["exemption", "duty"], 2, Rules.SHIFT_VELLUM)
	check(play_named(still_quiet, "exemption", 0, 0), "exemption sits off Edda's middle row")
	check(play_named(still_quiet, "duty", 1, 1), "the center duty stays refused")
	check(still_quiet.last_progress_gained == 1, "an exemption off the middle row does not open the center (%d)" % still_quiet.last_progress_gained)

	var refused_ripple = Rules.scripted_encounter(51, 0, ["entry_mark", "ripple"], 3, Rules.SHIFT_VELLUM)
	check(play_named(refused_ripple, "entry_mark", 1, 0), "entry mark is placed beside the center")
	check(refused_ripple.phase == "play", "the entry mark leaves the turn open")
	check(play_named(refused_ripple, "ripple", 1, 1), "ripple is placed in Edda's center")
	check(refused_ripple.last_chain_count == 1, "the refused ripple still retriggers")
	check(refused_ripple.last_progress_gained == 4, "the center ripple scores 0 and the retrigger still pays (%d)" % refused_ripple.last_progress_gained)

	var refused_hold = Rules.scripted_encounter(51, 0, ["hold"], 1, Rules.SHIFT_VELLUM)
	check(play_named(refused_hold, "hold", 1, 1), "hold is placed in the center, Edda's lane")
	check(refused_hold.last_progress_gained == 0, "the refused hold grants no progress")
	check(refused_hold.last_patience_loss == 0 and refused_hold.patience == 5, "a refused hold still delays Edda")

	var missed_hold = Rules.scripted_encounter(51, 0, ["hold"], 1, Rules.SHIFT_VELLUM)
	check(play_named(missed_hold, "hold", 1, 0), "hold outside Edda's column")
	check(missed_hold.last_progress_gained == 1, "hold outside column 2 still scores")
	check(missed_hold.last_patience_loss == 1, "hold in another column does not delay Edda")

	var rho_one = Rules.scripted_encounter(52, 1, ["entry_mark"], 1, Rules.SHIFT_VELLUM)
	check(String(Rules.traveler(rho_one)["name"]) == "Rho Tallow", "the vellum bell's second form is Rho Tallow")
	check(String(Rules.traveler(rho_one)["form_name"]) == "Corner Meet", "Rho brings the Corner Meet")
	check(String(Rules.traveler(rho_one)["rule_text"]) == "Yields if two stamps meet at a corner.", "Rho's form states the corner rule")
	check(play_named(rho_one, "entry_mark", 1, 1), "Rho receives one stamp, the wrong stamp")
	check(rho_one.last_progress_gained == 2, "one stamp does not make Rho yield (%d)" % rho_one.last_progress_gained)

	var rho_side = Rules.scripted_encounter(52, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_VELLUM)
	check(play_named(rho_side, "entry_mark", 1, 0), "first of two stamps that share a side")
	check(play_named(rho_side, "entry_mark", 1, 1), "the second stamp shares a side, not a corner")
	check(rho_side.last_progress_gained == 4, "a shared side does not make Rho yield (%d)" % rho_side.last_progress_gained)

	var rho_long = Rules.scripted_encounter(52, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_VELLUM)
	check(play_named(rho_long, "entry_mark", 0, 0), "first stamp of a longer diagonal")
	check(play_named(rho_long, "entry_mark", 2, 2), "the second stamp is two steps away")
	check(rho_long.last_progress_gained == 4, "a longer diagonal does not meet at a corner (%d)" % rho_long.last_progress_gained)

	var rho_row = Rules.scripted_encounter(52, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_VELLUM)
	check(play_named(rho_row, "entry_mark", 0, 0), "first stamp of a full top row")
	check(play_named(rho_row, "entry_mark", 0, 1), "second stamp of a full top row")
	check(play_named(rho_row, "entry_mark", 0, 2), "a full row has no corner pair")
	check(rho_row.last_progress_gained == 6, "a full row does not make Rho yield (%d)" % rho_row.last_progress_gained)

	var rho_column = Rules.scripted_encounter(52, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_VELLUM)
	check(play_named(rho_column, "entry_mark", 0, 0), "first stamp of one column")
	check(play_named(rho_column, "entry_mark", 1, 0), "second stamp of that column")
	check(play_named(rho_column, "entry_mark", 2, 0), "a full column has no corner pair")
	check(rho_column.last_progress_gained == 6, "one full column does not make Rho yield (%d)" % rho_column.last_progress_gained)

	var rho_corner = Rules.scripted_encounter(52, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_VELLUM)
	check(play_named(rho_corner, "entry_mark", 0, 0), "Rho's top-left stamp")
	check(rho_corner.phase == "play", "the corner pair is still open")
	check(play_named(rho_corner, "entry_mark", 1, 1), "Rho receives the stamp that meets it at a corner, the correct stamp")
	check(rho_corner.last_progress_gained == 8, "Rho yields +4 when two stamps meet at a corner (%d)" % rho_corner.last_progress_gained)

	var rho_once = Rules.scripted_encounter(52, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_VELLUM)
	check(play_named(rho_once, "entry_mark", 0, 0), "first stamp of a three-cell diagonal")
	check(play_named(rho_once, "entry_mark", 1, 1), "second stamp of a three-cell diagonal")
	check(play_named(rho_once, "entry_mark", 2, 2), "third stamp of a three-cell diagonal")
	check(rho_once.last_progress_gained == 10, "Rho yields once for several corner pairs (%d)" % rho_once.last_progress_gained)

	var rho_mixed = Rules.scripted_encounter(52, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_VELLUM)
	check(play_named(rho_mixed, "entry_mark", 0, 0), "a corner stamp that also has a side neighbor")
	check(play_named(rho_mixed, "entry_mark", 0, 1), "the side neighbor")
	check(play_named(rho_mixed, "entry_mark", 1, 1), "the stamp that meets the first at a corner")
	check(rho_mixed.last_progress_gained == 10, "a shared side does not cancel Rho's corner (%d)" % rho_mixed.last_progress_gained)

	var rho_kept = Rules.scripted_encounter(52, 1, ["exemption", "entry_mark"], 2, Rules.SHIFT_VELLUM)
	check(play_named(rho_kept, "exemption", 1, 1), "exemption sits off Rho's top row")
	check(play_named(rho_kept, "entry_mark", 0, 0), "a corner partner for that exemption")
	check(rho_kept.last_progress_gained == 7, "a corner still yields when exemption is not on the top row (%d)" % rho_kept.last_progress_gained)

	var rho_muted = Rules.scripted_encounter(52, 1, ["exemption", "entry_mark"], 2, Rules.SHIFT_VELLUM)
	check(play_named(rho_muted, "exemption", 0, 0), "exemption is placed on Rho's top row")
	check(rho_muted.phase == "play", "Rho's exemption leaves the turn open")
	check(play_named(rho_muted, "entry_mark", 1, 1), "a corner partner under a cancelled yield")
	check(rho_muted.last_progress_gained == 3, "exemption cancels Rho's yield (%d)" % rho_muted.last_progress_gained)

	var rho_band = Rules.scripted_encounter(52, 1, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_VELLUM)
	check(play_named(rho_band, "exemption", 0, 1), "exemption on the top row, outside the corner pair")
	check(play_named(rho_band, "entry_mark", 1, 0), "first stamp of a corner pair under that exemption")
	check(play_named(rho_band, "entry_mark", 2, 1), "second stamp of that corner pair")
	check(rho_band.last_progress_gained == 5, "exemption on the top row cancels a corner elsewhere (%d)" % rho_band.last_progress_gained)

	var rho_held = Rules.scripted_encounter(52, 1, ["hold"], 1, Rules.SHIFT_VELLUM)
	check(play_named(rho_held, "hold", 2, 0), "hold in Rho's column")
	check(rho_held.last_progress_gained == 1, "one hold does not meet Rho at a corner")
	check(rho_held.last_patience_loss == 0 and rho_held.patience == 5, "hold delays Rho")

	var nessa_short = Rules.scripted_encounter(53, 2, ["duty"], 1, Rules.SHIFT_VELLUM)
	check(String(Rules.traveler(nessa_short)["name"]) == "Nessa Brin", "the vellum bell's third form is Nessa Brin")
	check(String(Rules.traveler(nessa_short)["form_name"]) == "Row Toll", "Nessa brings the Row Toll")
	check(String(Rules.traveler(nessa_short)["rule_text"]) == "Patience drops once for each empty row.", "Nessa's form states the row toll")
	check(play_named(nessa_short, "duty", 2, 2), "Nessa receives one bottom-row duty, the wrong stamp")
	check(nessa_short.last_progress_gained == 4, "the bottom-row duty still scores for Nessa")
	check(nessa_short.last_patience_loss == 2, "two empty rows drop Nessa's patience by 2 (%d)" % nessa_short.last_patience_loss)
	check(nessa_short.patience == 3, "Nessa's patience is 3 after the two-row toll")

	var nessa_full = Rules.scripted_encounter(53, 2, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_VELLUM)
	check(play_named(nessa_full, "entry_mark", 0, 0), "Nessa's top row is stamped")
	check(play_named(nessa_full, "entry_mark", 1, 1), "Nessa's middle row is stamped")
	check(nessa_full.phase == "play", "the last empty row is still open")
	check(play_named(nessa_full, "entry_mark", 2, 2), "Nessa receives the stamp that fills every row, the correct stamp")
	check(nessa_full.last_progress_gained == 6, "three rows still score for Nessa")
	check(nessa_full.last_patience_loss == 0 and nessa_full.patience == 5, "every row keeps Nessa's patience")

	var nessa_gap = Rules.scripted_encounter(53, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_VELLUM)
	check(play_named(nessa_gap, "entry_mark", 0, 0), "Nessa's top row")
	check(play_named(nessa_gap, "entry_mark", 2, 2), "Nessa's bottom row, the middle still empty")
	check(nessa_gap.last_patience_loss == 1, "one empty row drops Nessa's patience by 1")

	var nessa_stack = Rules.scripted_encounter(53, 2, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_VELLUM)
	check(play_named(nessa_stack, "entry_mark", 2, 0), "first stamp of one row")
	check(play_named(nessa_stack, "entry_mark", 2, 1), "second stamp of that row")
	check(play_named(nessa_stack, "entry_mark", 2, 2), "a full row leaves two rows empty")
	check(nessa_stack.last_progress_gained == 6, "a stacked row still scores")
	check(nessa_stack.last_patience_loss == 2, "a stacked row does not spare the other rows")

	var nessa_blank = Rules.scripted_encounter(53, 2, ["entry_mark"], 1, Rules.SHIFT_VELLUM)
	Rules.end_turn(nessa_blank)
	check(nessa_blank.last_progress_gained == 0, "an empty form scores nothing")
	check(nessa_blank.last_patience_loss == 3, "three empty rows drop Nessa's patience by 3 (%d)" % nessa_blank.last_patience_loss)

	var nessa_spared = Rules.scripted_encounter(53, 2, ["exemption"], 1, Rules.SHIFT_VELLUM)
	check(play_named(nessa_spared, "exemption", 2, 0), "exemption on Nessa's bottom row, two rows still empty")
	check(nessa_spared.last_patience_loss == 1, "exemption keeps Nessa's drop at 1")
	check(nessa_spared.last_progress_gained == 1, "the exemption itself scores 1")

	var nessa_open = Rules.scripted_encounter(53, 2, ["exemption"], 1, Rules.SHIFT_VELLUM)
	check(play_named(nessa_open, "exemption", 0, 0), "exemption sits off Nessa's bottom row")
	check(nessa_open.last_patience_loss == 2, "an exemption off the bottom row leaves the empty-row toll")

	var nessa_muted = Rules.scripted_encounter(53, 2, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_VELLUM)
	check(play_named(nessa_muted, "exemption", 2, 1), "exemption on the bottom row of a full form")
	check(play_named(nessa_muted, "entry_mark", 0, 0), "top row under a cancelled toll")
	check(play_named(nessa_muted, "entry_mark", 1, 1), "middle row under a cancelled toll")
	check(nessa_muted.last_patience_loss == 1, "exemption keeps the drop at 1 even when every row is stamped")
	check(nessa_muted.last_progress_gained == 5, "the filled rows still score under the exemption")

	var nessa_held = Rules.scripted_encounter(53, 2, ["hold"], 1, Rules.SHIFT_VELLUM)
	check(play_named(nessa_held, "hold", 0, 2), "hold in Nessa's column while two rows are empty")
	check(nessa_held.last_patience_loss == 0 and nessa_held.patience == 5, "hold delays Nessa before the row toll")

	var nessa_missed = Rules.scripted_encounter(53, 2, ["hold"], 1, Rules.SHIFT_VELLUM)
	check(play_named(nessa_missed, "hold", 0, 0), "hold outside Nessa's column")
	check(nessa_missed.last_patience_loss == 2, "hold in another column does not spare Nessa")

	var lark = Rules.scripted_encounter(54, 3, ["entry_mark", "entry_mark"], 3, Rules.SHIFT_VELLUM)
	check(String(Rules.traveler(lark)["name"]) == "Lark Pym", "the vellum bell's fourth form is Lark Pym")
	check(String(Rules.traveler(lark)["form_name"]) == "Solo Line", "Lark brings the Solo Line")
	check(String(Rules.traveler(lark)["rule_text"]) == "Ignores a stamp that shares its row.", "Lark's form states the shared-row rule")
	check(Rules.preview_progress(lark, "entry_mark", 1, 1) == 2, "preview accepts a lone center for Lark")
	check(play_named(lark, "entry_mark", 1, 0), "a stamp is placed on the middle row")
	check(lark.phase == "play", "the first row stamp leaves the turn open")
	check(Rules.can_play(lark, 0, 1, 1), "rules accept another stamp in that row as a placement")
	check(Rules.preview_progress(lark, "entry_mark", 1, 1) == 0, "preview rejects a stamp that shares the row")
	check(Rules.preview_progress(lark, "entry_mark", 0, 2) == 2, "preview accepts a stamp on an empty row")
	check(play_named(lark, "entry_mark", 1, 1), "Lark receives a stamp that shares its row, the wrong stamp")
	check(lark.last_progress_gained == 0, "Lark ignores both stamps that share a row (%d)" % lark.last_progress_gained)

	var lark_lone = Rules.scripted_encounter(54, 3, ["duty"], 1, Rules.SHIFT_VELLUM)
	check(play_named(lark_lone, "duty", 2, 2), "Lark receives a lone bottom-row duty, the correct stamp")
	check(lark_lone.last_progress_gained == 4, "Lark counts a lone stamp once (%d)" % lark_lone.last_progress_gained)

	var lark_split = Rules.scripted_encounter(54, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_VELLUM)
	check(play_named(lark_split, "entry_mark", 0, 0), "first stamp of two different rows")
	check(play_named(lark_split, "entry_mark", 1, 1), "the second stamp sits on another row")
	check(lark_split.last_progress_gained == 4, "Lark counts stamps on different rows (%d)" % lark_split.last_progress_gained)

	var lark_full = Rules.scripted_encounter(54, 3, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_VELLUM)
	check(play_named(lark_full, "entry_mark", 0, 0), "Lark's top row")
	check(play_named(lark_full, "entry_mark", 1, 1), "Lark's middle row")
	check(play_named(lark_full, "entry_mark", 2, 2), "Lark's bottom row")
	check(lark_full.last_progress_gained == 6, "one stamp in each row all count (%d)" % lark_full.last_progress_gained)

	var lark_freed = Rules.scripted_encounter(54, 3, ["exemption", "entry_mark"], 2, Rules.SHIFT_VELLUM)
	check(play_named(lark_freed, "exemption", 1, 1), "exemption is placed on Lark's middle row")
	check(lark_freed.phase == "play", "Lark's exemption leaves the turn open")
	check(Rules.preview_progress(lark_freed, "entry_mark", 1, 0) == 2, "preview counts a shared row once the rule is cancelled")
	check(play_named(lark_freed, "entry_mark", 1, 0), "a shared-row stamp follows the exemption")
	check(lark_freed.last_progress_gained == 3, "exemption lets Lark's shared row count (%d)" % lark_freed.last_progress_gained)

	var lark_kept = Rules.scripted_encounter(54, 3, ["exemption", "entry_mark"], 2, Rules.SHIFT_VELLUM)
	check(play_named(lark_kept, "exemption", 0, 0), "exemption sits off Lark's middle row")
	check(play_named(lark_kept, "entry_mark", 0, 1), "a stamp shares that top row")
	check(lark_kept.last_progress_gained == 0, "an exemption off the middle row does not let a shared row count (%d)" % lark_kept.last_progress_gained)

	var lark_echo = Rules.scripted_encounter(54, 3, ["echo", "entry_mark", "entry_mark"], 3, Rules.SHIFT_VELLUM)
	check(play_named(lark_echo, "echo", 0, 0), "echo shares the top row")
	check(play_named(lark_echo, "entry_mark", 0, 1), "entry mark shares the top row with the echo")
	check(lark_echo.phase == "play", "the shared row leaves the turn open")
	check(play_named(lark_echo, "entry_mark", 1, 0), "entry mark is placed under the echo")
	check(lark_echo.last_chain_count == 1, "the ignored echo still retriggers")
	check(lark_echo.last_progress_gained == 4, "the shared top row scores 0 and the other row still pays (%d)" % lark_echo.last_progress_gained)

	var lark_below = Rules.scripted_encounter(54, 3, ["echo", "entry_mark"], 2, Rules.SHIFT_VELLUM)
	check(play_named(lark_below, "echo", 0, 0), "echo is placed above an entry mark")
	check(play_named(lark_below, "entry_mark", 1, 0), "the entry mark is on the next row")
	check(lark_below.last_chain_count == 1, "echo retriggers the stamp below")
	check(lark_below.last_progress_gained == 5, "Lark counts stamps that sit on different rows (%d)" % lark_below.last_progress_gained)

	var lark_hold = Rules.scripted_encounter(54, 3, ["hold", "entry_mark"], 2, Rules.SHIFT_VELLUM)
	check(play_named(lark_hold, "hold", 2, 0), "hold is placed in Lark's column")
	check(play_named(lark_hold, "entry_mark", 2, 1), "a stamp shares the hold's row")
	check(lark_hold.last_progress_gained == 0, "the shared hold grants no progress")
	check(lark_hold.last_patience_loss == 0 and lark_hold.patience == 5, "an ignored hold still delays Lark")

	var ada = Rules.scripted_encounter(5, 0, ["entry_mark", "entry_mark"], 2)
	check(play_named(ada, "entry_mark", 1, 0), "Ada receives the first of a shared middle row")
	check(play_named(ada, "entry_mark", 1, 1), "Ada receives the center beside it")
	check(ada.last_progress_gained == 4, "Act 1 does not ignore a shared row or the center (%d)" % ada.last_progress_gained)
	var moss = Rules.scripted_encounter(21, 0, ["duty"], 1, Rules.SHIFT_CLOSING)
	check(play_named(moss, "duty", 1, 0), "Moss receives a middle-row duty outside the center")
	check(moss.last_progress_gained == 0, "the closing bell still refuses the whole middle row")
	var ivo = Rules.scripted_encounter(41, 0, ["duty"], 1, Rules.SHIFT_GUTTER)
	check(play_named(ivo, "duty", 0, 1), "Ivo receives a top-row duty in column 2")
	check(ivo.last_progress_gained == 0, "the gutter lamp still refuses the whole spine")
	var sol = Rules.scripted_encounter(11, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_LATE)
	check(play_named(sol, "entry_mark", 0, 0), "Sol's corner stamp")
	check(play_named(sol, "entry_mark", 1, 1), "Sol's stamp meets it at a corner")
	check(sol.last_progress_gained == 4, "the late shift does not yield for a corner meet (%d)" % sol.last_progress_gained)
	var vetch = Rules.scripted_encounter(31, 2, ["entry_mark"], 1, Rules.SHIFT_ASH)
	check(play_named(vetch, "entry_mark", 0, 0), "Vetch receives one row")
	check(vetch.last_patience_loss == 1, "the ash watch still drops once when a row is empty")
	var nim = Rules.scripted_encounter(32, 3, ["duty"], 1, Rules.SHIFT_ASH)
	check(play_named(nim, "duty", 2, 0), "Nim receives a lone bottom-row duty")
	check(nim.last_progress_gained == 8, "the ash watch still doubles a lone bottom duty (%d)" % nim.last_progress_gained)
	var cira = Rules.scripted_encounter(5, 2, ["entry_mark"], 1)
	check(play_named(cira, "entry_mark", 2, 1), "Cira receives a bottom-row stamp")
	check(cira.last_patience_loss == 1, "Act 1 keeps a single drop when the bottom row is stamped")


func test_vellum_bell_opens() -> void:
	check(Rules.VELLUM_BELL.size() == 4, "the vellum bell has four travelers")
	check(Rules.TRAVELERS.size() == 4 and String(Rules.TRAVELERS[0]["name"]) == "Ada Quill", "Act 1 still begins with Ada Quill")
	check(String(Rules.TRAVELERS[3]["name"]) == "Doss Kite", "Act 1 still ends with Doss Kite")
	check(Rules.LATE_SHIFT.size() == 4 and String(Rules.LATE_SHIFT[0]["name"]) == "Nell Parr", "the late shift still begins with Nell Parr")
	check(String(Rules.LATE_SHIFT[3]["name"]) == "Rue Calder", "the late shift still ends with Rue Calder")
	check(Rules.CLOSING_BELL.size() == 4 and String(Rules.CLOSING_BELL[0]["name"]) == "Moss Quen", "the closing bell still begins with Moss Quen")
	check(String(Rules.CLOSING_BELL[3]["name"]) == "Lumen Peck", "the closing bell still ends with Lumen Peck")
	check(Rules.ASH_WATCH.size() == 4 and String(Rules.ASH_WATCH[0]["name"]) == "Orla Fen", "the ash watch still begins with Orla Fen")
	check(String(Rules.ASH_WATCH[3]["name"]) == "Nim Harth", "the ash watch still ends with Nim Harth")
	check(Rules.GUTTER_LAMP.size() == 4 and String(Rules.GUTTER_LAMP[0]["name"]) == "Ivo Dane", "the gutter lamp still begins with Ivo Dane")
	check(String(Rules.GUTTER_LAMP[3]["name"]) == "Kit Yarrow", "the gutter lamp still ends with Kit Yarrow")
	var vellum = Rules.new_run(77, Rules.SHIFT_VELLUM)
	check(vellum.shift == Rules.SHIFT_VELLUM, "the vellum bell is a separate night")
	check(String(Rules.traveler(vellum)["name"]) == "Edda Voss", "the vellum bell begins with Edda Voss")
	check(vellum.hand.size() == Rules.HAND_SIZE, "the vellum bell draws 5")
	check(vellum.ink == Rules.BASE_INK, "the vellum bell starts at 3 ink")
	check(vellum.library.size() == Rules.STARTING_DECK.size(), "the vellum bell deals the starting deck")
	check(vellum.relic_id == "", "an earlier night's relic does not carry")
	check(vellum.phase == "play", "the vellum bell opens in play")
	var dealt: Array = []
	for iid in vellum.hand:
		dealt.append(Rules.card_id_of(vellum, int(iid)))
	var before = vellum.library.size()
	vellum.progress = 4
	vellum.patience = 1
	Rules.restart_encounter(vellum)
	check(vellum.shift == Rules.SHIFT_VELLUM and vellum.traveler_index == 0, "restart encounter stays on the vellum bell")
	check(vellum.progress == 0 and vellum.patience == int(Rules.VELLUM_BELL[0]["patience"]), "restart encounter resets Edda")
	check(vellum.library.size() == before and vellum.hand.size() == 5 and vellum.phase == "play", "restart keeps the vellum-bell deck and deals a hand")
	var redealt: Array = []
	for iid in vellum.hand:
		redealt.append(Rules.card_id_of(vellum, int(iid)))
	check(redealt == dealt, "restart deals Edda the same hand")

	var packed = load("res://game/main.tscn")
	var desk = packed.instantiate()
	root.add_child(desk)
	if desk.state == null:
		desk._ready()
	check(desk.state.shift == Rules.SHIFT_FIRST, "the desk still opens on Act 1")
	check(desk.vellum_button.text == "Vellum bell", "the desk offers the vellum bell")
	check(desk.shift_button.text == "Late shift", "the desk still offers the late shift")
	check(desk.closing_button.text == "Closing bell", "the desk still offers the closing bell")
	check(desk.ash_button.text == "Ash watch", "the desk still offers the ash watch")
	check(desk.gutter_button.text == "Gutter lamp", "the desk still offers the gutter lamp")
	desk.vellum_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_VELLUM, "the desk can open the vellum bell")
	check(String(Rules.traveler(desk.state)["name"]) == "Edda Voss", "the open desk shows Edda")
	check(String(desk.desk_label.text).begins_with("Vellum bell"), "the desk title follows the vellum bell")
	check(desk.meta_label.text.contains("Quiet Center"), "the desk shows Edda's form")
	check(desk.vellum_button.text == "First bell", "the vellum bell can return to the first bell")
	check(desk.shift_button.text == "Late shift", "the late shift stays available from the vellum bell")
	check(desk.closing_button.text == "Closing bell", "the closing bell stays available from the vellum bell")
	check(desk.ash_button.text == "Ash watch", "the ash watch stays available from the vellum bell")
	check(desk.gutter_button.text == "Gutter lamp", "the gutter lamp stays available from the vellum bell")
	desk._restart_act()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_VELLUM and String(Rules.traveler(desk.state)["name"]) == "Edda Voss", "restart act replays the vellum bell")
	desk.vellum_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the vellum bell returns to Ada")
	desk._toggle_shift()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_LATE and String(Rules.traveler(desk.state)["name"]) == "Nell Parr", "the late shift still opens from the first bell")
	check(desk.vellum_button.text == "Vellum bell", "the late shift offers the vellum bell")
	desk._begin_vellum_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_VELLUM and String(Rules.traveler(desk.state)["name"]) == "Edda Voss", "the late shift can open the vellum bell")
	desk._toggle_closing()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_CLOSING and String(Rules.traveler(desk.state)["name"]) == "Moss Quen", "the vellum bell can open the closing bell")
	check(desk.vellum_button.text == "Vellum bell", "the closing bell offers the vellum bell")
	desk.vellum_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_VELLUM and String(Rules.traveler(desk.state)["name"]) == "Edda Voss", "the closing bell can open the vellum bell")
	desk._toggle_ash()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_ASH and String(Rules.traveler(desk.state)["name"]) == "Orla Fen", "the vellum bell can open the ash watch")
	check(desk.vellum_button.text == "Vellum bell", "the ash watch offers the vellum bell")
	desk._begin_vellum_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_VELLUM and String(Rules.traveler(desk.state)["name"]) == "Edda Voss", "the ash watch can open the vellum bell")
	desk._toggle_gutter()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_GUTTER and String(Rules.traveler(desk.state)["name"]) == "Ivo Dane", "the vellum bell can open the gutter lamp")
	check(desk.vellum_button.text == "Vellum bell", "the gutter lamp offers the vellum bell")
	desk._begin_vellum_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_VELLUM and String(Rules.traveler(desk.state)["name"]) == "Edda Voss", "the gutter lamp can open the vellum bell")
	desk._begin_first_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "first bell still returns to Ada")
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_vellum = _button_named(desk, "Open the vellum bell")
	check(victory_vellum != null, "Act 1's victory desk offers the vellum bell")
	if victory_vellum != null:
		victory_vellum.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_VELLUM and String(Rules.traveler(desk.state)["name"]) == "Edda Voss", "the victory desk opens the vellum bell")
	root.remove_child(desk)
	desk.free()


func test_policy_clears_vellum_bell() -> void:
	var started = Time.get_ticks_msec()
	var state = Rules.new_run(12345, Rules.SHIFT_VELLUM)
	var steps = 0
	var seen = 0
	while state.phase != "victory":
		steps += 1
		if steps > 500 or state.phase == "defeat":
			check(false, "policy lost or stalled on the vellum bell, seed 12345: " + Rules.debug_summary(state))
			return
		var action = Policy.choose(state)
		if not Rules.apply_action(state, action):
			check(false, "vellum-bell policy action was rejected: %s / %s" % [str(action), Rules.debug_summary(state)])
			return
		if state.encounters_cleared != seen:
			seen = state.encounters_cleared
			print("cleared vellum encounter %d after %d actions" % [seen, steps])
	var elapsed = Time.get_ticks_msec() - started
	check(state.encounters_cleared == 4, "policy cleared all 4 vellum-bell encounters on seed 12345")
	check(state.phase == "victory", "vellum bell ends in victory")
	check(state.shift == Rules.SHIFT_VELLUM, "the clear stayed on the vellum bell")
	print("vellum bell finished in %d actions, %d ms" % [steps, elapsed])


func test_quire_watch_rules() -> void:
	var tess = Rules.scripted_encounter(61, 0, ["duty"], 3, Rules.SHIFT_QUIRE)
	check(String(Rules.traveler(tess)["name"]) == "Tess Quern", "the quire watch's first form is Tess Quern")
	check(String(Rules.traveler(tess)["form_name"]) == "Far Margin", "Tess brings the Far Margin")
	check(String(Rules.traveler(tess)["rule_text"]) == "Refuses stamps in column 3.", "Tess's form states the column rule")
	check(Rules.can_play(tess, 0, 2, 2), "rules accept a column-3 duty as a placement")
	check(Rules.preview_progress(tess, "duty", 2, 2) == 0, "preview rejects a column-3 duty for Tess")
	check(Rules.preview_progress(tess, "duty", 2, 1) == 4, "preview accepts a bottom-row duty outside column 3")
	check(Rules.preview_progress(tess, "duty", 1, 0) == 2, "preview accepts the middle row outside column 3")
	check(Rules.preview_progress(tess, "duty", 0, 2) == 0, "preview rejects a top-row duty in column 3")
	check(Rules.preview_progress(tess, "duty", 0, 1) == 2, "preview accepts a top-row duty outside column 3")

	var refused = Rules.scripted_encounter(61, 0, ["duty"], 1, Rules.SHIFT_QUIRE)
	check(play_named(refused, "duty", 2, 2), "Tess receives a column-3 duty, the wrong stamp")
	check(refused.last_progress_gained == 0, "Tess refuses column 3 (%d)" % refused.last_progress_gained)
	check(refused.turn_number == 2 and refused.progress == 0, "the refused column-3 duty resolved and scored nothing")
	check(refused.last_patience_loss == 1, "a refused stamp still spends the turn")

	var accepted = Rules.scripted_encounter(61, 0, ["duty"], 1, Rules.SHIFT_QUIRE)
	check(play_named(accepted, "duty", 2, 1), "Tess receives a bottom-row duty in column 2, the correct stamp")
	check(accepted.last_progress_gained == 4, "Tess counts that duty (%d)" % accepted.last_progress_gained)

	var middle = Rules.scripted_encounter(61, 0, ["duty"], 1, Rules.SHIFT_QUIRE)
	check(play_named(middle, "duty", 1, 2), "Tess receives a middle-row duty in column 3")
	check(middle.last_progress_gained == 0, "Tess refuses the middle of column 3 (%d)" % middle.last_progress_gained)

	var top = Rules.scripted_encounter(61, 0, ["duty"], 1, Rules.SHIFT_QUIRE)
	check(play_named(top, "duty", 0, 1), "Tess receives a top-row duty outside column 3")
	check(top.last_progress_gained == 2, "Tess does not refuse the rest of the top row (%d)" % top.last_progress_gained)

	var cleared = Rules.scripted_encounter(61, 0, ["exemption", "duty"], 2, Rules.SHIFT_QUIRE)
	check(play_named(cleared, "exemption", 0, 1), "exemption is placed on Tess's top row")
	check(cleared.phase == "play", "Tess's exemption leaves the turn open")
	check(play_named(cleared, "duty", 2, 2), "a column-3 duty follows the exemption")
	check(cleared.last_progress_gained == 5, "exemption lets Tess's column 3 count (%d)" % cleared.last_progress_gained)

	var margin_exempt = Rules.scripted_encounter(61, 0, ["exemption", "duty"], 2, Rules.SHIFT_QUIRE)
	check(play_named(margin_exempt, "exemption", 0, 2), "exemption sits in column 3 on Tess's top row")
	check(play_named(margin_exempt, "duty", 2, 2), "another column-3 duty follows that exemption")
	check(margin_exempt.last_progress_gained == 5, "an exemption in the refused column still cancels it (%d)" % margin_exempt.last_progress_gained)

	var still_far = Rules.scripted_encounter(61, 0, ["exemption", "duty"], 2, Rules.SHIFT_QUIRE)
	check(play_named(still_far, "exemption", 1, 0), "exemption sits off Tess's top row")
	check(play_named(still_far, "duty", 2, 2), "the column-3 duty stays refused")
	check(still_far.last_progress_gained == 1, "an exemption off the top row does not open column 3 (%d)" % still_far.last_progress_gained)

	var refused_ripple = Rules.scripted_encounter(61, 0, ["entry_mark", "ripple"], 3, Rules.SHIFT_QUIRE)
	check(play_named(refused_ripple, "entry_mark", 2, 1), "entry mark is placed beside column 3")
	check(refused_ripple.phase == "play", "the entry mark leaves the turn open")
	check(play_named(refused_ripple, "ripple", 2, 2), "ripple is placed in Tess's column 3")
	check(refused_ripple.last_chain_count == 1, "the refused ripple still retriggers")
	check(refused_ripple.last_progress_gained == 4, "the column-3 ripple scores 0 and the retrigger still pays (%d)" % refused_ripple.last_progress_gained)

	var refused_hold = Rules.scripted_encounter(61, 0, ["hold"], 1, Rules.SHIFT_QUIRE)
	check(play_named(refused_hold, "hold", 1, 2), "hold is placed in column 3, Tess's lane")
	check(refused_hold.last_progress_gained == 0, "the refused hold grants no progress")
	check(refused_hold.last_patience_loss == 0 and refused_hold.patience == 5, "a refused hold still delays Tess")

	var missed_hold = Rules.scripted_encounter(61, 0, ["hold"], 1, Rules.SHIFT_QUIRE)
	check(play_named(missed_hold, "hold", 1, 0), "hold outside Tess's column")
	check(missed_hold.last_progress_gained == 1, "hold outside column 3 still scores")
	check(missed_hold.last_patience_loss == 1, "hold in another column does not delay Tess")

	var oren_one = Rules.scripted_encounter(62, 1, ["entry_mark"], 1, Rules.SHIFT_QUIRE)
	check(String(Rules.traveler(oren_one)["name"]) == "Oren Sallow", "the quire watch's second form is Oren Sallow")
	check(String(Rules.traveler(oren_one)["form_name"]) == "Side Meet", "Oren brings the Side Meet")
	check(String(Rules.traveler(oren_one)["rule_text"]) == "Yields if two stamps share a side.", "Oren's form states the side rule")
	check(play_named(oren_one, "entry_mark", 1, 1), "Oren receives one stamp, the wrong stamp")
	check(oren_one.last_progress_gained == 2, "one stamp does not make Oren yield (%d)" % oren_one.last_progress_gained)

	var oren_corner = Rules.scripted_encounter(62, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_QUIRE)
	check(play_named(oren_corner, "entry_mark", 0, 0), "first of two stamps that meet at a corner")
	check(play_named(oren_corner, "entry_mark", 1, 1), "the second stamp meets it at a corner, not a side")
	check(oren_corner.last_progress_gained == 4, "a corner does not make Oren yield (%d)" % oren_corner.last_progress_gained)

	var oren_gap = Rules.scripted_encounter(62, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_QUIRE)
	check(play_named(oren_gap, "entry_mark", 0, 0), "first stamp of a row with a gap")
	check(play_named(oren_gap, "entry_mark", 0, 2), "the second stamp leaves a cell between them")
	check(oren_gap.last_progress_gained == 4, "a gap does not make Oren yield (%d)" % oren_gap.last_progress_gained)

	var oren_side = Rules.scripted_encounter(62, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_QUIRE)
	check(play_named(oren_side, "entry_mark", 1, 0), "Oren's first side stamp")
	check(oren_side.phase == "play", "the side pair is still open")
	check(play_named(oren_side, "entry_mark", 1, 1), "Oren receives the stamp that shares its side, the correct stamp")
	check(oren_side.last_progress_gained == 8, "Oren yields +4 when two stamps share a side (%d)" % oren_side.last_progress_gained)

	var oren_down = Rules.scripted_encounter(62, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_QUIRE)
	check(play_named(oren_down, "entry_mark", 0, 1), "a stamp above its neighbor")
	check(play_named(oren_down, "entry_mark", 1, 1), "the stamp directly below shares the side")
	check(oren_down.last_progress_gained == 8, "Oren yields for a vertical side (%d)" % oren_down.last_progress_gained)

	var oren_row = Rules.scripted_encounter(62, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_QUIRE)
	check(play_named(oren_row, "entry_mark", 0, 0), "first stamp of a full top row")
	check(play_named(oren_row, "entry_mark", 0, 1), "second stamp of a full top row")
	check(play_named(oren_row, "entry_mark", 0, 2), "a full row shares sides")
	check(oren_row.last_progress_gained == 10, "Oren yields once for a full row (%d)" % oren_row.last_progress_gained)

	var oren_column = Rules.scripted_encounter(62, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_QUIRE)
	check(play_named(oren_column, "entry_mark", 0, 0), "first stamp of one column")
	check(play_named(oren_column, "entry_mark", 1, 0), "second stamp of that column")
	check(play_named(oren_column, "entry_mark", 2, 0), "a full column shares sides")
	check(oren_column.last_progress_gained == 10, "Oren yields once for a full column (%d)" % oren_column.last_progress_gained)

	var oren_mixed = Rules.scripted_encounter(62, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_QUIRE)
	check(play_named(oren_mixed, "entry_mark", 0, 0), "a stamp that also has a corner neighbor")
	check(play_named(oren_mixed, "entry_mark", 1, 1), "the corner neighbor")
	check(play_named(oren_mixed, "entry_mark", 1, 2), "the stamp that shares a side")
	check(oren_mixed.last_progress_gained == 10, "a corner does not cancel Oren's side (%d)" % oren_mixed.last_progress_gained)

	var oren_kept = Rules.scripted_encounter(62, 1, ["exemption", "entry_mark"], 2, Rules.SHIFT_QUIRE)
	check(play_named(oren_kept, "exemption", 0, 0), "exemption sits off Oren's middle row")
	check(play_named(oren_kept, "entry_mark", 0, 1), "a side partner for that exemption")
	check(oren_kept.last_progress_gained == 7, "a shared side still yields when exemption is not on the middle row (%d)" % oren_kept.last_progress_gained)

	var oren_muted = Rules.scripted_encounter(62, 1, ["exemption", "entry_mark"], 2, Rules.SHIFT_QUIRE)
	check(play_named(oren_muted, "exemption", 1, 1), "exemption is placed on Oren's middle row")
	check(oren_muted.phase == "play", "Oren's exemption leaves the turn open")
	check(play_named(oren_muted, "entry_mark", 1, 0), "a side partner under a cancelled yield")
	check(oren_muted.last_progress_gained == 3, "exemption cancels Oren's yield (%d)" % oren_muted.last_progress_gained)

	var oren_band = Rules.scripted_encounter(62, 1, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_QUIRE)
	check(play_named(oren_band, "exemption", 1, 1), "exemption on the middle row, outside the side pair")
	check(play_named(oren_band, "entry_mark", 0, 0), "first stamp of a side pair under that exemption")
	check(play_named(oren_band, "entry_mark", 0, 1), "second stamp of that side pair")
	check(oren_band.last_progress_gained == 5, "exemption on the middle row cancels a side elsewhere (%d)" % oren_band.last_progress_gained)

	var oren_held = Rules.scripted_encounter(62, 1, ["hold"], 1, Rules.SHIFT_QUIRE)
	check(play_named(oren_held, "hold", 2, 0), "hold in Oren's column")
	check(oren_held.last_progress_gained == 1, "one hold does not share a side")
	check(oren_held.last_patience_loss == 0 and oren_held.patience == 5, "hold delays Oren")

	var bryn_short = Rules.scripted_encounter(63, 2, ["duty"], 1, Rules.SHIFT_QUIRE)
	check(String(Rules.traveler(bryn_short)["name"]) == "Bryn Solt", "the quire watch's third form is Bryn Solt")
	check(String(Rules.traveler(bryn_short)["form_name"]) == "Column Toll", "Bryn brings the Column Toll")
	check(String(Rules.traveler(bryn_short)["rule_text"]) == "Patience drops once for each empty column.", "Bryn's form states the column toll")
	check(play_named(bryn_short, "duty", 2, 2), "Bryn receives one column-3 duty, the wrong stamp")
	check(bryn_short.last_progress_gained == 4, "the column-3 duty still scores for Bryn")
	check(bryn_short.last_patience_loss == 2, "two empty columns drop Bryn's patience by 2 (%d)" % bryn_short.last_patience_loss)
	check(bryn_short.patience == 3, "Bryn's patience is 3 after the two-column toll")

	var bryn_full = Rules.scripted_encounter(63, 2, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_QUIRE)
	check(play_named(bryn_full, "entry_mark", 0, 0), "Bryn's column 1 is stamped")
	check(play_named(bryn_full, "entry_mark", 1, 1), "Bryn's column 2 is stamped")
	check(bryn_full.phase == "play", "the last empty column is still open")
	check(play_named(bryn_full, "entry_mark", 2, 2), "Bryn receives the stamp that fills every column, the correct stamp")
	check(bryn_full.last_progress_gained == 6, "three columns still score for Bryn")
	check(bryn_full.last_patience_loss == 0 and bryn_full.patience == 5, "every column keeps Bryn's patience")

	var bryn_gap = Rules.scripted_encounter(63, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_QUIRE)
	check(play_named(bryn_gap, "entry_mark", 0, 0), "Bryn's column 1")
	check(play_named(bryn_gap, "entry_mark", 2, 2), "Bryn's column 3, column 2 still empty")
	check(bryn_gap.last_patience_loss == 1, "one empty column drops Bryn's patience by 1")

	var bryn_stack = Rules.scripted_encounter(63, 2, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_QUIRE)
	check(play_named(bryn_stack, "entry_mark", 0, 0), "first stamp of one column")
	check(play_named(bryn_stack, "entry_mark", 1, 0), "second stamp of that column")
	check(play_named(bryn_stack, "entry_mark", 2, 0), "a full column leaves two columns empty")
	check(bryn_stack.last_progress_gained == 6, "a stacked column still scores")
	check(bryn_stack.last_patience_loss == 2, "a stacked column does not spare the other columns")

	var bryn_row = Rules.scripted_encounter(63, 2, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_QUIRE)
	check(play_named(bryn_row, "entry_mark", 0, 0), "Bryn's shared row, column 1")
	check(play_named(bryn_row, "entry_mark", 0, 1), "Bryn's shared row, column 2")
	check(play_named(bryn_row, "entry_mark", 0, 2), "one row still touches every column")
	check(bryn_row.last_patience_loss == 0, "one stamp in each column is enough for Bryn")

	var bryn_blank = Rules.scripted_encounter(63, 2, ["entry_mark"], 1, Rules.SHIFT_QUIRE)
	Rules.end_turn(bryn_blank)
	check(bryn_blank.last_progress_gained == 0, "an empty form scores nothing")
	check(bryn_blank.last_patience_loss == 3, "three empty columns drop Bryn's patience by 3 (%d)" % bryn_blank.last_patience_loss)

	var bryn_spared = Rules.scripted_encounter(63, 2, ["exemption"], 1, Rules.SHIFT_QUIRE)
	check(play_named(bryn_spared, "exemption", 2, 0), "exemption on Bryn's bottom row, two columns still empty")
	check(bryn_spared.last_patience_loss == 1, "exemption keeps Bryn's drop at 1")
	check(bryn_spared.last_progress_gained == 1, "the exemption itself scores 1")

	var bryn_open = Rules.scripted_encounter(63, 2, ["exemption"], 1, Rules.SHIFT_QUIRE)
	check(play_named(bryn_open, "exemption", 0, 0), "exemption sits off Bryn's bottom row")
	check(bryn_open.last_patience_loss == 2, "an exemption off the bottom row leaves the empty-column toll")

	var bryn_muted = Rules.scripted_encounter(63, 2, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_QUIRE)
	check(play_named(bryn_muted, "exemption", 2, 1), "exemption on the bottom row of a full set of columns")
	check(play_named(bryn_muted, "entry_mark", 0, 0), "column 1 under a cancelled toll")
	check(play_named(bryn_muted, "entry_mark", 1, 2), "column 3 under a cancelled toll")
	check(bryn_muted.last_patience_loss == 1, "exemption keeps the drop at 1 even when every column is stamped")
	check(bryn_muted.last_progress_gained == 5, "the filled columns still score under the exemption")

	var bryn_held = Rules.scripted_encounter(63, 2, ["hold"], 1, Rules.SHIFT_QUIRE)
	check(play_named(bryn_held, "hold", 0, 1), "hold in Bryn's column while two columns are empty")
	check(bryn_held.last_patience_loss == 0 and bryn_held.patience == 5, "hold delays Bryn before the column toll")

	var bryn_missed = Rules.scripted_encounter(63, 2, ["hold"], 1, Rules.SHIFT_QUIRE)
	check(play_named(bryn_missed, "hold", 0, 0), "hold outside Bryn's column")
	check(bryn_missed.last_patience_loss == 2, "hold in another column does not spare Bryn")

	var ida = Rules.scripted_encounter(64, 3, ["entry_mark", "duty"], 3, Rules.SHIFT_QUIRE)
	check(String(Rules.traveler(ida)["name"]) == "Ida Cress", "the quire watch's fourth form is Ida Cress")
	check(String(Rules.traveler(ida)["form_name"]) == "Head Slip", "Ida brings the Head Slip")
	check(String(Rules.traveler(ida)["rule_text"]) == "The first stamp in the queue scores twice.", "Ida's form states the queue-head rule")
	check(Rules.preview_progress(ida, "duty", 2, 2) == 8, "preview doubles a lone bottom-row duty")
	check(Rules.preview_progress(ida, "duty", 0, 0) == 4, "preview doubles a lone top-row duty")
	check(play_named(ida, "entry_mark", 0, 0), "an earlier cell is filled before the preview")
	check(ida.phase == "play", "the head stamp leaves the turn open")
	check(Rules.can_play(ida, 0, 2, 2), "rules accept a later duty as a placement")
	check(Rules.preview_progress(ida, "duty", 2, 2) == 4, "preview does not double a duty with a stamp earlier in the queue")
	check(Rules.preview_progress(ida, "duty", 0, 1) == 2, "preview does not double a later top-row duty")

	var later = Rules.scripted_encounter(64, 3, ["duty", "entry_mark"], 2, Rules.SHIFT_QUIRE)
	check(play_named(later, "entry_mark", 0, 0), "an earlier stamp is placed")
	check(play_named(later, "duty", 2, 0), "Ida receives a later bottom-row duty, the wrong stamp")
	check(later.last_progress_gained == 8, "the later bottom-row duty is not doubled (%d)" % later.last_progress_gained)

	var head = Rules.scripted_encounter(64, 3, ["duty"], 1, Rules.SHIFT_QUIRE)
	check(play_named(head, "duty", 2, 2), "Ida receives a lone bottom-row duty, the correct stamp")
	check(head.last_progress_gained == 8, "Ida doubles the first stamp (%d)" % head.last_progress_gained)

	var split = Rules.scripted_encounter(64, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_QUIRE)
	check(play_named(split, "entry_mark", 0, 0), "the earlier entry mark")
	check(play_named(split, "entry_mark", 0, 1), "the later entry mark in that row")
	check(split.last_progress_gained == 6, "only the earlier entry mark is doubled (%d)" % split.last_progress_gained)

	var muted = Rules.scripted_encounter(64, 3, ["exemption", "duty"], 2, Rules.SHIFT_QUIRE)
	check(play_named(muted, "duty", 0, 0), "a top-row duty would be the queue head")
	check(play_named(muted, "exemption", 0, 1), "exemption is placed on Ida's top row")
	check(muted.last_progress_gained == 3, "exemption cancels Ida's doubling (%d)" % muted.last_progress_gained)

	var kept = Rules.scripted_encounter(64, 3, ["duty", "exemption"], 2, Rules.SHIFT_QUIRE)
	check(play_named(kept, "duty", 0, 0), "the queue head under an off-row exemption")
	check(play_named(kept, "exemption", 1, 1), "exemption sits off Ida's top row")
	check(kept.last_progress_gained == 5, "an exemption off the top row leaves the head doubled (%d)" % kept.last_progress_gained)

	var doubled_echo = Rules.scripted_encounter(64, 3, ["echo", "entry_mark"], 2, Rules.SHIFT_QUIRE)
	check(play_named(doubled_echo, "echo", 0, 0), "echo is the first stamp in the queue")
	check(play_named(doubled_echo, "entry_mark", 1, 0), "entry mark is placed under the echo")
	check(doubled_echo.last_chain_count == 1, "the doubled echo still retriggers")
	check(doubled_echo.last_progress_gained == 6, "the head echo scores twice and the later retrigger does not (%d)" % doubled_echo.last_progress_gained)

	var plain_echo = Rules.scripted_encounter(64, 3, ["entry_mark", "echo", "entry_mark"], 3, Rules.SHIFT_QUIRE)
	check(play_named(plain_echo, "entry_mark", 0, 0), "an earlier stamp keeps the echo off the head")
	check(play_named(plain_echo, "echo", 0, 1), "echo is placed after the first cell")
	check(play_named(plain_echo, "entry_mark", 1, 1), "entry mark is placed under that echo")
	check(plain_echo.last_chain_count == 1, "an echo that is not first still retriggers")
	check(plain_echo.last_progress_gained == 9, "the echo scores 1 and the earlier stamp is doubled (%d)" % plain_echo.last_progress_gained)

	var doubled_reply = Rules.scripted_encounter(64, 3, ["entry_mark", "reply"], 2, Rules.SHIFT_QUIRE)
	check(play_named(doubled_reply, "entry_mark", 0, 0), "entry mark is the queue head")
	check(play_named(doubled_reply, "reply", 1, 0), "reply retriggers the stamp above")
	check(doubled_reply.last_chain_count == 1, "the reply retriggers the queue head")
	check(doubled_reply.last_progress_gained == 9, "a retrigger of the queue head scores twice again (%d)" % doubled_reply.last_progress_gained)

	var doubled_hold = Rules.scripted_encounter(64, 3, ["hold"], 1, Rules.SHIFT_QUIRE)
	check(play_named(doubled_hold, "hold", 2, 0), "hold is the first stamp in Ida's column")
	check(doubled_hold.last_progress_gained == 2, "the head hold scores twice")
	check(doubled_hold.last_patience_loss == 0 and doubled_hold.patience == 5, "a doubled hold still delays Ida")

	var missed_ida = Rules.scripted_encounter(64, 3, ["hold"], 1, Rules.SHIFT_QUIRE)
	check(play_named(missed_ida, "hold", 0, 1), "a doubled hold outside Ida's column")
	check(missed_ida.last_progress_gained == 2, "the head hold still scores twice outside the lane")
	check(missed_ida.last_patience_loss == 1, "a doubled hold in another column does not delay Ida")

	var ada = Rules.scripted_encounter(5, 0, ["duty"], 1)
	check(play_named(ada, "duty", 2, 2), "Ada receives a column-3 duty")
	check(ada.last_progress_gained == 4, "Act 1 does not refuse column 3 (%d)" % ada.last_progress_gained)
	var rho = Rules.scripted_encounter(52, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_VELLUM)
	check(play_named(rho, "entry_mark", 1, 0), "Rho's first side stamp")
	check(play_named(rho, "entry_mark", 1, 1), "Rho's second stamp shares that side")
	check(rho.last_progress_gained == 4, "the vellum bell does not yield for a shared side (%d)" % rho.last_progress_gained)
	var nessa = Rules.scripted_encounter(53, 2, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_VELLUM)
	check(play_named(nessa, "entry_mark", 0, 0), "Nessa's column 1 on one row")
	check(play_named(nessa, "entry_mark", 0, 1), "Nessa's column 2 on that row")
	check(play_named(nessa, "entry_mark", 0, 2), "Nessa's column 3 on that row")
	check(nessa.last_patience_loss == 2, "the vellum bell still tolls the empty rows")
	var nim = Rules.scripted_encounter(34, 3, ["entry_mark", "duty"], 2, Rules.SHIFT_ASH)
	check(play_named(nim, "entry_mark", 0, 0), "Nim's earlier entry mark")
	check(play_named(nim, "duty", 2, 0), "Nim's later bottom-row duty")
	check(nim.last_progress_gained == 10, "the ash watch still doubles the last stamp (%d)" % nim.last_progress_gained)
	var ivo = Rules.scripted_encounter(41, 0, ["duty"], 1, Rules.SHIFT_GUTTER)
	check(play_named(ivo, "duty", 2, 2), "Ivo receives a bottom-row duty in column 3")
	check(ivo.last_progress_gained == 4, "the gutter lamp still counts column 3 (%d)" % ivo.last_progress_gained)
	var pim = Rules.scripted_encounter(12, 2, ["entry_mark"], 1, Rules.SHIFT_LATE)
	check(play_named(pim, "entry_mark", 0, 2), "Pim receives a stamp in column 3")
	check(pim.last_patience_loss == 1, "the late shift still drops once when column 3 is stamped")
	var first = Rules.scripted_encounter(5, 1, ["entry_mark", "entry_mark"], 2)
	check(play_named(first, "entry_mark", 1, 0), "Bram's earlier entry mark")
	check(play_named(first, "entry_mark", 2, 0), "Bram's later entry mark")
	check(first.last_progress_gained == 4, "Act 1 does not double the first stamp (%d)" % first.last_progress_gained)


func test_quire_watch_opens() -> void:
	check(Rules.QUIRE_WATCH.size() == 4, "the quire watch has four travelers")
	check(Rules.TRAVELERS.size() == 4 and String(Rules.TRAVELERS[0]["name"]) == "Ada Quill", "Act 1 still begins with Ada Quill")
	check(String(Rules.TRAVELERS[3]["name"]) == "Doss Kite", "Act 1 still ends with Doss Kite")
	check(Rules.LATE_SHIFT.size() == 4 and String(Rules.LATE_SHIFT[0]["name"]) == "Nell Parr", "the late shift still begins with Nell Parr")
	check(String(Rules.LATE_SHIFT[3]["name"]) == "Rue Calder", "the late shift still ends with Rue Calder")
	check(Rules.CLOSING_BELL.size() == 4 and String(Rules.CLOSING_BELL[0]["name"]) == "Moss Quen", "the closing bell still begins with Moss Quen")
	check(String(Rules.CLOSING_BELL[3]["name"]) == "Lumen Peck", "the closing bell still ends with Lumen Peck")
	check(Rules.ASH_WATCH.size() == 4 and String(Rules.ASH_WATCH[0]["name"]) == "Orla Fen", "the ash watch still begins with Orla Fen")
	check(String(Rules.ASH_WATCH[3]["name"]) == "Nim Harth", "the ash watch still ends with Nim Harth")
	check(Rules.GUTTER_LAMP.size() == 4 and String(Rules.GUTTER_LAMP[0]["name"]) == "Ivo Dane", "the gutter lamp still begins with Ivo Dane")
	check(String(Rules.GUTTER_LAMP[3]["name"]) == "Kit Yarrow", "the gutter lamp still ends with Kit Yarrow")
	check(Rules.VELLUM_BELL.size() == 4 and String(Rules.VELLUM_BELL[0]["name"]) == "Edda Voss", "the vellum bell still begins with Edda Voss")
	check(String(Rules.VELLUM_BELL[3]["name"]) == "Lark Pym", "the vellum bell still ends with Lark Pym")
	var quire = Rules.new_run(77, Rules.SHIFT_QUIRE)
	check(quire.shift == Rules.SHIFT_QUIRE, "the quire watch is a separate night")
	check(String(Rules.traveler(quire)["name"]) == "Tess Quern", "the quire watch begins with Tess Quern")
	check(quire.hand.size() == Rules.HAND_SIZE, "the quire watch draws 5")
	check(quire.ink == Rules.BASE_INK, "the quire watch starts at 3 ink")
	check(quire.library.size() == Rules.STARTING_DECK.size(), "the quire watch deals the starting deck")
	check(quire.relic_id == "", "an earlier night's relic does not carry")
	check(quire.phase == "play", "the quire watch opens in play")
	var dealt: Array = []
	for iid in quire.hand:
		dealt.append(Rules.card_id_of(quire, int(iid)))
	var before = quire.library.size()
	quire.progress = 4
	quire.patience = 1
	Rules.restart_encounter(quire)
	check(quire.shift == Rules.SHIFT_QUIRE and quire.traveler_index == 0, "restart encounter stays on the quire watch")
	check(quire.progress == 0 and quire.patience == int(Rules.QUIRE_WATCH[0]["patience"]), "restart encounter resets Tess")
	check(quire.library.size() == before and quire.hand.size() == 5 and quire.phase == "play", "restart keeps the quire-watch deck and deals a hand")
	var redealt: Array = []
	for iid in quire.hand:
		redealt.append(Rules.card_id_of(quire, int(iid)))
	check(redealt == dealt, "restart deals Tess the same hand")

	var packed = load("res://game/main.tscn")
	var desk = packed.instantiate()
	root.add_child(desk)
	if desk.state == null:
		desk._ready()
	check(desk.state.shift == Rules.SHIFT_FIRST, "the desk still opens on Act 1")
	check(desk.quire_button.text == "Quire watch", "the desk offers the quire watch")
	check(desk.shift_button.text == "Late shift", "the desk still offers the late shift")
	check(desk.closing_button.text == "Closing bell", "the desk still offers the closing bell")
	check(desk.ash_button.text == "Ash watch", "the desk still offers the ash watch")
	check(desk.gutter_button.text == "Gutter lamp", "the desk still offers the gutter lamp")
	check(desk.vellum_button.text == "Vellum bell", "the desk still offers the vellum bell")
	desk.quire_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_QUIRE, "the desk can open the quire watch")
	check(String(Rules.traveler(desk.state)["name"]) == "Tess Quern", "the open desk shows Tess")
	check(String(desk.desk_label.text).begins_with("Quire watch"), "the desk title follows the quire watch")
	check(desk.meta_label.text.contains("Far Margin"), "the desk shows Tess's form")
	check(desk.quire_button.text == "First bell", "the quire watch can return to the first bell")
	check(desk.shift_button.text == "Late shift", "the late shift stays available from the quire watch")
	check(desk.closing_button.text == "Closing bell", "the closing bell stays available from the quire watch")
	check(desk.ash_button.text == "Ash watch", "the ash watch stays available from the quire watch")
	check(desk.gutter_button.text == "Gutter lamp", "the gutter lamp stays available from the quire watch")
	check(desk.vellum_button.text == "Vellum bell", "the vellum bell stays available from the quire watch")
	desk._restart_act()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_QUIRE and String(Rules.traveler(desk.state)["name"]) == "Tess Quern", "restart act replays the quire watch")
	desk.quire_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the quire watch returns to Ada")
	desk._toggle_shift()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_LATE and String(Rules.traveler(desk.state)["name"]) == "Nell Parr", "the late shift still opens from the first bell")
	check(desk.quire_button.text == "Quire watch", "the late shift offers the quire watch")
	desk._begin_quire_watch()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_QUIRE and String(Rules.traveler(desk.state)["name"]) == "Tess Quern", "the late shift can open the quire watch")
	desk._toggle_closing()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_CLOSING and String(Rules.traveler(desk.state)["name"]) == "Moss Quen", "the quire watch can open the closing bell")
	check(desk.quire_button.text == "Quire watch", "the closing bell offers the quire watch")
	desk.quire_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_QUIRE and String(Rules.traveler(desk.state)["name"]) == "Tess Quern", "the closing bell can open the quire watch")
	desk._toggle_ash()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_ASH and String(Rules.traveler(desk.state)["name"]) == "Orla Fen", "the quire watch can open the ash watch")
	check(desk.quire_button.text == "Quire watch", "the ash watch offers the quire watch")
	desk._begin_quire_watch()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_QUIRE and String(Rules.traveler(desk.state)["name"]) == "Tess Quern", "the ash watch can open the quire watch")
	desk._toggle_gutter()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_GUTTER and String(Rules.traveler(desk.state)["name"]) == "Ivo Dane", "the quire watch can open the gutter lamp")
	check(desk.quire_button.text == "Quire watch", "the gutter lamp offers the quire watch")
	desk._begin_quire_watch()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_QUIRE and String(Rules.traveler(desk.state)["name"]) == "Tess Quern", "the gutter lamp can open the quire watch")
	desk._toggle_vellum()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_VELLUM and String(Rules.traveler(desk.state)["name"]) == "Edda Voss", "the quire watch can open the vellum bell")
	check(desk.quire_button.text == "Quire watch", "the vellum bell offers the quire watch")
	desk._begin_quire_watch()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_QUIRE and String(Rules.traveler(desk.state)["name"]) == "Tess Quern", "the vellum bell can open the quire watch")
	desk._begin_first_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "first bell still returns to Ada")
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_quire = _button_named(desk, "Open the quire watch")
	check(victory_quire != null, "Act 1's victory desk offers the quire watch")
	if victory_quire != null:
		victory_quire.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_QUIRE and String(Rules.traveler(desk.state)["name"]) == "Tess Quern", "the victory desk opens the quire watch")
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_first = _button_named(desk, "Open the first bell")
	check(victory_first != null, "the quire watch victory desk offers the first bell")
	if victory_first != null:
		victory_first.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the quire watch victory desk opens the first bell")
	root.remove_child(desk)
	desk.free()


func test_policy_clears_quire_watch() -> void:
	var started = Time.get_ticks_msec()
	var state = Rules.new_run(12345, Rules.SHIFT_QUIRE)
	var steps = 0
	var seen = 0
	while state.phase != "victory":
		steps += 1
		if steps > 500 or state.phase == "defeat":
			check(false, "policy lost or stalled on the quire watch, seed 12345: " + Rules.debug_summary(state))
			return
		var action = Policy.choose(state)
		if not Rules.apply_action(state, action):
			check(false, "quire-watch policy action was rejected: %s / %s" % [str(action), Rules.debug_summary(state)])
			return
		if state.encounters_cleared != seen:
			seen = state.encounters_cleared
			print("cleared quire encounter %d after %d actions" % [seen, steps])
	var elapsed = Time.get_ticks_msec() - started
	check(state.encounters_cleared == 4, "policy cleared all 4 quire-watch encounters on seed 12345")
	check(state.phase == "victory", "quire watch ends in victory")
	check(state.shift == Rules.SHIFT_QUIRE, "the clear stayed on the quire watch")
	print("quire watch finished in %d actions, %d ms" % [steps, elapsed])


func test_salt_watch_rules() -> void:
	var pell = Rules.scripted_encounter(71, 0, ["duty"], 3, Rules.SHIFT_SALT)
	check(String(Rules.traveler(pell)["name"]) == "Pell Voss", "the salt watch's first form is Pell Voss")
	check(String(Rules.traveler(pell)["form_name"]) == "Tide Bar", "Pell brings the Tide Bar")
	check(String(Rules.traveler(pell)["rule_text"]) == "A stamp on the middle row scores 0 unless an Exemption is also on the middle row.", "Pell's form states the middle-row rule")
	check(Rules.can_play(pell, 0, 1, 1), "rules accept a middle-row duty as a placement")
	check(Rules.preview_progress(pell, "duty", 1, 1) == 0, "preview rejects a middle-row duty for Pell")
	check(Rules.preview_progress(pell, "duty", 2, 1) == 4, "preview accepts a bottom-row duty for Pell")
	check(Rules.preview_progress(pell, "duty", 0, 1) == 2, "preview accepts a top-row duty for Pell")

	var refused = Rules.scripted_encounter(71, 0, ["duty"], 1, Rules.SHIFT_SALT)
	check(play_named(refused, "duty", 1, 1), "Pell receives a middle-row duty, the wrong stamp")
	check(refused.last_progress_gained == 0, "Pell scores 0 for the middle row (%d)" % refused.last_progress_gained)
	check(refused.turn_number == 2 and refused.progress == 0, "the refused middle-row duty resolved and scored nothing")
	check(refused.last_patience_loss == 1, "a refused stamp still spends the turn")

	var accepted = Rules.scripted_encounter(71, 0, ["duty"], 1, Rules.SHIFT_SALT)
	check(play_named(accepted, "duty", 2, 0), "Pell receives a bottom-row duty, the correct stamp")
	check(accepted.last_progress_gained == 4, "Pell counts a bottom-row duty (%d)" % accepted.last_progress_gained)

	var top = Rules.scripted_encounter(71, 0, ["duty"], 1, Rules.SHIFT_SALT)
	check(play_named(top, "duty", 0, 2), "Pell receives a top-row duty")
	check(top.last_progress_gained == 2, "Pell does not refuse the top row (%d)" % top.last_progress_gained)

	var cleared = Rules.scripted_encounter(71, 0, ["exemption", "duty"], 2, Rules.SHIFT_SALT)
	check(play_named(cleared, "exemption", 1, 0), "exemption is placed on Pell's middle row")
	check(cleared.phase == "play", "Pell's exemption leaves the turn open")
	check(play_named(cleared, "duty", 1, 2), "a middle-row duty follows the exemption")
	check(cleared.last_progress_gained == 3, "exemption on the middle row lets Pell's middle row count (%d)" % cleared.last_progress_gained)

	var still_tide = Rules.scripted_encounter(71, 0, ["exemption", "duty"], 2, Rules.SHIFT_SALT)
	check(play_named(still_tide, "exemption", 0, 1), "exemption sits off Pell's middle row")
	check(play_named(still_tide, "duty", 1, 1), "the middle-row duty stays refused")
	check(still_tide.last_progress_gained == 1, "an exemption off the middle row does not open the middle row (%d)" % still_tide.last_progress_gained)

	var refused_ripple = Rules.scripted_encounter(71, 0, ["entry_mark", "ripple"], 3, Rules.SHIFT_SALT)
	check(play_named(refused_ripple, "entry_mark", 0, 1), "entry mark is placed above the middle row")
	check(refused_ripple.phase == "play", "the entry mark leaves the turn open")
	check(play_named(refused_ripple, "ripple", 1, 1), "ripple is placed on Pell's middle row")
	check(refused_ripple.last_chain_count == 1, "the refused ripple still retriggers")
	check(refused_ripple.last_progress_gained == 4, "the middle-row ripple scores 0 and the retrigger still pays (%d)" % refused_ripple.last_progress_gained)

	var refused_hold = Rules.scripted_encounter(71, 0, ["hold"], 1, Rules.SHIFT_SALT)
	check(play_named(refused_hold, "hold", 1, 1), "hold is placed on the middle row, in Pell's column")
	check(refused_hold.last_progress_gained == 0, "the refused hold grants no progress")
	check(refused_hold.last_patience_loss == 0 and refused_hold.patience == 5, "a refused hold still delays Pell")

	var open_hold = Rules.scripted_encounter(71, 0, ["hold"], 1, Rules.SHIFT_SALT)
	check(play_named(open_hold, "hold", 0, 1), "hold is placed on the top row of Pell's column")
	check(open_hold.last_progress_gained == 1, "hold on the top row still scores")
	check(open_hold.last_patience_loss == 0 and open_hold.patience == 5, "hold in Pell's column delays her")

	var missed_hold = Rules.scripted_encounter(71, 0, ["hold"], 1, Rules.SHIFT_SALT)
	check(play_named(missed_hold, "hold", 0, 0), "hold outside Pell's column")
	check(missed_hold.last_progress_gained == 1, "hold outside column 2 still scores")
	check(missed_hold.last_patience_loss == 1, "hold in another column does not delay Pell")

	var june_pair = Rules.scripted_encounter(72, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_SALT)
	check(String(Rules.traveler(june_pair)["name"]) == "June Hart", "the salt watch's second form is June Hart")
	check(String(Rules.traveler(june_pair)["form_name"]) == "Pair Toll", "June brings the Pair Toll")
	check(String(Rules.traveler(june_pair)["rule_text"]) == "Patience drops by 2 if two stamps share a number.", "June's form states the pair toll")
	check(play_named(june_pair, "entry_mark", 0, 0), "June's first entry mark")
	check(june_pair.phase == "play", "the pair is still open")
	check(play_named(june_pair, "entry_mark", 0, 1), "June receives a second entry mark, the wrong stamp")
	check(june_pair.last_progress_gained == 4, "two shared numbers still score (%d)" % june_pair.last_progress_gained)
	check(june_pair.last_patience_loss == 2, "two stamps that grant 2 drop June's patience by 2 (%d)" % june_pair.last_patience_loss)
	check(june_pair.patience == 3, "June's patience is 3 after the pair toll")

	var june_split = Rules.scripted_encounter(72, 1, ["entry_mark", "duty"], 2, Rules.SHIFT_SALT)
	check(play_named(june_split, "entry_mark", 0, 0), "an entry mark grants 2")
	check(play_named(june_split, "duty", 2, 1), "June receives a bottom-row duty, the correct stamp")
	check(june_split.last_progress_gained == 6, "2 and 4 still score for June (%d)" % june_split.last_progress_gained)
	check(june_split.last_patience_loss == 1, "a 2 and a 4 do not share a number")

	var june_same_card = Rules.scripted_encounter(72, 1, ["duty", "duty"], 2, Rules.SHIFT_SALT)
	check(play_named(june_same_card, "duty", 0, 0), "a top-row duty grants 2")
	check(play_named(june_same_card, "duty", 2, 2), "a bottom-row duty grants 4")
	check(june_same_card.last_progress_gained == 6, "two duties on different rows still score")
	check(june_same_card.last_patience_loss == 1, "the same card does not share when the numbers differ")

	var june_other_card = Rules.scripted_encounter(72, 1, ["duty", "entry_mark"], 2, Rules.SHIFT_SALT)
	check(play_named(june_other_card, "duty", 0, 0), "a top-row duty grants 2")
	check(play_named(june_other_card, "entry_mark", 2, 0), "an entry mark also grants 2")
	check(june_other_card.last_patience_loss == 2, "different cards share a number when both grant 2")

	var june_one = Rules.scripted_encounter(72, 1, ["entry_mark"], 1, Rules.SHIFT_SALT)
	check(play_named(june_one, "entry_mark", 1, 1), "June receives one stamp")
	check(june_one.last_progress_gained == 2, "one stamp still scores")
	check(june_one.last_patience_loss == 1, "one stamp cannot share a number")

	var june_above = Rules.scripted_encounter(72, 1, ["entry_mark", "surcharge"], 2, Rules.SHIFT_SALT)
	check(play_named(june_above, "entry_mark", 0, 0), "the cell above a surcharge grants 2")
	check(play_named(june_above, "surcharge", 1, 0), "the surcharge grants 5")
	check(june_above.last_progress_gained == 7, "the filled cell changes the surcharge number (%d)" % june_above.last_progress_gained)
	check(june_above.last_patience_loss == 1, "2 and 5 do not share a number")

	var june_flat = Rules.scripted_encounter(72, 1, ["surcharge", "surcharge"], 2, Rules.SHIFT_SALT)
	check(play_named(june_flat, "surcharge", 0, 0), "a surcharge with nothing above grants 2")
	check(play_named(june_flat, "surcharge", 0, 2), "another open surcharge grants 2")
	check(june_flat.last_patience_loss == 2, "two surcharges that both grant 2 share a number")

	var june_three = Rules.scripted_encounter(72, 1, ["visa_dot", "entry_mark", "duty"], 3, Rules.SHIFT_SALT)
	check(play_named(june_three, "visa_dot", 0, 0), "a visa dot grants 3")
	check(play_named(june_three, "entry_mark", 0, 1), "an entry mark grants 2")
	check(play_named(june_three, "duty", 2, 2), "a bottom-row duty grants 4")
	check(june_three.last_progress_gained == 9, "three different numbers still score")
	check(june_three.last_patience_loss == 1, "three different numbers keep the drop at 1")

	var june_match = Rules.scripted_encounter(72, 1, ["entry_mark", "entry_mark", "visa_dot"], 3, Rules.SHIFT_SALT)
	check(play_named(june_match, "entry_mark", 0, 0), "first of a matching pair")
	check(play_named(june_match, "entry_mark", 0, 1), "second of a matching pair")
	check(play_named(june_match, "visa_dot", 2, 2), "a third stamp with a different number")
	check(june_match.last_progress_gained == 7, "the unmatched stamp still scores")
	check(june_match.last_patience_loss == 2, "one matching pair is enough to toll June")

	var june_blank = Rules.scripted_encounter(72, 1, ["entry_mark"], 1, Rules.SHIFT_SALT)
	Rules.end_turn(june_blank)
	check(june_blank.last_progress_gained == 0, "an empty form scores nothing for June")
	check(june_blank.last_patience_loss == 1, "an empty form does not share a number")

	var june_spared = Rules.scripted_encounter(72, 1, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_SALT)
	check(play_named(june_spared, "exemption", 2, 0), "exemption on June's bottom row")
	check(play_named(june_spared, "entry_mark", 0, 0), "first entry mark under the exemption")
	check(play_named(june_spared, "entry_mark", 0, 1), "second entry mark under the exemption")
	check(june_spared.last_patience_loss == 1, "exemption keeps June's drop at 1")
	check(june_spared.last_progress_gained == 5, "the shared stamps still score under the exemption")

	var june_open = Rules.scripted_encounter(72, 1, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_SALT)
	check(play_named(june_open, "exemption", 0, 0), "exemption sits off June's bottom row")
	check(play_named(june_open, "entry_mark", 1, 0), "first entry mark beside that exemption")
	check(play_named(june_open, "entry_mark", 1, 1), "second entry mark beside that exemption")
	check(june_open.last_patience_loss == 2, "an exemption off the bottom row leaves the pair toll")

	var june_held = Rules.scripted_encounter(72, 1, ["hold", "entry_mark", "entry_mark"], 3, Rules.SHIFT_SALT)
	check(play_named(june_held, "entry_mark", 0, 0), "first shared entry mark")
	check(play_named(june_held, "entry_mark", 0, 1), "second shared entry mark")
	check(play_named(june_held, "hold", 1, 2), "hold in June's column while two stamps share a number")
	check(june_held.last_progress_gained == 5, "the held pair still scores")
	check(june_held.last_patience_loss == 0 and june_held.patience == 5, "hold delays June before the pair toll")

	var june_missed = Rules.scripted_encounter(72, 1, ["hold", "entry_mark", "entry_mark"], 3, Rules.SHIFT_SALT)
	check(play_named(june_missed, "entry_mark", 0, 0), "first shared entry mark outside the hold")
	check(play_named(june_missed, "entry_mark", 0, 1), "second shared entry mark outside the hold")
	check(play_named(june_missed, "hold", 1, 0), "hold outside June's column")
	check(june_missed.last_patience_loss == 2, "hold in another column does not spare June")

	var cal_center = Rules.scripted_encounter(73, 2, ["entry_mark"], 1, Rules.SHIFT_SALT)
	check(String(Rules.traveler(cal_center)["name"]) == "Cal Mire", "the salt watch's third form is Cal Mire")
	check(String(Rules.traveler(cal_center)["form_name"]) == "Edge Yield", "Cal brings the Edge Yield")
	check(String(Rules.traveler(cal_center)["rule_text"]) == "A stamp on the outer frame yields +3. The center cell does not.", "Cal's form states the frame rule")
	check(Rules.preview_progress(cal_center, "entry_mark", 1, 1) == 2, "preview leaves the center entry mark at 2")
	check(Rules.preview_progress(cal_center, "entry_mark", 0, 0) == 5, "preview adds 3 on a corner")
	check(Rules.preview_progress(cal_center, "entry_mark", 1, 0) == 5, "preview adds 3 on the side of the middle row")
	check(Rules.preview_progress(cal_center, "duty", 2, 2) == 7, "preview adds 3 to a bottom-row duty")
	check(Rules.preview_progress(cal_center, "duty", 1, 1) == 2, "preview does not add 3 to a center duty")
	check(play_named(cal_center, "entry_mark", 1, 1), "Cal receives a center entry mark, the wrong stamp")
	check(cal_center.last_progress_gained == 2, "the center cell does not yield (%d)" % cal_center.last_progress_gained)

	var cal_frame = Rules.scripted_encounter(73, 2, ["entry_mark"], 1, Rules.SHIFT_SALT)
	check(play_named(cal_frame, "entry_mark", 0, 0), "Cal receives a corner entry mark, the correct stamp")
	check(cal_frame.last_progress_gained == 5, "a frame stamp yields +3 (%d)" % cal_frame.last_progress_gained)

	var cal_side = Rules.scripted_encounter(73, 2, ["entry_mark"], 1, Rules.SHIFT_SALT)
	check(play_named(cal_side, "entry_mark", 1, 2), "Cal receives the right-hand cell of the middle row")
	check(cal_side.last_progress_gained == 5, "the outer frame is every cell except the center (%d)" % cal_side.last_progress_gained)

	var cal_pair = Rules.scripted_encounter(73, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_SALT)
	check(play_named(cal_pair, "entry_mark", 0, 0), "first frame stamp")
	check(play_named(cal_pair, "entry_mark", 2, 2), "second frame stamp")
	check(cal_pair.last_progress_gained == 10, "each frame stamp yields +3 (%d)" % cal_pair.last_progress_gained)

	var cal_mixed = Rules.scripted_encounter(73, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_SALT)
	check(play_named(cal_mixed, "entry_mark", 1, 1), "the center stamp")
	check(play_named(cal_mixed, "entry_mark", 0, 2), "a frame stamp beside the center")
	check(cal_mixed.last_progress_gained == 7, "only the frame stamp yields +3 (%d)" % cal_mixed.last_progress_gained)

	var cal_muted = Rules.scripted_encounter(73, 2, ["exemption", "entry_mark"], 2, Rules.SHIFT_SALT)
	check(play_named(cal_muted, "exemption", 0, 1), "exemption is placed on Cal's top row")
	check(cal_muted.phase == "play", "Cal's exemption leaves the turn open")
	check(play_named(cal_muted, "entry_mark", 0, 2), "a frame stamp follows the exemption")
	check(cal_muted.last_progress_gained == 3, "exemption cancels Cal's frame yield (%d)" % cal_muted.last_progress_gained)

	var cal_kept = Rules.scripted_encounter(73, 2, ["exemption", "entry_mark"], 2, Rules.SHIFT_SALT)
	check(play_named(cal_kept, "exemption", 1, 0), "exemption sits on the frame, off Cal's top row")
	check(play_named(cal_kept, "entry_mark", 0, 0), "a frame stamp beside that exemption")
	check(cal_kept.last_progress_gained == 9, "an exemption off the top row leaves the frame yield (%d)" % cal_kept.last_progress_gained)

	var cal_echo = Rules.scripted_encounter(73, 2, ["echo", "entry_mark"], 2, Rules.SHIFT_SALT)
	check(play_named(cal_echo, "echo", 0, 0), "echo is placed on the frame")
	check(play_named(cal_echo, "entry_mark", 1, 0), "entry mark is placed under the echo, still on the frame")
	check(cal_echo.last_chain_count == 1, "the frame echo still retriggers")
	check(cal_echo.last_progress_gained == 14, "a retrigger of a frame stamp yields +3 again (%d)" % cal_echo.last_progress_gained)

	var cal_center_echo = Rules.scripted_encounter(73, 2, ["echo", "entry_mark"], 2, Rules.SHIFT_SALT)
	check(play_named(cal_center_echo, "echo", 0, 1), "echo is placed above the center")
	check(play_named(cal_center_echo, "entry_mark", 1, 1), "entry mark is placed in the center")
	check(cal_center_echo.last_chain_count == 1, "echo still retriggers the center")
	check(cal_center_echo.last_progress_gained == 8, "a retrigger of the center does not yield +3 (%d)" % cal_center_echo.last_progress_gained)

	var cal_held = Rules.scripted_encounter(73, 2, ["hold"], 1, Rules.SHIFT_SALT)
	check(play_named(cal_held, "hold", 2, 0), "hold is placed on the frame in Cal's column")
	check(cal_held.last_progress_gained == 4, "a frame hold yields +3")
	check(cal_held.last_patience_loss == 0 and cal_held.patience == 5, "a frame hold still delays Cal")

	var cal_center_hold = Rules.scripted_encounter(73, 2, ["hold"], 1, Rules.SHIFT_SALT)
	check(play_named(cal_center_hold, "hold", 1, 1), "hold is placed in the center, outside Cal's column")
	check(cal_center_hold.last_progress_gained == 1, "the center hold does not yield")
	check(cal_center_hold.last_patience_loss == 1, "a center hold is outside Cal's column")

	var ned = Rules.scripted_encounter(74, 3, ["entry_mark", "duty"], 3, Rules.SHIFT_SALT)
	check(String(Rules.traveler(ned)["name"]) == "Ned Quill", "the salt watch's fourth form is Ned Quill")
	check(String(Rules.traveler(ned)["form_name"]) == "Last Slip", "Ned brings the Last Slip")
	check(String(Rules.traveler(ned)["rule_text"]) == "The last stamp in the queue scores twice.", "Ned's form states the queue-tail rule")
	check(Rules.preview_progress(ned, "duty", 2, 2) == 8, "preview doubles a lone bottom-row duty")
	check(Rules.preview_progress(ned, "duty", 0, 0) == 4, "preview doubles a lone top-row duty")
	check(play_named(ned, "entry_mark", 2, 2), "a later cell is filled before the preview")
	check(ned.phase == "play", "the tail stamp leaves the turn open")
	check(Rules.can_play(ned, 0, 2, 0), "rules accept an earlier duty as a placement")
	check(Rules.preview_progress(ned, "duty", 2, 0) == 4, "preview does not double a duty with a stamp later in the queue")
	check(Rules.preview_progress(ned, "duty", 0, 0) == 2, "preview does not double a top-row duty once a later stamp exists")

	var early = Rules.scripted_encounter(74, 3, ["duty", "entry_mark"], 2, Rules.SHIFT_SALT)
	check(play_named(early, "duty", 2, 0), "Ned receives a bottom-row duty, the wrong stamp")
	check(play_named(early, "entry_mark", 2, 1), "a stamp is placed later in that row")
	check(early.last_progress_gained == 8, "the earlier bottom-row duty is not doubled (%d)" % early.last_progress_gained)

	var tail = Rules.scripted_encounter(74, 3, ["duty"], 1, Rules.SHIFT_SALT)
	check(play_named(tail, "duty", 2, 2), "Ned receives a lone bottom-row duty, the correct stamp")
	check(tail.last_progress_gained == 8, "Ned doubles the last stamp (%d)" % tail.last_progress_gained)

	var split = Rules.scripted_encounter(74, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_SALT)
	check(play_named(split, "entry_mark", 0, 0), "the earlier entry mark")
	check(play_named(split, "entry_mark", 0, 1), "the later entry mark in that row")
	check(split.last_progress_gained == 6, "only the later entry mark is doubled (%d)" % split.last_progress_gained)

	var muted = Rules.scripted_encounter(74, 3, ["exemption", "duty"], 2, Rules.SHIFT_SALT)
	check(play_named(muted, "exemption", 2, 1), "exemption is placed on Ned's bottom row")
	check(muted.phase == "play", "Ned's exemption leaves the turn open")
	check(play_named(muted, "duty", 2, 2), "the tail duty follows the exemption")
	check(muted.last_progress_gained == 5, "exemption on the bottom row cancels Ned's doubling (%d)" % muted.last_progress_gained)

	var kept = Rules.scripted_encounter(74, 3, ["duty", "exemption"], 2, Rules.SHIFT_SALT)
	check(play_named(kept, "duty", 2, 2), "the queue tail under an off-row exemption")
	check(play_named(kept, "exemption", 0, 0), "exemption sits off Ned's bottom row")
	check(kept.last_progress_gained == 9, "an exemption off the bottom row leaves the tail doubled (%d)" % kept.last_progress_gained)

	var doubled_reply = Rules.scripted_encounter(74, 3, ["entry_mark", "reply"], 2, Rules.SHIFT_SALT)
	check(play_named(doubled_reply, "entry_mark", 1, 1), "entry mark sits above the reply")
	check(play_named(doubled_reply, "reply", 2, 1), "reply is the last stamp in the queue")
	check(doubled_reply.last_chain_count == 1, "the doubled reply still retriggers")
	check(doubled_reply.last_progress_gained == 6, "the tail reply scores twice and the earlier retrigger does not (%d)" % doubled_reply.last_progress_gained)

	var plain_reply = Rules.scripted_encounter(74, 3, ["entry_mark", "reply", "entry_mark"], 3, Rules.SHIFT_SALT)
	check(play_named(plain_reply, "entry_mark", 1, 1), "entry mark sits above a reply that is not last")
	check(play_named(plain_reply, "reply", 2, 1), "reply is placed before the last cell")
	check(play_named(plain_reply, "entry_mark", 2, 2), "a later stamp keeps the reply off the tail")
	check(plain_reply.last_chain_count == 1, "a reply that is not last still retriggers")
	check(plain_reply.last_progress_gained == 9, "the reply scores 1 and the later stamp is doubled (%d)" % plain_reply.last_progress_gained)

	var doubled_hold = Rules.scripted_encounter(74, 3, ["hold"], 1, Rules.SHIFT_SALT)
	check(play_named(doubled_hold, "hold", 2, 1), "hold is the last stamp in Ned's column")
	check(doubled_hold.last_progress_gained == 2, "the tail hold scores twice")
	check(doubled_hold.last_patience_loss == 0 and doubled_hold.patience == 5, "a doubled hold still delays Ned")

	var missed_ned = Rules.scripted_encounter(74, 3, ["hold"], 1, Rules.SHIFT_SALT)
	check(play_named(missed_ned, "hold", 2, 0), "a doubled hold outside Ned's column")
	check(missed_ned.last_progress_gained == 2, "the tail hold still scores twice outside the lane")
	check(missed_ned.last_patience_loss == 1, "a doubled hold in another column does not delay Ned")

	var moss = Rules.scripted_encounter(21, 0, ["duty"], 1, Rules.SHIFT_CLOSING)
	check(play_named(moss, "duty", 1, 1), "Moss receives a middle-row duty")
	check(moss.last_progress_gained == 0, "the closing bell still refuses the middle row (%d)" % moss.last_progress_gained)
	var nim = Rules.scripted_encounter(34, 3, ["duty"], 1, Rules.SHIFT_ASH)
	check(play_named(nim, "duty", 2, 2), "Nim receives a lone bottom-row duty")
	check(nim.last_progress_gained == 8, "the ash watch still doubles the last stamp (%d)" % nim.last_progress_gained)
	var bram = Rules.scripted_encounter(5, 1, ["entry_mark", "entry_mark"], 2)
	check(play_named(bram, "entry_mark", 1, 0), "Bram's first entry mark")
	check(play_named(bram, "entry_mark", 1, 1), "Bram's second entry mark shares column 2")
	check(bram.last_progress_gained == 8, "Act 1 still yields for column 2 (%d)" % bram.last_progress_gained)
	check(bram.last_patience_loss == 1, "Act 1 does not toll two stamps that grant 2")
	var ada = Rules.scripted_encounter(5, 0, ["entry_mark"], 1)
	check(play_named(ada, "entry_mark", 2, 0), "Ada receives a bottom-row entry mark")
	check(ada.last_progress_gained == 2, "Act 1 does not add 3 on the outer frame (%d)" % ada.last_progress_gained)


func test_salt_watch_opens() -> void:
	check(Rules.SALT_WATCH.size() == 4, "the salt watch has four travelers")
	check(Rules.TRAVELERS.size() == 4 and String(Rules.TRAVELERS[0]["name"]) == "Ada Quill", "Act 1 still begins with Ada Quill")
	check(String(Rules.TRAVELERS[3]["name"]) == "Doss Kite", "Act 1 still ends with Doss Kite")
	check(Rules.LATE_SHIFT.size() == 4 and String(Rules.LATE_SHIFT[0]["name"]) == "Nell Parr", "the late shift still begins with Nell Parr")
	check(String(Rules.LATE_SHIFT[3]["name"]) == "Rue Calder", "the late shift still ends with Rue Calder")
	check(Rules.CLOSING_BELL.size() == 4 and String(Rules.CLOSING_BELL[0]["name"]) == "Moss Quen", "the closing bell still begins with Moss Quen")
	check(String(Rules.CLOSING_BELL[3]["name"]) == "Lumen Peck", "the closing bell still ends with Lumen Peck")
	check(Rules.ASH_WATCH.size() == 4 and String(Rules.ASH_WATCH[0]["name"]) == "Orla Fen", "the ash watch still begins with Orla Fen")
	check(String(Rules.ASH_WATCH[3]["name"]) == "Nim Harth", "the ash watch still ends with Nim Harth")
	check(Rules.GUTTER_LAMP.size() == 4 and String(Rules.GUTTER_LAMP[0]["name"]) == "Ivo Dane", "the gutter lamp still begins with Ivo Dane")
	check(String(Rules.GUTTER_LAMP[3]["name"]) == "Kit Yarrow", "the gutter lamp still ends with Kit Yarrow")
	check(Rules.VELLUM_BELL.size() == 4 and String(Rules.VELLUM_BELL[0]["name"]) == "Edda Voss", "the vellum bell still begins with Edda Voss")
	check(String(Rules.VELLUM_BELL[3]["name"]) == "Lark Pym", "the vellum bell still ends with Lark Pym")
	check(Rules.QUIRE_WATCH.size() == 4 and String(Rules.QUIRE_WATCH[0]["name"]) == "Tess Quern", "the quire watch still begins with Tess Quern")
	check(String(Rules.QUIRE_WATCH[3]["name"]) == "Ida Cress", "the quire watch still ends with Ida Cress")
	var salt = Rules.new_run(77, Rules.SHIFT_SALT)
	check(salt.shift == Rules.SHIFT_SALT, "the salt watch is a separate night")
	check(String(Rules.traveler(salt)["name"]) == "Pell Voss", "the salt watch begins with Pell Voss")
	check(salt.hand.size() == Rules.HAND_SIZE, "the salt watch draws 5")
	check(salt.ink == Rules.BASE_INK, "the salt watch starts at 3 ink")
	check(salt.library.size() == Rules.STARTING_DECK.size(), "the salt watch deals the starting deck")
	check(salt.relic_id == "", "an earlier night's relic does not carry")
	check(salt.phase == "play", "the salt watch opens in play")
	var dealt: Array = []
	for iid in salt.hand:
		dealt.append(Rules.card_id_of(salt, int(iid)))
	var before = salt.library.size()
	salt.progress = 4
	salt.patience = 1
	Rules.restart_encounter(salt)
	check(salt.shift == Rules.SHIFT_SALT and salt.traveler_index == 0, "restart encounter stays on the salt watch")
	check(salt.progress == 0 and salt.patience == int(Rules.SALT_WATCH[0]["patience"]), "restart encounter resets Pell")
	check(salt.library.size() == before and salt.hand.size() == 5 and salt.phase == "play", "restart keeps the salt-watch deck and deals a hand")
	var redealt: Array = []
	for iid in salt.hand:
		redealt.append(Rules.card_id_of(salt, int(iid)))
	check(redealt == dealt, "restart deals Pell the same hand")

	var packed = load("res://game/main.tscn")
	var desk = packed.instantiate()
	root.add_child(desk)
	if desk.state == null:
		desk._ready()
	check(desk.state.shift == Rules.SHIFT_FIRST, "the desk still opens on Act 1")
	check(desk.salt_button.text == "Salt watch", "the desk offers the salt watch")
	check(desk.quire_button.text == "Quire watch", "the desk still offers the quire watch")
	check(desk.shift_button.text == "Late shift", "the desk still offers the late shift")
	check(desk.closing_button.text == "Closing bell", "the desk still offers the closing bell")
	check(desk.ash_button.text == "Ash watch", "the desk still offers the ash watch")
	check(desk.gutter_button.text == "Gutter lamp", "the desk still offers the gutter lamp")
	check(desk.vellum_button.text == "Vellum bell", "the desk still offers the vellum bell")
	desk.salt_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_SALT, "the desk can open the salt watch")
	check(String(Rules.traveler(desk.state)["name"]) == "Pell Voss", "the open desk shows Pell")
	check(String(desk.desk_label.text).begins_with("Salt watch"), "the desk title follows the salt watch")
	check(desk.meta_label.text.contains("Tide Bar"), "the desk shows Pell's form")
	check(desk.salt_button.text == "First bell", "the salt watch can return to the first bell")
	check(desk.shift_button.text == "Late shift", "the late shift stays available from the salt watch")
	check(desk.closing_button.text == "Closing bell", "the closing bell stays available from the salt watch")
	check(desk.ash_button.text == "Ash watch", "the ash watch stays available from the salt watch")
	check(desk.gutter_button.text == "Gutter lamp", "the gutter lamp stays available from the salt watch")
	check(desk.vellum_button.text == "Vellum bell", "the vellum bell stays available from the salt watch")
	check(desk.quire_button.text == "Quire watch", "the quire watch stays available from the salt watch")
	desk._restart_act()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_SALT and String(Rules.traveler(desk.state)["name"]) == "Pell Voss", "restart act replays the salt watch")
	desk.salt_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the salt watch returns to Ada")
	desk._toggle_shift()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_LATE and String(Rules.traveler(desk.state)["name"]) == "Nell Parr", "the late shift still opens from the first bell")
	check(desk.salt_button.text == "Salt watch", "the late shift offers the salt watch")
	desk._begin_salt_watch()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_SALT and String(Rules.traveler(desk.state)["name"]) == "Pell Voss", "the late shift can open the salt watch")
	desk._toggle_closing()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_CLOSING and String(Rules.traveler(desk.state)["name"]) == "Moss Quen", "the salt watch can open the closing bell")
	check(desk.salt_button.text == "Salt watch", "the closing bell offers the salt watch")
	desk.salt_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_SALT and String(Rules.traveler(desk.state)["name"]) == "Pell Voss", "the closing bell can open the salt watch")
	desk._toggle_ash()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_ASH and String(Rules.traveler(desk.state)["name"]) == "Orla Fen", "the salt watch can open the ash watch")
	check(desk.salt_button.text == "Salt watch", "the ash watch offers the salt watch")
	desk._begin_salt_watch()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_SALT and String(Rules.traveler(desk.state)["name"]) == "Pell Voss", "the ash watch can open the salt watch")
	desk._toggle_gutter()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_GUTTER and String(Rules.traveler(desk.state)["name"]) == "Ivo Dane", "the salt watch can open the gutter lamp")
	check(desk.salt_button.text == "Salt watch", "the gutter lamp offers the salt watch")
	desk._begin_salt_watch()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_SALT and String(Rules.traveler(desk.state)["name"]) == "Pell Voss", "the gutter lamp can open the salt watch")
	desk._toggle_vellum()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_VELLUM and String(Rules.traveler(desk.state)["name"]) == "Edda Voss", "the salt watch can open the vellum bell")
	check(desk.salt_button.text == "Salt watch", "the vellum bell offers the salt watch")
	desk._begin_salt_watch()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_SALT and String(Rules.traveler(desk.state)["name"]) == "Pell Voss", "the vellum bell can open the salt watch")
	desk._toggle_quire()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_QUIRE and String(Rules.traveler(desk.state)["name"]) == "Tess Quern", "the salt watch can open the quire watch")
	check(desk.salt_button.text == "Salt watch", "the quire watch offers the salt watch")
	desk._begin_salt_watch()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_SALT and String(Rules.traveler(desk.state)["name"]) == "Pell Voss", "the quire watch can open the salt watch")
	desk._begin_first_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "first bell still returns to Ada")
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_salt = _button_named(desk, "Open the salt watch")
	check(victory_salt != null, "Act 1's victory desk offers the salt watch")
	if victory_salt != null:
		victory_salt.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_SALT and String(Rules.traveler(desk.state)["name"]) == "Pell Voss", "the victory desk opens the salt watch")
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_first = _button_named(desk, "Open the first bell")
	check(victory_first != null, "the salt watch victory desk offers the first bell")
	if victory_first != null:
		victory_first.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the salt watch victory desk opens the first bell")
	desk._begin_quire_watch()
	desk._refresh_ui()
	desk.state.phase = "victory"
	desk._refresh_ui()
	var quire_salt = _button_named(desk, "Open the salt watch")
	check(quire_salt != null, "the quire watch victory desk offers the salt watch")
	if quire_salt != null:
		quire_salt.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_SALT and String(Rules.traveler(desk.state)["name"]) == "Pell Voss", "the quire watch victory desk opens the salt watch")
	root.remove_child(desk)
	desk.free()


func test_policy_clears_salt_watch() -> void:
	var started = Time.get_ticks_msec()
	var state = Rules.new_run(12345, Rules.SHIFT_SALT)
	var steps = 0
	var seen = 0
	while state.phase != "victory":
		steps += 1
		if steps > 500 or state.phase == "defeat":
			check(false, "policy lost or stalled on the salt watch, seed 12345: " + Rules.debug_summary(state))
			return
		var action = Policy.choose(state)
		if not Rules.apply_action(state, action):
			check(false, "salt-watch policy action was rejected: %s / %s" % [str(action), Rules.debug_summary(state)])
			return
		if state.encounters_cleared != seen:
			seen = state.encounters_cleared
			print("cleared salt encounter %d after %d actions" % [seen, steps])
	var elapsed = Time.get_ticks_msec() - started
	check(state.encounters_cleared == 4, "policy cleared all 4 salt-watch encounters on seed 12345")
	check(state.phase == "victory", "salt watch ends in victory")
	check(state.shift == Rules.SHIFT_SALT, "the clear stayed on the salt watch")
	print("salt watch finished in %d actions, %d ms" % [steps, elapsed])


func test_quay_bell_rules() -> void:
	var mara = Rules.scripted_encounter(81, 0, ["duty", "entry_mark"], 3, Rules.SHIFT_QUAY)
	check(String(Rules.traveler(mara)["name"]) == "Mara Quill", "the quay bell's first form is Mara Quill")
	check(String(Rules.traveler(mara)["form_name"]) == "First Bar", "Mara brings the First Bar")
	check(String(Rules.traveler(mara)["rule_text"]) == "The first stamp in the queue scores 0 unless an Exemption is on the top row.", "Mara's form states the first-stamp rule")
	check(Rules.preview_progress(mara, "duty", 2, 2) == 0, "preview zeros a lone bottom-row duty for Mara")
	check(Rules.preview_progress(mara, "duty", 0, 0) == 0, "preview zeros a lone top-row duty for Mara")
	check(Rules.preview_progress(mara, "entry_mark", 1, 1) == 0, "preview zeros a lone center stamp for Mara")

	var wrong = Rules.scripted_encounter(81, 0, ["duty"], 1, Rules.SHIFT_QUAY)
	check(play_named(wrong, "duty", 2, 2), "Mara receives a lone bottom-row duty, the wrong stamp")
	check(wrong.last_progress_gained == 0, "a lone stamp is first, so Mara scores 0 (%d)" % wrong.last_progress_gained)
	check(wrong.last_patience_loss == 1, "a refused first stamp still spends the turn")

	var right = Rules.scripted_encounter(81, 0, ["entry_mark", "duty"], 2, Rules.SHIFT_QUAY)
	check(play_named(right, "entry_mark", 0, 0), "an earlier entry mark is the queue head")
	check(play_named(right, "duty", 2, 2), "Mara receives a later bottom-row duty, the correct stamp")
	check(right.last_progress_gained == 4, "the later duty scores and the first stamp scores 0 (%d)" % right.last_progress_gained)

	var top_later = Rules.scripted_encounter(81, 0, ["entry_mark", "duty"], 2, Rules.SHIFT_QUAY)
	check(play_named(top_later, "entry_mark", 0, 0), "the left cell of the top row is first")
	check(play_named(top_later, "duty", 0, 2), "a later top-row duty")
	check(top_later.last_progress_gained == 2, "a top-row stamp still counts when an earlier cell is filled (%d)" % top_later.last_progress_gained)

	var pressed_last = Rules.scripted_encounter(81, 0, ["duty", "entry_mark"], 2, Rules.SHIFT_QUAY)
	check(play_named(pressed_last, "duty", 2, 2), "the bottom duty is pressed first")
	check(pressed_last.phase == "play", "the first press leaves Mara's turn open")
	check(play_named(pressed_last, "entry_mark", 0, 0), "the top stamp is pressed last")
	check(pressed_last.last_progress_gained == 4, "queue order, not press order, chooses Mara's first stamp (%d)" % pressed_last.last_progress_gained)

	var spared = Rules.scripted_encounter(81, 0, ["exemption", "duty"], 2, Rules.SHIFT_QUAY)
	check(play_named(spared, "duty", 0, 0), "a top-row duty would be the queue head")
	check(play_named(spared, "exemption", 0, 1), "exemption is placed on Mara's top row")
	check(spared.last_progress_gained == 3, "exemption on the top row lets the first stamp count (%d)" % spared.last_progress_gained)

	var head_exempt = Rules.scripted_encounter(81, 0, ["exemption", "duty"], 2, Rules.SHIFT_QUAY)
	check(play_named(head_exempt, "exemption", 0, 0), "exemption itself is the first stamp")
	check(play_named(head_exempt, "duty", 2, 2), "a later duty follows that exemption")
	check(head_exempt.last_progress_gained == 5, "an exemption on the top row counts, and the later duty counts (%d)" % head_exempt.last_progress_gained)

	var still_bar = Rules.scripted_encounter(81, 0, ["exemption", "duty"], 2, Rules.SHIFT_QUAY)
	check(play_named(still_bar, "duty", 0, 0), "the queue head under an off-row exemption")
	check(play_named(still_bar, "exemption", 1, 1), "exemption sits off Mara's top row")
	check(still_bar.last_progress_gained == 1, "an exemption off the top row leaves the first stamp at 0 (%d)" % still_bar.last_progress_gained)

	var refused_echo = Rules.scripted_encounter(81, 0, ["echo", "entry_mark"], 2, Rules.SHIFT_QUAY)
	check(play_named(refused_echo, "echo", 0, 0), "echo is the first stamp")
	check(play_named(refused_echo, "entry_mark", 1, 0), "entry mark is placed under the echo")
	check(refused_echo.last_chain_count == 1, "the refused echo still retriggers")
	check(refused_echo.last_progress_gained == 4, "the first echo scores 0 and the later stamp still pays (%d)" % refused_echo.last_progress_gained)

	var refused_reply = Rules.scripted_encounter(81, 0, ["entry_mark", "reply"], 2, Rules.SHIFT_QUAY)
	check(play_named(refused_reply, "entry_mark", 0, 0), "entry mark is the queue head")
	check(play_named(refused_reply, "reply", 1, 0), "reply retriggers the stamp above")
	check(refused_reply.last_chain_count == 1, "the reply retriggers the first stamp")
	check(refused_reply.last_progress_gained == 1, "a retrigger of the first stamp scores 0 again (%d)" % refused_reply.last_progress_gained)

	var held = Rules.scripted_encounter(81, 0, ["hold"], 1, Rules.SHIFT_QUAY)
	check(play_named(held, "hold", 0, 1), "hold is the first stamp in Mara's column")
	check(held.last_progress_gained == 0, "the refused hold grants no progress")
	check(held.last_patience_loss == 0 and held.patience == 5, "a refused hold still delays Mara")

	var missed = Rules.scripted_encounter(81, 0, ["hold"], 1, Rules.SHIFT_QUAY)
	check(play_named(missed, "hold", 0, 0), "a refused hold outside Mara's column")
	check(missed.last_progress_gained == 0, "the hold is still the first stamp")
	check(missed.last_patience_loss == 1, "hold in another column does not delay Mara")

	var holt_center = Rules.scripted_encounter(82, 1, ["entry_mark"], 1, Rules.SHIFT_QUAY)
	check(String(Rules.traveler(holt_center)["name"]) == "Holt Venn", "the quay bell's second form is Holt Venn")
	check(String(Rules.traveler(holt_center)["form_name"]) == "Center Toll", "Holt brings the Center Toll")
	check(String(Rules.traveler(holt_center)["rule_text"]) == "Patience drops by 2 if the center cell is filled.", "Holt's form states the center toll")
	check(play_named(holt_center, "entry_mark", 1, 1), "Holt receives a center entry mark, the wrong stamp")
	check(holt_center.last_progress_gained == 2, "the center stamp still scores (%d)" % holt_center.last_progress_gained)
	check(holt_center.last_patience_loss == 2, "a filled center drops Holt's patience by 2 (%d)" % holt_center.last_patience_loss)
	check(holt_center.patience == 3, "Holt's patience is 3 after the center toll")

	var holt_edge = Rules.scripted_encounter(82, 1, ["entry_mark"], 1, Rules.SHIFT_QUAY)
	check(play_named(holt_edge, "entry_mark", 0, 0), "Holt receives a corner entry mark, the correct stamp")
	check(holt_edge.last_progress_gained == 2, "a stamp outside the center still scores")
	check(holt_edge.last_patience_loss == 1, "an empty center keeps Holt's drop at 1")

	var holt_bottom = Rules.scripted_encounter(82, 1, ["duty"], 1, Rules.SHIFT_QUAY)
	check(play_named(holt_bottom, "duty", 2, 1), "Holt receives a bottom-row duty outside the center")
	check(holt_bottom.last_progress_gained == 4, "the bottom-row duty scores 4")
	check(holt_bottom.last_patience_loss == 1, "the bottom row does not toll Holt")

	var holt_blank = Rules.scripted_encounter(82, 1, ["entry_mark"], 1, Rules.SHIFT_QUAY)
	Rules.end_turn(holt_blank)
	check(holt_blank.last_progress_gained == 0, "an empty form scores nothing for Holt")
	check(holt_blank.last_patience_loss == 1, "an empty center does not toll Holt")

	var holt_spared = Rules.scripted_encounter(82, 1, ["exemption", "entry_mark"], 2, Rules.SHIFT_QUAY)
	check(play_named(holt_spared, "exemption", 1, 0), "exemption on Holt's middle row, beside the center")
	check(play_named(holt_spared, "entry_mark", 1, 1), "the center is filled under that exemption")
	check(holt_spared.last_progress_gained == 3, "the center stamp still scores under the exemption")
	check(holt_spared.last_patience_loss == 1, "exemption on the middle row keeps Holt's drop at 1")

	var holt_center_exempt = Rules.scripted_encounter(82, 1, ["exemption"], 1, Rules.SHIFT_QUAY)
	check(play_named(holt_center_exempt, "exemption", 1, 1), "exemption is placed in the center")
	check(holt_center_exempt.last_progress_gained == 1, "a center exemption scores 1")
	check(holt_center_exempt.last_patience_loss == 1, "an exemption in the center is on the middle row")

	var holt_open = Rules.scripted_encounter(82, 1, ["exemption", "entry_mark"], 2, Rules.SHIFT_QUAY)
	check(play_named(holt_open, "exemption", 0, 0), "exemption sits off Holt's middle row")
	check(play_named(holt_open, "entry_mark", 1, 1), "the center is filled beside that exemption")
	check(holt_open.last_patience_loss == 2, "an exemption off the middle row leaves the center toll")

	var holt_held = Rules.scripted_encounter(82, 1, ["entry_mark", "hold"], 2, Rules.SHIFT_QUAY)
	check(play_named(holt_held, "entry_mark", 1, 1), "the center is filled")
	check(play_named(holt_held, "hold", 0, 2), "hold in Holt's column while the center is filled")
	check(holt_held.last_progress_gained == 3, "the held center still scores")
	check(holt_held.last_patience_loss == 0 and holt_held.patience == 5, "hold delays Holt before the center toll")

	var holt_missed = Rules.scripted_encounter(82, 1, ["entry_mark", "hold"], 2, Rules.SHIFT_QUAY)
	check(play_named(holt_missed, "entry_mark", 1, 1), "the center is filled outside the hold")
	check(play_named(holt_missed, "hold", 0, 0), "hold outside Holt's column")
	check(holt_missed.last_patience_loss == 2, "hold in another column does not spare Holt")

	var holt_center_hold = Rules.scripted_encounter(82, 1, ["hold"], 1, Rules.SHIFT_QUAY)
	check(play_named(holt_center_hold, "hold", 1, 1), "hold is placed in the center, outside Holt's column")
	check(holt_center_hold.last_progress_gained == 1, "the center hold still scores")
	check(holt_center_hold.last_patience_loss == 2, "a center hold outside the lane does not delay Holt")

	var sera_edge = Rules.scripted_encounter(83, 2, ["entry_mark"], 1, Rules.SHIFT_QUAY)
	check(String(Rules.traveler(sera_edge)["name"]) == "Sera Dunn", "the quay bell's third form is Sera Dunn")
	check(String(Rules.traveler(sera_edge)["form_name"]) == "Corner Yield", "Sera brings the Corner Yield")
	check(String(Rules.traveler(sera_edge)["rule_text"]) == "A stamp in a corner yields +3. A non-corner edge does not.", "Sera's form states the corner rule")
	check(Rules.preview_progress(sera_edge, "entry_mark", 0, 0) == 5, "preview adds 3 on a corner")
	check(Rules.preview_progress(sera_edge, "entry_mark", 0, 2) == 5, "preview adds 3 on the other top corner")
	check(Rules.preview_progress(sera_edge, "entry_mark", 2, 0) == 5, "preview adds 3 on a bottom corner")
	check(Rules.preview_progress(sera_edge, "duty", 2, 2) == 7, "preview adds 3 to a corner duty")
	check(Rules.preview_progress(sera_edge, "entry_mark", 0, 1) == 2, "preview does not add 3 on the top edge")
	check(Rules.preview_progress(sera_edge, "entry_mark", 1, 0) == 2, "preview does not add 3 on the left edge")
	check(Rules.preview_progress(sera_edge, "entry_mark", 1, 2) == 2, "preview does not add 3 on the right edge")
	check(Rules.preview_progress(sera_edge, "entry_mark", 2, 1) == 2, "preview does not add 3 on the bottom edge")
	check(Rules.preview_progress(sera_edge, "duty", 2, 1) == 4, "preview leaves a non-corner bottom duty at 4")
	check(Rules.preview_progress(sera_edge, "entry_mark", 1, 1) == 2, "preview leaves the center at 2")
	check(play_named(sera_edge, "entry_mark", 1, 0), "Sera receives a non-corner edge, the wrong stamp")
	check(sera_edge.last_progress_gained == 2, "a non-corner edge does not yield (%d)" % sera_edge.last_progress_gained)

	var sera_top_edge = Rules.scripted_encounter(83, 2, ["entry_mark"], 1, Rules.SHIFT_QUAY)
	check(play_named(sera_top_edge, "entry_mark", 0, 1), "Sera receives the middle of the top row")
	check(sera_top_edge.last_progress_gained == 2, "the top edge is not a corner (%d)" % sera_top_edge.last_progress_gained)

	var sera_bottom_edge = Rules.scripted_encounter(83, 2, ["duty"], 1, Rules.SHIFT_QUAY)
	check(play_named(sera_bottom_edge, "duty", 2, 1), "Sera receives the middle of the bottom row")
	check(sera_bottom_edge.last_progress_gained == 4, "a non-corner bottom duty stays at 4 (%d)" % sera_bottom_edge.last_progress_gained)

	var sera_center = Rules.scripted_encounter(83, 2, ["entry_mark"], 1, Rules.SHIFT_QUAY)
	check(play_named(sera_center, "entry_mark", 1, 1), "Sera receives the center")
	check(sera_center.last_progress_gained == 2, "the center does not yield (%d)" % sera_center.last_progress_gained)

	var sera_corner = Rules.scripted_encounter(83, 2, ["entry_mark"], 1, Rules.SHIFT_QUAY)
	check(play_named(sera_corner, "entry_mark", 0, 0), "Sera receives a corner entry mark, the correct stamp")
	check(sera_corner.last_progress_gained == 5, "a corner stamp yields +3 (%d)" % sera_corner.last_progress_gained)

	var sera_other = Rules.scripted_encounter(83, 2, ["entry_mark"], 1, Rules.SHIFT_QUAY)
	check(play_named(sera_other, "entry_mark", 2, 2), "Sera receives the opposite corner")
	check(sera_other.last_progress_gained == 5, "each corner yields +3 (%d)" % sera_other.last_progress_gained)

	var sera_pair = Rules.scripted_encounter(83, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_QUAY)
	check(play_named(sera_pair, "entry_mark", 0, 0), "first corner")
	check(play_named(sera_pair, "entry_mark", 2, 2), "second corner")
	check(sera_pair.last_progress_gained == 10, "each corner stamp yields +3 (%d)" % sera_pair.last_progress_gained)

	var sera_mixed = Rules.scripted_encounter(83, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_QUAY)
	check(play_named(sera_mixed, "entry_mark", 0, 0), "a corner stamp")
	check(play_named(sera_mixed, "entry_mark", 1, 0), "a non-corner edge beside it")
	check(sera_mixed.last_progress_gained == 7, "only the corner yields +3 (%d)" % sera_mixed.last_progress_gained)

	var sera_muted = Rules.scripted_encounter(83, 2, ["exemption", "entry_mark"], 2, Rules.SHIFT_QUAY)
	check(play_named(sera_muted, "exemption", 0, 1), "exemption is placed on Sera's top row, off the corners")
	check(play_named(sera_muted, "entry_mark", 2, 2), "a corner stamp follows the exemption")
	check(sera_muted.last_progress_gained == 3, "exemption on the top row cancels Sera's corner yield (%d)" % sera_muted.last_progress_gained)

	var sera_corner_exempt = Rules.scripted_encounter(83, 2, ["exemption", "entry_mark"], 2, Rules.SHIFT_QUAY)
	check(play_named(sera_corner_exempt, "exemption", 0, 0), "exemption is a top-row corner")
	check(play_named(sera_corner_exempt, "entry_mark", 2, 2), "another corner follows it")
	check(sera_corner_exempt.last_progress_gained == 3, "a cancelling exemption does not itself yield +3 (%d)" % sera_corner_exempt.last_progress_gained)

	var sera_kept = Rules.scripted_encounter(83, 2, ["exemption", "entry_mark"], 2, Rules.SHIFT_QUAY)
	check(play_named(sera_kept, "exemption", 2, 0), "exemption sits on a bottom corner, off Sera's top row")
	check(play_named(sera_kept, "entry_mark", 0, 0), "a corner stamp beside that exemption")
	check(sera_kept.last_progress_gained == 9, "an exemption off the top row leaves both corners yielding (%d)" % sera_kept.last_progress_gained)

	var sera_side_exempt = Rules.scripted_encounter(83, 2, ["exemption", "entry_mark"], 2, Rules.SHIFT_QUAY)
	check(play_named(sera_side_exempt, "exemption", 1, 2), "exemption sits on a non-corner edge")
	check(play_named(sera_side_exempt, "entry_mark", 0, 2), "a corner stamp beside that edge")
	check(sera_side_exempt.last_progress_gained == 6, "the edge exemption scores 1 and the corner yields +3 (%d)" % sera_side_exempt.last_progress_gained)

	var sera_reply = Rules.scripted_encounter(83, 2, ["entry_mark", "reply"], 2, Rules.SHIFT_QUAY)
	check(play_named(sera_reply, "entry_mark", 0, 0), "a corner entry mark")
	check(play_named(sera_reply, "reply", 1, 0), "reply sits under the corner, on a non-corner edge")
	check(sera_reply.last_chain_count == 1, "the reply still retriggers the corner")
	check(sera_reply.last_progress_gained == 11, "a retrigger of a corner yields +3 again (%d)" % sera_reply.last_progress_gained)

	var sera_plain = Rules.scripted_encounter(83, 2, ["entry_mark", "reply"], 2, Rules.SHIFT_QUAY)
	check(play_named(sera_plain, "entry_mark", 1, 0), "a non-corner entry mark")
	check(play_named(sera_plain, "reply", 2, 0), "reply is a corner under that edge")
	check(sera_plain.last_chain_count == 1, "the corner reply still retriggers")
	check(sera_plain.last_progress_gained == 8, "a retrigger of a non-corner edge does not yield +3 (%d)" % sera_plain.last_progress_gained)

	var sera_held = Rules.scripted_encounter(83, 2, ["hold"], 1, Rules.SHIFT_QUAY)
	check(play_named(sera_held, "hold", 0, 0), "hold is placed on a corner in Sera's column")
	check(sera_held.last_progress_gained == 4, "a corner hold yields +3")
	check(sera_held.last_patience_loss == 0 and sera_held.patience == 5, "a corner hold still delays Sera")

	var sera_edge_hold = Rules.scripted_encounter(83, 2, ["hold"], 1, Rules.SHIFT_QUAY)
	check(play_named(sera_edge_hold, "hold", 1, 0), "hold is placed on the non-corner edge of Sera's column")
	check(sera_edge_hold.last_progress_gained == 1, "a non-corner hold does not yield")
	check(sera_edge_hold.last_patience_loss == 0 and sera_edge_hold.patience == 5, "the edge hold still delays Sera")

	var ivo = Rules.scripted_encounter(84, 3, ["entry_mark", "duty"], 3, Rules.SHIFT_QUAY)
	check(String(Rules.traveler(ivo)["name"]) == "Ivo Pell", "the quay bell's fourth form is Ivo Pell")
	check(String(Rules.traveler(ivo)["form_name"]) == "Pair Slip", "Ivo brings the Pair Slip")
	check(String(Rules.traveler(ivo)["rule_text"]) == "If two stamps share a number, the later one scores twice.", "Ivo's form states the pair slip")
	check(Rules.preview_progress(ivo, "entry_mark", 0, 0) == 2, "preview leaves a lone entry mark at 2")
	check(Rules.preview_progress(ivo, "duty", 2, 2) == 4, "preview leaves a lone bottom-row duty at 4")
	check(play_named(ivo, "entry_mark", 0, 0), "an entry mark is placed before the preview")
	check(ivo.phase == "play", "the first stamp leaves Ivo's turn open")
	check(Rules.preview_progress(ivo, "entry_mark", 0, 1) == 4, "preview doubles a later entry mark that shares 2")
	check(Rules.preview_progress(ivo, "duty", 2, 2) == 4, "preview does not double a later duty whose number is 4")
	check(Rules.preview_progress(ivo, "entry_mark", 2, 2) == 4, "preview doubles a later entry mark below the first")

	var lone = Rules.scripted_encounter(84, 3, ["entry_mark"], 1, Rules.SHIFT_QUAY)
	check(play_named(lone, "entry_mark", 0, 0), "Ivo receives one entry mark, the wrong stamp")
	check(lone.last_progress_gained == 2, "one stamp cannot share, so it scores once (%d)" % lone.last_progress_gained)
	check(lone.last_patience_loss == 1, "a lone stamp drops Ivo's patience by 1")

	var split = Rules.scripted_encounter(84, 3, ["entry_mark", "duty"], 2, Rules.SHIFT_QUAY)
	check(play_named(split, "entry_mark", 0, 0), "an entry mark grants 2")
	check(play_named(split, "duty", 2, 1), "Ivo receives a bottom-row duty, a later stamp with a different number")
	check(split.last_progress_gained == 6, "2 and 4 do not share, so the later duty scores once (%d)" % split.last_progress_gained)
	check(split.last_patience_loss == 1, "different numbers do not change Ivo's patience drop")

	var paired = Rules.scripted_encounter(84, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_QUAY)
	check(play_named(paired, "entry_mark", 0, 0), "the earlier entry mark")
	check(play_named(paired, "entry_mark", 0, 1), "Ivo receives a later entry mark, the correct stamp")
	check(paired.last_progress_gained == 6, "the later shared stamp scores twice (%d)" % paired.last_progress_gained)
	check(paired.last_patience_loss == 1, "a shared number does not toll Ivo")

	var other_card = Rules.scripted_encounter(84, 3, ["duty", "entry_mark"], 2, Rules.SHIFT_QUAY)
	check(play_named(other_card, "duty", 0, 0), "a top-row duty grants 2")
	check(play_named(other_card, "entry_mark", 1, 0), "an entry mark also grants 2")
	check(other_card.last_progress_gained == 6, "different cards share a number when both grant 2 (%d)" % other_card.last_progress_gained)

	var same_card = Rules.scripted_encounter(84, 3, ["duty", "duty"], 2, Rules.SHIFT_QUAY)
	check(play_named(same_card, "duty", 0, 0), "a top-row duty grants 2")
	check(play_named(same_card, "duty", 2, 2), "a bottom-row duty grants 4")
	check(same_card.last_progress_gained == 6, "the same card does not share when the numbers differ (%d)" % same_card.last_progress_gained)

	var both_bottom = Rules.scripted_encounter(84, 3, ["duty", "duty"], 2, Rules.SHIFT_QUAY)
	check(play_named(both_bottom, "duty", 2, 0), "an earlier bottom-row duty grants 4")
	check(play_named(both_bottom, "duty", 2, 2), "a later bottom-row duty grants 4")
	check(both_bottom.last_progress_gained == 12, "the later duty of a shared 4 scores twice (%d)" % both_bottom.last_progress_gained)

	var three = Rules.scripted_encounter(84, 3, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_QUAY)
	check(play_named(three, "entry_mark", 0, 0), "first of three shared stamps")
	check(play_named(three, "entry_mark", 0, 1), "second of three shared stamps")
	check(play_named(three, "entry_mark", 0, 2), "third of three shared stamps")
	check(three.last_progress_gained == 10, "the second and the third of a shared number both score twice (%d)" % three.last_progress_gained)

	var last_differs = Rules.scripted_encounter(84, 3, ["entry_mark", "entry_mark", "visa_dot"], 3, Rules.SHIFT_QUAY)
	check(play_named(last_differs, "entry_mark", 0, 0), "the earlier shared stamp")
	check(play_named(last_differs, "entry_mark", 0, 1), "the later shared stamp")
	check(play_named(last_differs, "visa_dot", 2, 2), "the last cell has a different number")
	check(last_differs.last_progress_gained == 9, "the last cell scores once when its number is new (%d)" % last_differs.last_progress_gained)

	var gapped = Rules.scripted_encounter(84, 3, ["entry_mark", "visa_dot", "entry_mark"], 3, Rules.SHIFT_QUAY)
	check(play_named(gapped, "entry_mark", 0, 0), "an entry mark grants 2")
	check(play_named(gapped, "visa_dot", 0, 1), "a visa dot grants 3 between the pair")
	check(play_named(gapped, "entry_mark", 0, 2), "a later entry mark shares 2 across the gap")
	check(gapped.last_progress_gained == 9, "a gap does not block the shared number (%d)" % gapped.last_progress_gained)

	var pressed = Rules.scripted_encounter(84, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_QUAY)
	check(play_named(pressed, "entry_mark", 2, 2), "the lower stamp is pressed first")
	check(play_named(pressed, "entry_mark", 0, 0), "the higher stamp is pressed last")
	check(pressed.last_progress_gained == 6, "the later queue cell scores twice, not the later press (%d)" % pressed.last_progress_gained)

	var above = Rules.scripted_encounter(84, 3, ["entry_mark", "surcharge"], 2, Rules.SHIFT_QUAY)
	check(play_named(above, "entry_mark", 0, 0), "the cell above a surcharge grants 2")
	check(play_named(above, "surcharge", 1, 0), "the surcharge grants 5")
	check(above.last_progress_gained == 7, "the filled cell changes the surcharge number (%d)" % above.last_progress_gained)
	check(above.last_patience_loss == 1, "2 and 5 do not share a number")

	var flat = Rules.scripted_encounter(84, 3, ["surcharge", "surcharge"], 2, Rules.SHIFT_QUAY)
	check(play_named(flat, "surcharge", 0, 0), "a surcharge with nothing above grants 2")
	check(play_named(flat, "surcharge", 0, 2), "another open surcharge grants 2")
	check(flat.last_progress_gained == 6, "two surcharges that both grant 2 double the later one (%d)" % flat.last_progress_gained)

	var muted = Rules.scripted_encounter(84, 3, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_QUAY)
	check(play_named(muted, "entry_mark", 0, 0), "first entry mark under an exemption")
	check(play_named(muted, "entry_mark", 0, 1), "second entry mark under an exemption")
	check(play_named(muted, "exemption", 2, 0), "exemption is placed on Ivo's bottom row")
	check(muted.last_progress_gained == 5, "exemption on the bottom row cancels the doubling (%d)" % muted.last_progress_gained)

	var kept = Rules.scripted_encounter(84, 3, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_QUAY)
	check(play_named(kept, "exemption", 1, 0), "exemption sits off Ivo's bottom row")
	check(play_named(kept, "entry_mark", 0, 0), "first entry mark beside that exemption")
	check(play_named(kept, "entry_mark", 0, 2), "second entry mark beside that exemption")
	check(kept.last_progress_gained == 7, "an exemption off the bottom row leaves the later stamp doubled (%d)" % kept.last_progress_gained)

	var echo_pair = Rules.scripted_encounter(84, 3, ["echo", "exemption"], 2, Rules.SHIFT_QUAY)
	check(play_named(echo_pair, "echo", 0, 0), "echo grants 1")
	check(play_named(echo_pair, "exemption", 1, 1), "a later exemption also grants 1")
	check(echo_pair.last_progress_gained == 3, "the later shared 1 scores twice when the exemption is off the bottom row (%d)" % echo_pair.last_progress_gained)

	var echo_muted = Rules.scripted_encounter(84, 3, ["echo", "exemption"], 2, Rules.SHIFT_QUAY)
	check(play_named(echo_muted, "echo", 0, 0), "echo grants 1 above a cancelling exemption")
	check(play_named(echo_muted, "exemption", 2, 1), "exemption on the bottom row shares that 1")
	check(echo_muted.last_progress_gained == 2, "the bottom-row exemption cancels its own doubling (%d)" % echo_muted.last_progress_gained)

	var doubled_echo = Rules.scripted_encounter(84, 3, ["entry_mark", "echo", "entry_mark"], 3, Rules.SHIFT_QUAY)
	check(play_named(doubled_echo, "entry_mark", 0, 0), "an entry mark grants 2")
	check(play_named(doubled_echo, "echo", 0, 1), "echo grants 1 and retriggers below")
	check(play_named(doubled_echo, "entry_mark", 1, 1), "the stamp under the echo shares 2")
	check(doubled_echo.last_chain_count == 1, "the echo still retriggers the later shared stamp")
	check(doubled_echo.last_progress_gained == 11, "a retrigger of the later shared stamp scores twice again (%d)" % doubled_echo.last_progress_gained)

	var plain_reply = Rules.scripted_encounter(84, 3, ["exemption", "reply"], 2, Rules.SHIFT_QUAY)
	check(play_named(plain_reply, "exemption", 0, 0), "exemption is the earlier shared 1")
	check(play_named(plain_reply, "reply", 1, 0), "reply is the later shared 1")
	check(plain_reply.last_chain_count == 1, "the reply retriggers the earlier stamp")
	check(plain_reply.last_progress_gained == 4, "the later reply scores twice and the earlier retrigger does not (%d)" % plain_reply.last_progress_gained)

	var held_pair = Rules.scripted_encounter(84, 3, ["entry_mark", "entry_mark", "hold"], 3, Rules.SHIFT_QUAY)
	check(play_named(held_pair, "entry_mark", 0, 0), "first shared entry mark")
	check(play_named(held_pair, "entry_mark", 0, 2), "second shared entry mark")
	check(play_named(held_pair, "hold", 1, 1), "hold in Ivo's column")
	check(held_pair.last_progress_gained == 7, "the held pair still scores")
	check(held_pair.last_patience_loss == 0 and held_pair.patience == 5, "hold still delays Ivo")

	var missed_hold = Rules.scripted_encounter(84, 3, ["entry_mark", "entry_mark", "hold"], 3, Rules.SHIFT_QUAY)
	check(play_named(missed_hold, "entry_mark", 0, 0), "first shared entry mark outside the hold")
	check(play_named(missed_hold, "entry_mark", 0, 2), "second shared entry mark outside the hold")
	check(play_named(missed_hold, "hold", 1, 0), "hold outside Ivo's column")
	check(missed_hold.last_progress_gained == 7, "the pair still doubles outside the lane")
	check(missed_hold.last_patience_loss == 1, "hold in another column does not delay Ivo, and the pair does not toll")

	var ida = Rules.scripted_encounter(64, 3, ["duty"], 1, Rules.SHIFT_QUIRE)
	check(play_named(ida, "duty", 2, 2), "Ida receives a lone bottom-row duty")
	check(ida.last_progress_gained == 8, "the quire watch still doubles the first stamp (%d)" % ida.last_progress_gained)
	var pell = Rules.scripted_encounter(71, 0, ["duty"], 1, Rules.SHIFT_SALT)
	check(play_named(pell, "duty", 2, 2), "Pell receives a bottom-row duty")
	check(pell.last_progress_gained == 4, "the salt watch still counts a bottom-row duty (%d)" % pell.last_progress_gained)
	var june = Rules.scripted_encounter(72, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_SALT)
	check(play_named(june, "entry_mark", 0, 0), "June's first entry mark")
	check(play_named(june, "entry_mark", 0, 1), "June's second entry mark")
	check(june.last_progress_gained == 4, "the salt watch does not double a shared number (%d)" % june.last_progress_gained)
	check(june.last_patience_loss == 2, "the salt watch still tolls a shared number")
	var june_center = Rules.scripted_encounter(72, 1, ["entry_mark"], 1, Rules.SHIFT_SALT)
	check(play_named(june_center, "entry_mark", 1, 1), "June receives one center stamp")
	check(june_center.last_patience_loss == 1, "a filled center does not toll June")
	var cal = Rules.scripted_encounter(73, 2, ["entry_mark"], 1, Rules.SHIFT_SALT)
	check(play_named(cal, "entry_mark", 1, 0), "Cal receives a non-corner edge")
	check(cal.last_progress_gained == 5, "the salt watch still yields +3 on a non-corner edge (%d)" % cal.last_progress_gained)
	var ned = Rules.scripted_encounter(74, 3, ["duty"], 1, Rules.SHIFT_SALT)
	check(play_named(ned, "duty", 2, 2), "Ned receives a lone bottom-row duty")
	check(ned.last_progress_gained == 8, "the salt watch still doubles the last stamp (%d)" % ned.last_progress_gained)
	var tansy = Rules.scripted_encounter(23, 2, ["entry_mark"], 1, Rules.SHIFT_CLOSING)
	check(play_named(tansy, "entry_mark", 0, 0), "Tansy receives a stamp outside the center")
	check(tansy.last_patience_loss == 2, "the closing bell still tolls an empty center")
	var ada = Rules.scripted_encounter(5, 0, ["entry_mark"], 1)
	check(play_named(ada, "entry_mark", 0, 0), "Ada receives a corner entry mark")
	check(ada.last_progress_gained == 0, "Act 1 still refuses the top row (%d)" % ada.last_progress_gained)


func test_quay_bell_opens() -> void:
	check(Rules.QUAY_BELL.size() == 4, "the quay bell has four travelers")
	check(Rules.TRAVELERS.size() == 4 and String(Rules.TRAVELERS[0]["name"]) == "Ada Quill", "Act 1 still begins with Ada Quill")
	check(String(Rules.TRAVELERS[3]["name"]) == "Doss Kite", "Act 1 still ends with Doss Kite")
	check(Rules.LATE_SHIFT.size() == 4 and String(Rules.LATE_SHIFT[0]["name"]) == "Nell Parr", "the late shift still begins with Nell Parr")
	check(String(Rules.LATE_SHIFT[3]["name"]) == "Rue Calder", "the late shift still ends with Rue Calder")
	check(Rules.CLOSING_BELL.size() == 4 and String(Rules.CLOSING_BELL[0]["name"]) == "Moss Quen", "the closing bell still begins with Moss Quen")
	check(String(Rules.CLOSING_BELL[3]["name"]) == "Lumen Peck", "the closing bell still ends with Lumen Peck")
	check(Rules.ASH_WATCH.size() == 4 and String(Rules.ASH_WATCH[0]["name"]) == "Orla Fen", "the ash watch still begins with Orla Fen")
	check(String(Rules.ASH_WATCH[3]["name"]) == "Nim Harth", "the ash watch still ends with Nim Harth")
	check(Rules.GUTTER_LAMP.size() == 4 and String(Rules.GUTTER_LAMP[0]["name"]) == "Ivo Dane", "the gutter lamp still begins with Ivo Dane")
	check(String(Rules.GUTTER_LAMP[3]["name"]) == "Kit Yarrow", "the gutter lamp still ends with Kit Yarrow")
	check(Rules.VELLUM_BELL.size() == 4 and String(Rules.VELLUM_BELL[0]["name"]) == "Edda Voss", "the vellum bell still begins with Edda Voss")
	check(String(Rules.VELLUM_BELL[3]["name"]) == "Lark Pym", "the vellum bell still ends with Lark Pym")
	check(Rules.QUIRE_WATCH.size() == 4 and String(Rules.QUIRE_WATCH[0]["name"]) == "Tess Quern", "the quire watch still begins with Tess Quern")
	check(String(Rules.QUIRE_WATCH[3]["name"]) == "Ida Cress", "the quire watch still ends with Ida Cress")
	check(Rules.SALT_WATCH.size() == 4 and String(Rules.SALT_WATCH[0]["name"]) == "Pell Voss", "the salt watch still begins with Pell Voss")
	check(String(Rules.SALT_WATCH[3]["name"]) == "Ned Quill", "the salt watch still ends with Ned Quill")
	var quay = Rules.new_run(77, Rules.SHIFT_QUAY)
	check(quay.shift == Rules.SHIFT_QUAY, "the quay bell is a separate night")
	check(String(Rules.traveler(quay)["name"]) == "Mara Quill", "the quay bell begins with Mara Quill")
	check(quay.hand.size() == Rules.HAND_SIZE, "the quay bell draws 5")
	check(quay.ink == Rules.BASE_INK, "the quay bell starts at 3 ink")
	check(quay.library.size() == Rules.STARTING_DECK.size(), "the quay bell deals the starting deck")
	check(quay.relic_id == "", "an earlier night's relic does not carry")
	check(quay.phase == "play", "the quay bell opens in play")
	var dealt: Array = []
	for iid in quay.hand:
		dealt.append(Rules.card_id_of(quay, int(iid)))
	var before = quay.library.size()
	quay.progress = 4
	quay.patience = 1
	Rules.restart_encounter(quay)
	check(quay.shift == Rules.SHIFT_QUAY and quay.traveler_index == 0, "restart encounter stays on the quay bell")
	check(quay.progress == 0 and quay.patience == int(Rules.QUAY_BELL[0]["patience"]), "restart encounter resets Mara")
	check(quay.library.size() == before and quay.hand.size() == 5 and quay.phase == "play", "restart keeps the quay-bell deck and deals a hand")
	var redealt: Array = []
	for iid in quay.hand:
		redealt.append(Rules.card_id_of(quay, int(iid)))
	check(redealt == dealt, "restart deals Mara the same hand")

	var packed = load("res://game/main.tscn")
	var desk = packed.instantiate()
	root.add_child(desk)
	if desk.state == null:
		desk._ready()
	check(desk.state.shift == Rules.SHIFT_FIRST, "the desk still opens on Act 1")
	check(desk.quay_button.text == "Quay bell", "the desk offers the quay bell")
	check(desk.salt_button.text == "Salt watch", "the desk still offers the salt watch")
	check(desk.quire_button.text == "Quire watch", "the desk still offers the quire watch")
	check(desk.shift_button.text == "Late shift", "the desk still offers the late shift")
	check(desk.closing_button.text == "Closing bell", "the desk still offers the closing bell")
	check(desk.ash_button.text == "Ash watch", "the desk still offers the ash watch")
	check(desk.gutter_button.text == "Gutter lamp", "the desk still offers the gutter lamp")
	check(desk.vellum_button.text == "Vellum bell", "the desk still offers the vellum bell")
	desk.quay_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_QUAY, "the desk can open the quay bell")
	check(String(Rules.traveler(desk.state)["name"]) == "Mara Quill", "the open desk shows Mara")
	check(String(desk.desk_label.text).begins_with("Quay bell"), "the desk title follows the quay bell")
	check(desk.meta_label.text.contains("First Bar"), "the desk shows Mara's form")
	check(desk.quay_button.text == "First bell", "the quay bell can return to the first bell")
	check(desk.shift_button.text == "Late shift", "the late shift stays available from the quay bell")
	check(desk.closing_button.text == "Closing bell", "the closing bell stays available from the quay bell")
	check(desk.ash_button.text == "Ash watch", "the ash watch stays available from the quay bell")
	check(desk.gutter_button.text == "Gutter lamp", "the gutter lamp stays available from the quay bell")
	check(desk.vellum_button.text == "Vellum bell", "the vellum bell stays available from the quay bell")
	check(desk.quire_button.text == "Quire watch", "the quire watch stays available from the quay bell")
	check(desk.salt_button.text == "Salt watch", "the salt watch stays available from the quay bell")
	desk._restart_act()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_QUAY and String(Rules.traveler(desk.state)["name"]) == "Mara Quill", "restart act replays the quay bell")
	desk.quay_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the quay bell returns to Ada")
	desk._toggle_shift()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_LATE and String(Rules.traveler(desk.state)["name"]) == "Nell Parr", "the late shift still opens from the first bell")
	check(desk.quay_button.text == "Quay bell", "the late shift offers the quay bell")
	desk._begin_quay_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_QUAY and String(Rules.traveler(desk.state)["name"]) == "Mara Quill", "the late shift can open the quay bell")
	desk._toggle_closing()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_CLOSING and String(Rules.traveler(desk.state)["name"]) == "Moss Quen", "the quay bell can open the closing bell")
	check(desk.quay_button.text == "Quay bell", "the closing bell offers the quay bell")
	desk.quay_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_QUAY and String(Rules.traveler(desk.state)["name"]) == "Mara Quill", "the closing bell can open the quay bell")
	desk._toggle_ash()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_ASH and String(Rules.traveler(desk.state)["name"]) == "Orla Fen", "the quay bell can open the ash watch")
	check(desk.quay_button.text == "Quay bell", "the ash watch offers the quay bell")
	desk._begin_quay_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_QUAY and String(Rules.traveler(desk.state)["name"]) == "Mara Quill", "the ash watch can open the quay bell")
	desk._toggle_gutter()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_GUTTER and String(Rules.traveler(desk.state)["name"]) == "Ivo Dane", "the quay bell can open the gutter lamp")
	check(desk.quay_button.text == "Quay bell", "the gutter lamp offers the quay bell")
	desk._begin_quay_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_QUAY and String(Rules.traveler(desk.state)["name"]) == "Mara Quill", "the gutter lamp can open the quay bell")
	desk._toggle_vellum()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_VELLUM and String(Rules.traveler(desk.state)["name"]) == "Edda Voss", "the quay bell can open the vellum bell")
	check(desk.quay_button.text == "Quay bell", "the vellum bell offers the quay bell")
	desk._begin_quay_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_QUAY and String(Rules.traveler(desk.state)["name"]) == "Mara Quill", "the vellum bell can open the quay bell")
	desk._toggle_quire()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_QUIRE and String(Rules.traveler(desk.state)["name"]) == "Tess Quern", "the quay bell can open the quire watch")
	check(desk.quay_button.text == "Quay bell", "the quire watch offers the quay bell")
	desk._begin_quay_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_QUAY and String(Rules.traveler(desk.state)["name"]) == "Mara Quill", "the quire watch can open the quay bell")
	desk._toggle_salt()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_SALT and String(Rules.traveler(desk.state)["name"]) == "Pell Voss", "the quay bell can open the salt watch")
	check(desk.quay_button.text == "Quay bell", "the salt watch offers the quay bell")
	desk._begin_quay_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_QUAY and String(Rules.traveler(desk.state)["name"]) == "Mara Quill", "the salt watch can open the quay bell")
	desk._begin_first_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "first bell still returns to Ada")
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_quay = _button_named(desk, "Open the quay bell")
	check(victory_quay != null, "Act 1's victory desk offers the quay bell")
	if victory_quay != null:
		victory_quay.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_QUAY and String(Rules.traveler(desk.state)["name"]) == "Mara Quill", "the victory desk opens the quay bell")
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_first = _button_named(desk, "Open the first bell")
	check(victory_first != null, "the quay bell victory desk offers the first bell")
	if victory_first != null:
		victory_first.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the quay bell victory desk opens the first bell")
	desk._begin_salt_watch()
	desk._refresh_ui()
	desk.state.phase = "victory"
	desk._refresh_ui()
	var salt_quay = _button_named(desk, "Open the quay bell")
	check(salt_quay != null, "the salt watch victory desk offers the quay bell")
	if salt_quay != null:
		salt_quay.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_QUAY and String(Rules.traveler(desk.state)["name"]) == "Mara Quill", "the salt watch victory desk opens the quay bell")
	root.remove_child(desk)
	desk.free()


func test_policy_clears_quay_bell() -> void:
	var started = Time.get_ticks_msec()
	var state = Rules.new_run(12345, Rules.SHIFT_QUAY)
	var steps = 0
	var seen = 0
	while state.phase != "victory":
		steps += 1
		if steps > 500 or state.phase == "defeat":
			check(false, "policy lost or stalled on the quay bell, seed 12345: " + Rules.debug_summary(state))
			return
		var action = Policy.choose(state)
		if not Rules.apply_action(state, action):
			check(false, "quay-bell policy action was rejected: %s / %s" % [str(action), Rules.debug_summary(state)])
			return
		if state.encounters_cleared != seen:
			seen = state.encounters_cleared
			print("cleared quay encounter %d after %d actions" % [seen, steps])
	var elapsed = Time.get_ticks_msec() - started
	check(state.encounters_cleared == 4, "policy cleared all 4 quay-bell encounters on seed 12345")
	check(state.phase == "victory", "quay bell ends in victory")
	check(state.shift == Rules.SHIFT_QUAY, "the clear stayed on the quay bell")
	print("quay bell finished in %d actions, %d ms" % [steps, elapsed])


func test_folio_bell_rules() -> void:
	var ness = Rules.scripted_encounter(91, 0, ["duty", "entry_mark"], 3, Rules.SHIFT_FOLIO)
	check(String(Rules.traveler(ness)["name"]) == "Ness Hart", "the folio bell's first form is Ness Hart")
	check(String(Rules.traveler(ness)["form_name"]) == "Last Bar", "Ness brings the Last Bar")
	check(String(Rules.traveler(ness)["rule_text"]) == "The last stamp in the queue scores 0 unless an Exemption is on the bottom row.", "Ness's form states the last-stamp rule")
	check(Rules.preview_progress(ness, "duty", 2, 2) == 0, "preview zeros a lone bottom-row duty for Ness")
	check(Rules.preview_progress(ness, "duty", 0, 0) == 0, "preview zeros a lone top-row duty for Ness")
	check(Rules.preview_progress(ness, "entry_mark", 1, 1) == 0, "preview zeros a lone center stamp for Ness")

	var wrong = Rules.scripted_encounter(91, 0, ["duty"], 1, Rules.SHIFT_FOLIO)
	check(play_named(wrong, "duty", 2, 2), "Ness receives a lone bottom-row duty, the wrong stamp")
	check(wrong.last_progress_gained == 0, "a lone stamp is last, so Ness scores 0 (%d)" % wrong.last_progress_gained)
	check(wrong.last_patience_loss == 1, "a refused last stamp still spends the turn")

	var right = Rules.scripted_encounter(91, 0, ["duty", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(play_named(right, "duty", 2, 0), "an earlier bottom-row duty")
	check(play_named(right, "entry_mark", 2, 2), "Ness receives a later stamp, so the duty is not last")
	check(right.last_progress_gained == 4, "the earlier duty scores and the last stamp scores 0 (%d)" % right.last_progress_gained)

	var top_last = Rules.scripted_encounter(91, 0, ["entry_mark", "duty"], 2, Rules.SHIFT_FOLIO)
	check(play_named(top_last, "entry_mark", 0, 0), "an earlier top-row stamp")
	check(play_named(top_last, "duty", 0, 2), "a later top-row duty is the queue tail")
	check(top_last.last_progress_gained == 2, "a top-row stamp scores 0 when it is last (%d)" % top_last.last_progress_gained)

	var pressed_first = Rules.scripted_encounter(91, 0, ["duty", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(play_named(pressed_first, "duty", 2, 2), "the bottom duty is pressed first")
	check(pressed_first.phase == "play", "the first press leaves Ness's turn open")
	check(play_named(pressed_first, "entry_mark", 0, 0), "the top stamp is pressed last")
	check(pressed_first.last_progress_gained == 2, "queue order, not press order, chooses Ness's last stamp (%d)" % pressed_first.last_progress_gained)

	var spared = Rules.scripted_encounter(91, 0, ["exemption", "duty"], 2, Rules.SHIFT_FOLIO)
	check(play_named(spared, "exemption", 2, 0), "exemption is placed on Ness's bottom row")
	check(play_named(spared, "duty", 2, 2), "the last duty follows that exemption")
	check(spared.last_progress_gained == 5, "exemption on the bottom row lets the last stamp count (%d)" % spared.last_progress_gained)

	var tail_exempt = Rules.scripted_encounter(91, 0, ["duty", "exemption"], 2, Rules.SHIFT_FOLIO)
	check(play_named(tail_exempt, "duty", 2, 0), "an earlier bottom-row duty")
	check(play_named(tail_exempt, "exemption", 2, 2), "exemption itself is the last stamp")
	check(tail_exempt.last_progress_gained == 5, "an exemption on the bottom row counts, and the earlier duty counts (%d)" % tail_exempt.last_progress_gained)

	var still_bar = Rules.scripted_encounter(91, 0, ["exemption", "duty"], 2, Rules.SHIFT_FOLIO)
	check(play_named(still_bar, "exemption", 1, 1), "exemption sits off Ness's bottom row")
	check(play_named(still_bar, "duty", 2, 2), "the queue tail under an off-row exemption")
	check(still_bar.last_progress_gained == 1, "an exemption off the bottom row leaves the last stamp at 0 (%d)" % still_bar.last_progress_gained)

	var refused_echo = Rules.scripted_encounter(91, 0, ["echo", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(play_named(refused_echo, "echo", 1, 2), "echo sits above the last cell")
	check(play_named(refused_echo, "entry_mark", 2, 2), "entry mark is the last stamp")
	check(refused_echo.last_chain_count == 1, "the echo still retriggers the last stamp")
	check(refused_echo.last_progress_gained == 1, "the last stamp scores 0 and its retrigger scores 0 (%d)" % refused_echo.last_progress_gained)

	var kept_reply = Rules.scripted_encounter(91, 0, ["entry_mark", "reply"], 2, Rules.SHIFT_FOLIO)
	check(play_named(kept_reply, "entry_mark", 0, 0), "entry mark is earlier than the reply")
	check(play_named(kept_reply, "reply", 1, 0), "reply is the last stamp and retriggers above")
	check(kept_reply.last_chain_count == 1, "the reply still retriggers the earlier stamp")
	check(kept_reply.last_progress_gained == 4, "a retrigger of an earlier stamp scores its own number (%d)" % kept_reply.last_progress_gained)

	var held = Rules.scripted_encounter(91, 0, ["hold"], 1, Rules.SHIFT_FOLIO)
	check(play_named(held, "hold", 0, 0), "hold is the last stamp in Ness's column")
	check(held.last_progress_gained == 0, "the refused hold grants no progress")
	check(held.last_patience_loss == 0 and held.patience == 5, "a refused hold still delays Ness")

	var missed = Rules.scripted_encounter(91, 0, ["hold"], 1, Rules.SHIFT_FOLIO)
	check(play_named(missed, "hold", 0, 1), "a refused hold outside Ness's column")
	check(missed.last_progress_gained == 0, "the hold is still the last stamp")
	check(missed.last_patience_loss == 1, "hold in another column does not delay Ness")

	var wynn_edge = Rules.scripted_encounter(92, 1, ["entry_mark"], 1, Rules.SHIFT_FOLIO)
	check(String(Rules.traveler(wynn_edge)["name"]) == "Wynn Cress", "the folio bell's second form is Wynn Cress")
	check(String(Rules.traveler(wynn_edge)["form_name"]) == "Center Slip", "Wynn brings the Center Slip")
	check(String(Rules.traveler(wynn_edge)["rule_text"]) == "The center stamp scores twice. Other cells score their own number.", "Wynn's form states the center slip")
	check(Rules.preview_progress(wynn_edge, "entry_mark", 1, 1) == 4, "preview doubles a center entry mark")
	check(Rules.preview_progress(wynn_edge, "visa_dot", 1, 1) == 6, "preview doubles a center visa dot")
	check(Rules.preview_progress(wynn_edge, "duty", 1, 1) == 4, "preview doubles a center duty")
	check(Rules.preview_progress(wynn_edge, "duty", 2, 1) == 4, "preview leaves a bottom-row duty at 4")
	check(Rules.preview_progress(wynn_edge, "entry_mark", 0, 0) == 2, "preview leaves a corner at 2")
	check(Rules.preview_progress(wynn_edge, "entry_mark", 1, 0) == 2, "preview leaves the rest of the middle row at 2")
	check(play_named(wynn_edge, "entry_mark", 1, 0), "Wynn receives a non-center stamp, the wrong stamp")
	check(wynn_edge.last_progress_gained == 2, "a stamp outside the center scores its own number (%d)" % wynn_edge.last_progress_gained)

	var wynn_center = Rules.scripted_encounter(92, 1, ["entry_mark"], 1, Rules.SHIFT_FOLIO)
	check(play_named(wynn_center, "entry_mark", 1, 1), "Wynn receives a center entry mark, the correct stamp")
	check(wynn_center.last_progress_gained == 4, "the center stamp scores twice (%d)" % wynn_center.last_progress_gained)

	var wynn_bottom = Rules.scripted_encounter(92, 1, ["duty"], 1, Rules.SHIFT_FOLIO)
	check(play_named(wynn_bottom, "duty", 2, 1), "Wynn receives a bottom-row duty")
	check(wynn_bottom.last_progress_gained == 4, "a bottom-row duty scores its own 4 (%d)" % wynn_bottom.last_progress_gained)

	var wynn_duty = Rules.scripted_encounter(92, 1, ["duty"], 1, Rules.SHIFT_FOLIO)
	check(play_named(wynn_duty, "duty", 1, 1), "Wynn receives a center duty")
	check(wynn_duty.last_progress_gained == 4, "a center duty of 2 scores 4 (%d)" % wynn_duty.last_progress_gained)

	var wynn_visa = Rules.scripted_encounter(92, 1, ["visa_dot"], 1, Rules.SHIFT_FOLIO)
	check(play_named(wynn_visa, "visa_dot", 1, 1), "Wynn receives a center visa dot")
	check(wynn_visa.last_progress_gained == 6, "a center visa dot of 3 scores 6 (%d)" % wynn_visa.last_progress_gained)

	var wynn_pair = Rules.scripted_encounter(92, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(play_named(wynn_pair, "entry_mark", 0, 0), "a corner stamp")
	check(play_named(wynn_pair, "entry_mark", 2, 2), "another corner stamp")
	check(wynn_pair.last_progress_gained == 4, "two stamps outside the center are not doubled (%d)" % wynn_pair.last_progress_gained)

	var wynn_mixed = Rules.scripted_encounter(92, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(play_named(wynn_mixed, "entry_mark", 1, 1), "the center stamp")
	check(play_named(wynn_mixed, "entry_mark", 0, 0), "a corner beside the center")
	check(wynn_mixed.last_progress_gained == 6, "only the center stamp scores twice (%d)" % wynn_mixed.last_progress_gained)

	var wynn_muted = Rules.scripted_encounter(92, 1, ["exemption", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(play_named(wynn_muted, "exemption", 1, 0), "exemption is placed on Wynn's middle row, off the center")
	check(play_named(wynn_muted, "entry_mark", 1, 1), "the center stamp follows that exemption")
	check(wynn_muted.last_progress_gained == 3, "exemption on the middle row cancels the doubling (%d)" % wynn_muted.last_progress_gained)

	var wynn_center_exempt = Rules.scripted_encounter(92, 1, ["exemption"], 1, Rules.SHIFT_FOLIO)
	check(play_named(wynn_center_exempt, "exemption", 1, 1), "exemption is placed in the center")
	check(wynn_center_exempt.last_progress_gained == 1, "a center exemption scores 1, not 2")

	var wynn_kept = Rules.scripted_encounter(92, 1, ["exemption", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(play_named(wynn_kept, "exemption", 0, 0), "exemption sits off Wynn's middle row")
	check(play_named(wynn_kept, "entry_mark", 1, 1), "the center stamp beside that exemption")
	check(wynn_kept.last_progress_gained == 5, "an exemption off the middle row leaves the center doubled (%d)" % wynn_kept.last_progress_gained)

	var wynn_reply = Rules.scripted_encounter(92, 1, ["entry_mark", "reply"], 2, Rules.SHIFT_FOLIO)
	check(play_named(wynn_reply, "entry_mark", 1, 1), "a center entry mark")
	check(play_named(wynn_reply, "reply", 2, 1), "reply sits under the center")
	check(wynn_reply.last_chain_count == 1, "the reply still retriggers the center")
	check(wynn_reply.last_progress_gained == 9, "a retrigger of the center scores twice again (%d)" % wynn_reply.last_progress_gained)

	var wynn_plain = Rules.scripted_encounter(92, 1, ["entry_mark", "reply"], 2, Rules.SHIFT_FOLIO)
	check(play_named(wynn_plain, "entry_mark", 0, 0), "a corner entry mark")
	check(play_named(wynn_plain, "reply", 1, 0), "reply retriggers that corner")
	check(wynn_plain.last_chain_count == 1, "the reply still retriggers")
	check(wynn_plain.last_progress_gained == 5, "a retrigger outside the center is not doubled (%d)" % wynn_plain.last_progress_gained)

	var wynn_echo = Rules.scripted_encounter(92, 1, ["echo", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(play_named(wynn_echo, "echo", 0, 1), "echo sits above the center")
	check(play_named(wynn_echo, "entry_mark", 1, 1), "the center stamp under the echo")
	check(wynn_echo.last_chain_count == 1, "the echo retriggers the center")
	check(wynn_echo.last_progress_gained == 9, "the center scores twice on the retrigger and again in the queue (%d)" % wynn_echo.last_progress_gained)

	var wynn_held = Rules.scripted_encounter(92, 1, ["entry_mark", "hold"], 2, Rules.SHIFT_FOLIO)
	check(play_named(wynn_held, "entry_mark", 1, 1), "the center is filled")
	check(play_named(wynn_held, "hold", 2, 2), "hold in Wynn's column")
	check(wynn_held.last_progress_gained == 5, "the held center still scores twice")
	check(wynn_held.last_patience_loss == 0 and wynn_held.patience == 5, "hold delays Wynn")

	var wynn_center_hold = Rules.scripted_encounter(92, 1, ["hold"], 1, Rules.SHIFT_FOLIO)
	check(play_named(wynn_center_hold, "hold", 1, 1), "hold is placed in the center, outside Wynn's column")
	check(wynn_center_hold.last_progress_gained == 2, "a center hold scores twice")
	check(wynn_center_hold.last_patience_loss == 1, "a center hold outside the lane does not delay Wynn")

	var tam = Rules.scripted_encounter(93, 2, ["duty", "entry_mark"], 3, Rules.SHIFT_FOLIO)
	check(String(Rules.traveler(tam)["name"]) == "Tam Quern", "the folio bell's third form is Tam Quern")
	check(String(Rules.traveler(tam)["form_name"]) == "Column Bar", "Tam brings the Column Bar")
	check(String(Rules.traveler(tam)["rule_text"]) == "A stamp in column 1 scores 0 when that column holds another stamp. A lone stamp in column 1 counts.", "Tam's form states the stacked-column rule")
	check(Rules.preview_progress(tam, "duty", 2, 0) == 4, "preview counts a lone column-1 duty")
	check(Rules.preview_progress(tam, "duty", 2, 1) == 4, "preview counts a column-2 duty")
	check(play_named(tam, "entry_mark", 0, 0), "the first column-1 stamp leaves the turn open")
	check(tam.phase == "play", "Tam's first stamp does not end the turn")
	check(Rules.preview_progress(tam, "duty", 2, 0) == 0, "preview zeros a second stamp in column 1")
	check(Rules.preview_progress(tam, "duty", 2, 1) == 4, "preview still counts column 2 beside a lone column 1")

	var stacked = Rules.scripted_encounter(93, 2, ["entry_mark", "duty"], 2, Rules.SHIFT_FOLIO)
	check(play_named(stacked, "entry_mark", 0, 0), "a stamp in column 1")
	check(play_named(stacked, "duty", 2, 0), "Tam receives a second stamp in column 1, the wrong stamp")
	check(stacked.last_progress_gained == 0, "a stacked column 1 scores 0 (%d)" % stacked.last_progress_gained)

	var lone = Rules.scripted_encounter(93, 2, ["duty"], 1, Rules.SHIFT_FOLIO)
	check(play_named(lone, "duty", 2, 0), "Tam receives a lone column-1 duty, the correct stamp")
	check(lone.last_progress_gained == 4, "a lone stamp in column 1 scores its own number (%d)" % lone.last_progress_gained)

	var beside = Rules.scripted_encounter(93, 2, ["entry_mark", "duty"], 2, Rules.SHIFT_FOLIO)
	check(play_named(beside, "entry_mark", 0, 0), "one stamp in column 1")
	check(play_named(beside, "duty", 2, 1), "a duty in column 2")
	check(beside.last_progress_gained == 6, "column 2 scores normally beside a lone column 1 (%d)" % beside.last_progress_gained)

	var other = Rules.scripted_encounter(93, 2, ["entry_mark", "entry_mark", "duty"], 3, Rules.SHIFT_FOLIO)
	check(play_named(other, "entry_mark", 0, 0), "first stacked stamp")
	check(play_named(other, "entry_mark", 1, 0), "second stacked stamp")
	check(play_named(other, "duty", 2, 2), "a duty in column 3")
	check(other.last_progress_gained == 4, "column 3 scores normally while column 1 is stacked (%d)" % other.last_progress_gained)

	var touching = Rules.scripted_encounter(93, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(play_named(touching, "entry_mark", 0, 0), "a column-1 stamp")
	check(play_named(touching, "entry_mark", 0, 1), "a stamp that shares its side")
	check(touching.last_progress_gained == 4, "a neighbor does not bar a lone column 1 (%d)" % touching.last_progress_gained)

	var freed = Rules.scripted_encounter(93, 2, ["exemption", "entry_mark", "duty"], 3, Rules.SHIFT_FOLIO)
	check(play_named(freed, "exemption", 0, 2), "exemption is placed on Tam's top row")
	check(play_named(freed, "entry_mark", 0, 0), "a column-1 stamp under that exemption")
	check(play_named(freed, "duty", 2, 0), "a second column-1 stamp under that exemption")
	check(freed.last_progress_gained == 7, "exemption on the top row lets a stacked column 1 count (%d)" % freed.last_progress_gained)

	var column_exempt = Rules.scripted_encounter(93, 2, ["exemption", "duty"], 2, Rules.SHIFT_FOLIO)
	check(play_named(column_exempt, "exemption", 0, 0), "exemption is the top cell of column 1")
	check(play_named(column_exempt, "duty", 2, 0), "a second column-1 stamp")
	check(column_exempt.last_progress_gained == 5, "an exemption in column 1 on the top row lets the column count (%d)" % column_exempt.last_progress_gained)

	var still_stacked = Rules.scripted_encounter(93, 2, ["exemption", "entry_mark", "duty"], 3, Rules.SHIFT_FOLIO)
	check(play_named(still_stacked, "exemption", 1, 1), "exemption sits off Tam's top row")
	check(play_named(still_stacked, "entry_mark", 0, 0), "a column-1 stamp")
	check(play_named(still_stacked, "duty", 2, 0), "a second column-1 stamp")
	check(still_stacked.last_progress_gained == 1, "an exemption off the top row leaves the stacked column at 0 (%d)" % still_stacked.last_progress_gained)

	var stacked_echo = Rules.scripted_encounter(93, 2, ["echo", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(play_named(stacked_echo, "echo", 0, 0), "echo in column 1")
	check(play_named(stacked_echo, "entry_mark", 1, 0), "a stamp under the echo, also in column 1")
	check(stacked_echo.last_chain_count == 1, "the stacked echo still retriggers")
	check(stacked_echo.last_progress_gained == 0, "a retrigger of a stacked column-1 stamp scores 0 (%d)" % stacked_echo.last_progress_gained)

	var tam_held = Rules.scripted_encounter(93, 2, ["hold", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(play_named(tam_held, "hold", 0, 0), "hold in Tam's column")
	check(play_named(tam_held, "entry_mark", 2, 0), "a second stamp in that column")
	check(tam_held.last_progress_gained == 0, "the stacked hold grants no progress")
	check(tam_held.last_patience_loss == 0 and tam_held.patience == 5, "a stacked hold still delays Tam")

	var tam_missed = Rules.scripted_encounter(93, 2, ["hold", "entry_mark", "entry_mark"], 3, Rules.SHIFT_FOLIO)
	check(play_named(tam_missed, "hold", 0, 1), "hold outside Tam's column")
	check(play_named(tam_missed, "entry_mark", 0, 0), "first stacked stamp")
	check(play_named(tam_missed, "entry_mark", 1, 0), "second stacked stamp")
	check(tam_missed.last_progress_gained == 1, "the outside hold still scores")
	check(tam_missed.last_patience_loss == 1, "hold in another column does not delay Tam")

	var tam_lone_hold = Rules.scripted_encounter(93, 2, ["hold"], 1, Rules.SHIFT_FOLIO)
	check(play_named(tam_lone_hold, "hold", 2, 0), "a lone hold in column 1")
	check(tam_lone_hold.last_progress_gained == 1, "a lone column-1 hold scores 1")
	check(tam_lone_hold.last_patience_loss == 0 and tam_lone_hold.patience == 5, "the lone hold still delays Tam")

	var sallow_gap = Rules.scripted_encounter(94, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(String(Rules.traveler(sallow_gap)["name"]) == "Pell Sallow", "the folio bell's fourth form is Pell Sallow")
	check(String(Rules.traveler(sallow_gap)["form_name"]) == "Gap Toll", "Pell brings the Gap Toll")
	check(String(Rules.traveler(sallow_gap)["rule_text"]) == "Patience drops by 2 if two stamps have an empty cell between them.", "Pell's form states the gap toll")
	check(play_named(sallow_gap, "entry_mark", 0, 0), "the left cell of the top row")
	check(play_named(sallow_gap, "entry_mark", 0, 2), "Pell receives a stamp with an empty cell between, the wrong stamp")
	check(sallow_gap.last_progress_gained == 4, "a gap does not change what the stamps score (%d)" % sallow_gap.last_progress_gained)
	check(sallow_gap.last_patience_loss == 2, "an empty cell between two stamps drops patience by 2 (%d)" % sallow_gap.last_patience_loss)
	check(sallow_gap.patience == 3, "Pell's patience is 3 after the gap toll")

	var sallow_touch = Rules.scripted_encounter(94, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(play_named(sallow_touch, "entry_mark", 0, 0), "the first of two adjacent stamps")
	check(play_named(sallow_touch, "entry_mark", 0, 1), "Pell receives the next cell, the correct stamp")
	check(sallow_touch.last_progress_gained == 4, "adjacent stamps still score (%d)" % sallow_touch.last_progress_gained)
	check(sallow_touch.last_patience_loss == 1, "stamps with nothing empty between them keep the drop at 1")
	check(sallow_touch.patience == 4, "Pell's patience is 4 when the queue has no gap")

	var sallow_break = Rules.scripted_encounter(94, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(play_named(sallow_break, "entry_mark", 0, 2), "the last cell of the top row")
	check(play_named(sallow_break, "entry_mark", 1, 0), "the first cell of the middle row")
	check(sallow_break.last_progress_gained == 4, "the row break still scores")
	check(sallow_break.last_patience_loss == 1, "the row break is the next queue cell, so it is not a gap")

	var sallow_diagonal = Rules.scripted_encounter(94, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(play_named(sallow_diagonal, "entry_mark", 0, 0), "a corner stamp")
	check(play_named(sallow_diagonal, "entry_mark", 1, 1), "a diagonal stamp")
	check(sallow_diagonal.last_patience_loss == 2, "a diagonal pair gaps when the queue cells between them are empty")

	var sallow_column = Rules.scripted_encounter(94, 3, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_FOLIO)
	check(play_named(sallow_column, "entry_mark", 0, 0), "the top of a column")
	check(play_named(sallow_column, "entry_mark", 1, 0), "the middle of that column")
	check(play_named(sallow_column, "entry_mark", 2, 0), "the bottom of that column")
	check(sallow_column.last_progress_gained == 6, "a full column still scores")
	check(sallow_column.last_patience_loss == 2, "a column leaves empty queue cells between its stamps")

	var sallow_one = Rules.scripted_encounter(94, 3, ["entry_mark"], 1, Rules.SHIFT_FOLIO)
	check(play_named(sallow_one, "entry_mark", 1, 1), "Pell receives one stamp")
	check(sallow_one.last_progress_gained == 2, "one stamp scores its own number")
	check(sallow_one.last_patience_loss == 1, "one stamp cannot leave a gap")

	var sallow_blank = Rules.scripted_encounter(94, 3, ["entry_mark"], 1, Rules.SHIFT_FOLIO)
	Rules.end_turn(sallow_blank)
	check(sallow_blank.last_progress_gained == 0, "an empty form scores nothing for Pell")
	check(sallow_blank.last_patience_loss == 1, "an empty form does not toll Pell")

	var sallow_row = Rules.scripted_encounter(94, 3, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_FOLIO)
	check(play_named(sallow_row, "entry_mark", 0, 0), "the left cell of a full row")
	check(play_named(sallow_row, "entry_mark", 0, 1), "the middle cell of a full row")
	check(play_named(sallow_row, "entry_mark", 0, 2), "the right cell of a full row")
	check(sallow_row.last_progress_gained == 6, "a full row scores 6")
	check(sallow_row.last_patience_loss == 1, "a full row has no empty cell between its stamps")

	var sallow_bottom = Rules.scripted_encounter(94, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(play_named(sallow_bottom, "entry_mark", 2, 0), "the left cell of the bottom row")
	check(play_named(sallow_bottom, "entry_mark", 2, 2), "the right cell of the bottom row")
	check(sallow_bottom.last_patience_loss == 2, "an empty bottom-row cell between two stamps is a gap")

	var sallow_held = Rules.scripted_encounter(94, 3, ["entry_mark", "hold"], 2, Rules.SHIFT_FOLIO)
	check(play_named(sallow_held, "entry_mark", 0, 0), "a stamp before the gap")
	check(play_named(sallow_held, "hold", 1, 2), "hold in Pell's column across that gap")
	check(sallow_held.last_progress_gained == 3, "the held gap still scores")
	check(sallow_held.last_patience_loss == 0 and sallow_held.patience == 5, "hold delays Pell before the gap toll")

	var sallow_missed = Rules.scripted_encounter(94, 3, ["hold", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(play_named(sallow_missed, "hold", 0, 0), "hold outside Pell's column")
	check(play_named(sallow_missed, "entry_mark", 0, 2), "a stamp with an empty cell between")
	check(sallow_missed.last_progress_gained == 3, "the outside hold still scores")
	check(sallow_missed.last_patience_loss == 2, "hold in another column does not spare Pell")

	var sallow_spared = Rules.scripted_encounter(94, 3, ["entry_mark", "entry_mark", "exemption"], 3, Rules.SHIFT_FOLIO)
	check(play_named(sallow_spared, "entry_mark", 0, 0), "a stamp before the gap")
	check(play_named(sallow_spared, "entry_mark", 0, 2), "a stamp after the gap")
	check(play_named(sallow_spared, "exemption", 2, 1), "exemption is placed on Pell's bottom row")
	check(sallow_spared.last_progress_gained == 5, "the stamps still score under the exemption")
	check(sallow_spared.last_patience_loss == 1, "exemption on the bottom row keeps the drop at 1")

	var sallow_flat = Rules.scripted_encounter(94, 3, ["exemption", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(play_named(sallow_flat, "exemption", 2, 0), "exemption on the bottom row")
	check(play_named(sallow_flat, "entry_mark", 2, 1), "the next bottom-row cell")
	check(sallow_flat.last_progress_gained == 3, "contiguous stamps score under the exemption")
	check(sallow_flat.last_patience_loss == 1, "exemption on the bottom row keeps a contiguous queue at 1")

	var sallow_open = Rules.scripted_encounter(94, 3, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_FOLIO)
	check(play_named(sallow_open, "exemption", 1, 1), "exemption sits off Pell's bottom row")
	check(play_named(sallow_open, "entry_mark", 0, 0), "a stamp before the gap")
	check(play_named(sallow_open, "entry_mark", 0, 2), "a stamp after the gap")
	check(sallow_open.last_patience_loss == 2, "an exemption off the bottom row leaves the gap toll")

	var nell = Rules.scripted_encounter(8, 0, ["duty"], 1, Rules.SHIFT_LATE)
	check(play_named(nell, "duty", 2, 0), "Nell receives a lone column-1 duty")
	check(nell.last_progress_gained == 0, "the late shift still refuses a lone column-1 duty (%d)" % nell.last_progress_gained)
	var mara = Rules.scripted_encounter(81, 0, ["duty"], 1, Rules.SHIFT_QUAY)
	check(play_named(mara, "duty", 2, 2), "Mara receives a lone bottom-row duty")
	check(mara.last_progress_gained == 0, "the quay bell still refuses the first stamp (%d)" % mara.last_progress_gained)
	var ned = Rules.scripted_encounter(74, 3, ["duty"], 1, Rules.SHIFT_SALT)
	check(play_named(ned, "duty", 2, 2), "Ned receives a lone bottom-row duty")
	check(ned.last_progress_gained == 8, "the salt watch still doubles the last stamp (%d)" % ned.last_progress_gained)
	var ida = Rules.scripted_encounter(64, 3, ["duty"], 1, Rules.SHIFT_QUIRE)
	check(play_named(ida, "duty", 2, 2), "Ida receives a lone bottom-row duty")
	check(ida.last_progress_gained == 8, "the quire watch still doubles the first stamp (%d)" % ida.last_progress_gained)
	var orla = Rules.scripted_encounter(31, 0, ["duty"], 1, Rules.SHIFT_ASH)
	check(play_named(orla, "duty", 0, 2), "Orla receives a top-row duty")
	check(orla.last_progress_gained == 2, "the ash watch still counts a top-row duty (%d)" % orla.last_progress_gained)


func test_folio_bell_opens() -> void:
	check(Rules.FOLIO_BELL.size() == 4, "the folio bell has four travelers")
	check(String(Rules.FOLIO_BELL[0]["name"]) == "Ness Hart", "the folio bell begins with Ness Hart")
	check(String(Rules.FOLIO_BELL[1]["name"]) == "Wynn Cress", "the folio bell's second traveler is Wynn Cress")
	check(String(Rules.FOLIO_BELL[2]["name"]) == "Tam Quern", "the folio bell's third traveler is Tam Quern")
	check(String(Rules.FOLIO_BELL[3]["name"]) == "Pell Sallow", "the folio bell ends with Pell Sallow")
	check(Rules.QUAY_BELL.size() == 4 and String(Rules.QUAY_BELL[0]["name"]) == "Mara Quill", "the quay bell still begins with Mara Quill")
	check(String(Rules.QUAY_BELL[3]["name"]) == "Ivo Pell", "the quay bell still ends with Ivo Pell")
	check(Rules.TRAVELERS.size() == 4 and String(Rules.TRAVELERS[0]["name"]) == "Ada Quill", "Act 1 still begins with Ada Quill")
	var folio = Rules.new_run(78, Rules.SHIFT_FOLIO)
	check(folio.shift == Rules.SHIFT_FOLIO, "the folio bell is a separate night")
	check(String(Rules.traveler(folio)["name"]) == "Ness Hart", "the folio bell begins with Ness Hart")
	check(folio.hand.size() == Rules.HAND_SIZE, "the folio bell draws 5")
	check(folio.ink == Rules.BASE_INK, "the folio bell starts at 3 ink")
	check(folio.library.size() == Rules.STARTING_DECK.size(), "the folio bell deals the starting deck")
	check(folio.relic_id == "", "an earlier night's relic does not carry")
	check(folio.phase == "play", "the folio bell opens in play")
	var dealt: Array = []
	for iid in folio.hand:
		dealt.append(Rules.card_id_of(folio, int(iid)))
	var before = folio.library.size()
	folio.progress = 4
	folio.patience = 1
	Rules.restart_encounter(folio)
	check(folio.shift == Rules.SHIFT_FOLIO and folio.traveler_index == 0, "restart encounter stays on the folio bell")
	check(folio.progress == 0 and folio.patience == int(Rules.FOLIO_BELL[0]["patience"]), "restart encounter resets Ness")
	check(folio.library.size() == before and folio.hand.size() == 5 and folio.phase == "play", "restart keeps the folio-bell deck and deals a hand")
	var redealt: Array = []
	for iid in folio.hand:
		redealt.append(Rules.card_id_of(folio, int(iid)))
	check(redealt == dealt, "restart deals Ness the same hand")

	var packed = load("res://game/main.tscn")
	var desk = packed.instantiate()
	root.add_child(desk)
	if desk.state == null:
		desk._ready()
	check(desk.state.shift == Rules.SHIFT_FIRST, "the desk still opens on Act 1")
	check(desk.folio_button.text == "Folio bell", "the desk offers the folio bell")
	check(desk.quay_button.text == "Quay bell", "the desk still offers the quay bell")
	desk.folio_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FOLIO, "the desk can open the folio bell")
	check(String(Rules.traveler(desk.state)["name"]) == "Ness Hart", "the open desk shows Ness")
	check(String(desk.desk_label.text).begins_with("Folio bell"), "the desk title follows the folio bell")
	check(desk.meta_label.text.contains("Last Bar"), "the desk shows Ness's form")
	check(desk.folio_button.text == "First bell", "the folio bell can return to the first bell")
	check(desk.quay_button.text == "Quay bell", "the quay bell stays available from the folio bell")
	check(desk.shift_button.text == "Late shift", "the late shift stays available from the folio bell")
	desk._restart_act()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FOLIO and String(Rules.traveler(desk.state)["name"]) == "Ness Hart", "restart act replays the folio bell")
	desk.folio_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the folio bell returns to Ada")
	var doors = [
		["_begin_late_shift", "Nell Parr", "the late shift"],
		["_begin_closing_bell", "Moss Quen", "the closing bell"],
		["_begin_ash_watch", "Orla Fen", "the ash watch"],
		["_begin_gutter_lamp", "Ivo Dane", "the gutter lamp"],
		["_begin_vellum_bell", "Edda Voss", "the vellum bell"],
		["_begin_quire_watch", "Tess Quern", "the quire watch"],
		["_begin_salt_watch", "Pell Voss", "the salt watch"],
		["_begin_quay_bell", "Mara Quill", "the quay bell"],
	]
	for door in doors:
		desk.call(String(door[0]))
		desk._refresh_ui()
		check(desk.state.shift != Rules.SHIFT_FOLIO and String(Rules.traveler(desk.state)["name"]) == String(door[1]), "%s still opens" % String(door[2]))
		check(desk.folio_button.text == "Folio bell", "%s offers the folio bell" % String(door[2]))
		desk._begin_folio_bell()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_FOLIO and String(Rules.traveler(desk.state)["name"]) == "Ness Hart", "%s can open the folio bell" % String(door[2]))
	desk._begin_first_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "first bell still returns to Ada")
	var victories = [
		[Rules.SHIFT_FIRST, "Act 1"],
		[Rules.SHIFT_LATE, "the late shift"],
		[Rules.SHIFT_CLOSING, "the closing bell"],
		[Rules.SHIFT_ASH, "the ash watch"],
		[Rules.SHIFT_GUTTER, "the gutter lamp"],
		[Rules.SHIFT_VELLUM, "the vellum bell"],
		[Rules.SHIFT_QUIRE, "the quire watch"],
		[Rules.SHIFT_SALT, "the salt watch"],
		[Rules.SHIFT_QUAY, "the quay bell"],
	]
	for victory in victories:
		desk._open_shift(int(victory[0]), desk.state.seed)
		desk._refresh_ui()
		desk.state.phase = "victory"
		desk._refresh_ui()
		var victory_folio = _button_named(desk, "Open the folio bell")
		check(victory_folio != null, "%s's victory desk offers the folio bell" % String(victory[1]))
		if victory_folio != null:
			victory_folio.pressed.emit()
			desk._refresh_ui()
			check(desk.state.shift == Rules.SHIFT_FOLIO and String(Rules.traveler(desk.state)["name"]) == "Ness Hart", "%s's victory desk opens the folio bell" % String(victory[1]))
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_first = _button_named(desk, "Open the first bell")
	check(victory_first != null, "the folio bell victory desk offers the first bell")
	if victory_first != null:
		victory_first.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the folio bell victory desk opens the first bell")
	desk._begin_folio_bell()
	desk._refresh_ui()
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_quay = _button_named(desk, "Open the quay bell")
	check(victory_quay != null, "the folio bell victory desk offers the quay bell")
	if victory_quay != null:
		victory_quay.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_QUAY and String(Rules.traveler(desk.state)["name"]) == "Mara Quill", "the folio bell victory desk opens the quay bell")
	root.remove_child(desk)
	desk.free()


func test_policy_clears_folio_bell() -> void:
	var started = Time.get_ticks_msec()
	var state = Rules.new_run(12345, Rules.SHIFT_FOLIO)
	var steps = 0
	var seen = 0
	while state.phase != "victory":
		steps += 1
		if steps > 500 or state.phase == "defeat":
			check(false, "policy lost or stalled on the folio bell, seed 12345: " + Rules.debug_summary(state))
			return
		var action = Policy.choose(state)
		if not Rules.apply_action(state, action):
			check(false, "folio-bell policy action was rejected: %s / %s" % [str(action), Rules.debug_summary(state)])
			return
		if state.encounters_cleared != seen:
			seen = state.encounters_cleared
			print("cleared folio encounter %d after %d actions" % [seen, steps])
	var elapsed = Time.get_ticks_msec() - started
	check(state.encounters_cleared == 4, "policy cleared all 4 folio-bell encounters on seed 12345")
	check(state.phase == "victory", "folio bell ends in victory")
	check(state.shift == Rules.SHIFT_FOLIO, "the clear stayed on the folio bell")
	print("folio bell finished in %d actions, %d ms" % [steps, elapsed])


func test_wick_bell_rules() -> void:
	var odell = Rules.scripted_encounter(101, 0, ["duty", "entry_mark"], 3, Rules.SHIFT_WICK)
	check(String(Rules.traveler(odell)["name"]) == "Odell Voss", "the wick bell's first form is Odell Voss")
	check(String(Rules.traveler(odell)["form_name"]) == "Row Bar", "Odell brings the Row Bar")
	check(String(Rules.traveler(odell)["rule_text"]) == "A stamp on the bottom row scores 0 when that row holds another stamp. A lone bottom-row stamp counts.", "Odell's form states the stacked-row rule")
	check(Rules.preview_progress(odell, "duty", 2, 1) == 4, "preview counts a lone bottom-row duty for Odell")
	check(Rules.preview_progress(odell, "entry_mark", 0, 0) == 2, "preview counts a top-row stamp for Odell")
	check(play_named(odell, "entry_mark", 2, 0), "the first bottom-row stamp leaves Odell's turn open")
	check(odell.phase == "play", "Odell's first stamp does not end the turn")
	check(Rules.preview_progress(odell, "duty", 2, 2) == 0, "preview zeros a second stamp on the bottom row")
	check(Rules.preview_progress(odell, "duty", 0, 0) == 2, "preview still counts the top row beside a lone bottom stamp")

	var stacked = Rules.scripted_encounter(101, 0, ["entry_mark", "duty"], 2, Rules.SHIFT_WICK)
	check(play_named(stacked, "entry_mark", 2, 0), "a stamp on the bottom row")
	check(play_named(stacked, "duty", 2, 2), "Odell receives a second bottom-row stamp, the wrong stamp")
	check(stacked.last_progress_gained == 0, "a stacked bottom row scores 0 (%d)" % stacked.last_progress_gained)

	var lone = Rules.scripted_encounter(101, 0, ["duty"], 1, Rules.SHIFT_WICK)
	check(play_named(lone, "duty", 2, 0), "Odell receives a lone bottom-row duty, the correct stamp")
	check(lone.last_progress_gained == 4, "a lone bottom-row stamp scores its own number (%d)" % lone.last_progress_gained)
	check(lone.last_patience_loss == 1, "a lone bottom-row stamp still spends the turn")

	var beside = Rules.scripted_encounter(101, 0, ["duty", "entry_mark"], 2, Rules.SHIFT_WICK)
	check(play_named(beside, "duty", 2, 0), "one stamp on the bottom row")
	check(play_named(beside, "entry_mark", 0, 0), "a stamp on the top row")
	check(beside.last_progress_gained == 6, "a top-row stamp scores beside a lone bottom row (%d)" % beside.last_progress_gained)

	var shared_top = Rules.scripted_encounter(101, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_WICK)
	check(play_named(shared_top, "entry_mark", 0, 0), "the left cell of the top row")
	check(play_named(shared_top, "entry_mark", 0, 2), "another stamp on the top row")
	check(shared_top.last_progress_gained == 4, "a shared top row still counts for Odell (%d)" % shared_top.last_progress_gained)

	var shared_middle = Rules.scripted_encounter(101, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_WICK)
	check(play_named(shared_middle, "entry_mark", 1, 0), "the left cell of the middle row")
	check(play_named(shared_middle, "entry_mark", 1, 2), "another stamp on the middle row")
	check(shared_middle.last_progress_gained == 4, "a shared middle row still counts for Odell (%d)" % shared_middle.last_progress_gained)

	var freed = Rules.scripted_encounter(101, 0, ["exemption", "duty"], 2, Rules.SHIFT_WICK)
	check(play_named(freed, "exemption", 2, 0), "exemption is placed on Odell's bottom row")
	check(play_named(freed, "duty", 2, 2), "a second bottom-row stamp under that exemption")
	check(freed.last_progress_gained == 5, "exemption on the bottom row lets a stacked bottom row count (%d)" % freed.last_progress_gained)

	var still_stacked = Rules.scripted_encounter(101, 0, ["exemption", "entry_mark", "duty"], 3, Rules.SHIFT_WICK)
	check(play_named(still_stacked, "exemption", 1, 1), "exemption sits off Odell's bottom row")
	check(play_named(still_stacked, "entry_mark", 2, 0), "a bottom-row stamp")
	check(play_named(still_stacked, "duty", 2, 2), "a second bottom-row stamp")
	check(still_stacked.last_progress_gained == 1, "an exemption off the bottom row leaves the stacked row at 0 (%d)" % still_stacked.last_progress_gained)

	var stacked_echo = Rules.scripted_encounter(101, 0, ["echo", "entry_mark", "entry_mark"], 3, Rules.SHIFT_WICK)
	check(play_named(stacked_echo, "echo", 1, 0), "echo sits above the bottom row")
	check(play_named(stacked_echo, "entry_mark", 2, 0), "a bottom-row stamp under the echo")
	check(play_named(stacked_echo, "entry_mark", 2, 2), "a second bottom-row stamp")
	check(stacked_echo.last_chain_count == 1, "the stacked echo still retriggers")
	check(stacked_echo.last_progress_gained == 1, "a retrigger of a stacked bottom-row stamp scores 0 (%d)" % stacked_echo.last_progress_gained)

	var odell_held = Rules.scripted_encounter(101, 0, ["hold", "entry_mark"], 2, Rules.SHIFT_WICK)
	check(play_named(odell_held, "hold", 2, 1), "hold in Odell's column on the bottom row")
	check(play_named(odell_held, "entry_mark", 2, 0), "a second stamp on that row")
	check(odell_held.last_progress_gained == 0, "the stacked hold grants no progress")
	check(odell_held.last_patience_loss == 0 and odell_held.patience == 5, "a stacked hold still delays Odell")

	var odell_missed = Rules.scripted_encounter(101, 0, ["hold", "entry_mark"], 2, Rules.SHIFT_WICK)
	check(play_named(odell_missed, "hold", 2, 2), "hold outside Odell's column")
	check(play_named(odell_missed, "entry_mark", 2, 0), "a second bottom-row stamp")
	check(odell_missed.last_progress_gained == 0, "the outside hold is still on the stacked row")
	check(odell_missed.last_patience_loss == 1, "hold in another column does not delay Odell")

	var cress = Rules.scripted_encounter(102, 1, ["duty"], 1, Rules.SHIFT_WICK)
	check(String(Rules.traveler(cress)["name"]) == "Cress Hart", "the wick bell's second form is Cress Hart")
	check(String(Rules.traveler(cress)["form_name"]) == "First Slip", "Cress brings the First Slip")
	check(String(Rules.traveler(cress)["rule_text"]) == "The first stamp in the queue scores twice when a later stamp follows it. A lone stamp scores its own number.", "Cress's form states the followed-first rule")
	check(Rules.preview_progress(cress, "duty", 2, 2) == 4, "preview leaves a lone duty at its own number")
	check(play_named(cress, "duty", 2, 2), "Cress receives a lone bottom-row duty, the wrong stamp")
	check(cress.last_progress_gained == 4, "a lone stamp scores its own number, not twice (%d)" % cress.last_progress_gained)

	var followed = Rules.scripted_encounter(102, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_WICK)
	check(play_named(followed, "entry_mark", 0, 0), "the first cell")
	check(play_named(followed, "entry_mark", 0, 2), "Cress receives a later stamp, the correct stamp")
	check(followed.last_progress_gained == 6, "the first stamp scores twice and the later stamp scores 2 (%d)" % followed.last_progress_gained)

	var later_duty = Rules.scripted_encounter(102, 1, ["entry_mark", "duty"], 2, Rules.SHIFT_WICK)
	check(play_named(later_duty, "entry_mark", 0, 0), "the first stamp")
	check(play_named(later_duty, "duty", 2, 2), "a later bottom-row duty")
	check(later_duty.last_progress_gained == 8, "the later duty scores its own 4 (%d)" % later_duty.last_progress_gained)

	var pressed_last = Rules.scripted_encounter(102, 1, ["duty", "entry_mark"], 2, Rules.SHIFT_WICK)
	check(play_named(pressed_last, "duty", 2, 2), "the later cell is pressed first")
	check(pressed_last.phase == "play", "the first press leaves Cress's turn open")
	check(play_named(pressed_last, "entry_mark", 0, 0), "the queue head is pressed last")
	check(pressed_last.last_progress_gained == 8, "queue order, not press order, doubles Cress's first stamp (%d)" % pressed_last.last_progress_gained)

	var cress_muted = Rules.scripted_encounter(102, 1, ["exemption", "entry_mark"], 2, Rules.SHIFT_WICK)
	check(play_named(cress_muted, "exemption", 0, 0), "exemption is the first stamp on Cress's top row")
	check(play_named(cress_muted, "entry_mark", 0, 2), "a later stamp follows that exemption")
	check(cress_muted.last_progress_gained == 3, "exemption on the top row cancels the doubling (%d)" % cress_muted.last_progress_gained)

	var cress_kept = Rules.scripted_encounter(102, 1, ["entry_mark", "exemption"], 2, Rules.SHIFT_WICK)
	check(play_named(cress_kept, "entry_mark", 0, 0), "the first stamp")
	check(play_named(cress_kept, "exemption", 2, 2), "exemption sits off Cress's top row")
	check(cress_kept.last_progress_gained == 5, "an exemption off the top row leaves the first stamp doubled (%d)" % cress_kept.last_progress_gained)

	var cress_reply = Rules.scripted_encounter(102, 1, ["entry_mark", "reply"], 2, Rules.SHIFT_WICK)
	check(play_named(cress_reply, "entry_mark", 0, 0), "a followed first stamp")
	check(play_named(cress_reply, "reply", 1, 0), "reply retriggers that first stamp")
	check(cress_reply.last_chain_count == 1, "the reply still retriggers the first stamp")
	check(cress_reply.last_progress_gained == 9, "a retrigger of the followed first stamp scores twice again (%d)" % cress_reply.last_progress_gained)

	var cress_echo = Rules.scripted_encounter(102, 1, ["echo", "entry_mark"], 2, Rules.SHIFT_WICK)
	check(play_named(cress_echo, "echo", 0, 0), "echo is the first stamp")
	check(play_named(cress_echo, "entry_mark", 1, 0), "a later stamp under the echo")
	check(cress_echo.last_chain_count == 1, "the echo still retriggers the later stamp")
	check(cress_echo.last_progress_gained == 6, "a retrigger of a later stamp is not doubled (%d)" % cress_echo.last_progress_gained)

	var cress_held = Rules.scripted_encounter(102, 1, ["entry_mark", "hold"], 2, Rules.SHIFT_WICK)
	check(play_named(cress_held, "entry_mark", 0, 2), "a later stamp")
	check(play_named(cress_held, "hold", 1, 0), "hold in Cress's column")
	check(cress_held.last_progress_gained == 5, "the held first stamp still scores twice")
	check(cress_held.last_patience_loss == 0 and cress_held.patience == 5, "hold delays Cress")

	var jun = Rules.scripted_encounter(103, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_WICK)
	check(String(Rules.traveler(jun)["name"]) == "Jun Solt", "the wick bell's third form is Jun Solt")
	check(String(Rules.traveler(jun)["form_name"]) == "Pair Bar", "Jun brings the Pair Bar")
	check(String(Rules.traveler(jun)["rule_text"]) == "If two stamps share a number, the later one scores 0. The earlier stamp scores its own number.", "Jun's form states the later-number rule")
	check(Rules.preview_progress(jun, "entry_mark", 0, 0) == 2, "preview counts a first entry mark")
	check(play_named(jun, "entry_mark", 0, 0), "the earlier entry mark leaves the turn open")
	check(jun.phase == "play", "Jun's first stamp does not end the turn")
	check(Rules.preview_progress(jun, "entry_mark", 0, 2) == 0, "preview zeros a later stamp with the same number")
	check(Rules.preview_progress(jun, "visa_dot", 0, 2) == 3, "preview counts a later stamp with a different number")
	check(play_named(jun, "entry_mark", 0, 2), "Jun receives a later shared number, the wrong stamp")
	check(jun.last_progress_gained == 2, "the later shared stamp scores 0 and the earlier stamp scores 2 (%d)" % jun.last_progress_gained)
	check(jun.last_patience_loss == 1, "a shared number does not change Jun's patience drop")

	var different = Rules.scripted_encounter(103, 2, ["entry_mark", "duty"], 2, Rules.SHIFT_WICK)
	check(play_named(different, "entry_mark", 0, 0), "an entry mark of 2")
	check(play_named(different, "duty", 2, 2), "Jun receives a bottom-row duty, the correct stamp")
	check(different.last_progress_gained == 6, "a later stamp with a different number scores its own 4 (%d)" % different.last_progress_gained)

	var same_card = Rules.scripted_encounter(103, 2, ["duty", "duty"], 2, Rules.SHIFT_WICK)
	check(play_named(same_card, "duty", 0, 0), "a top-row duty of 2")
	check(play_named(same_card, "duty", 2, 2), "a bottom-row duty of 4")
	check(same_card.last_progress_gained == 6, "the same card can fail to share when the numbers differ (%d)" % same_card.last_progress_gained)

	var shared_duty = Rules.scripted_encounter(103, 2, ["duty", "entry_mark"], 2, Rules.SHIFT_WICK)
	check(play_named(shared_duty, "duty", 0, 0), "a top-row duty of 2")
	check(play_named(shared_duty, "entry_mark", 0, 2), "an entry mark of 2")
	check(shared_duty.last_progress_gained == 2, "different cards share when their numbers match (%d)" % shared_duty.last_progress_gained)

	var triple = Rules.scripted_encounter(103, 2, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_WICK)
	check(play_named(triple, "entry_mark", 0, 0), "the first shared stamp")
	check(play_named(triple, "entry_mark", 0, 1), "the second shared stamp")
	check(play_named(triple, "entry_mark", 0, 2), "the third shared stamp")
	check(triple.last_progress_gained == 2, "the second and third shared stamps score 0 (%d)" % triple.last_progress_gained)

	var gapped = Rules.scripted_encounter(103, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_WICK)
	check(play_named(gapped, "entry_mark", 0, 0), "a stamp before the gap")
	check(play_named(gapped, "entry_mark", 2, 2), "a stamp after the gap")
	check(gapped.last_progress_gained == 2, "a gap does not block a shared number (%d)" % gapped.last_progress_gained)

	var pressed_jun = Rules.scripted_encounter(103, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_WICK)
	check(play_named(pressed_jun, "entry_mark", 2, 2), "the later cell is pressed first")
	check(play_named(pressed_jun, "entry_mark", 0, 0), "the earlier cell is pressed last")
	check(pressed_jun.last_progress_gained == 2, "queue order, not press order, bars Jun's later stamp (%d)" % pressed_jun.last_progress_gained)

	var surcharge_open = Rules.scripted_encounter(103, 2, ["entry_mark", "surcharge"], 2, Rules.SHIFT_WICK)
	check(play_named(surcharge_open, "entry_mark", 0, 0), "an entry mark of 2")
	check(play_named(surcharge_open, "surcharge", 2, 1), "a surcharge with an empty cell above")
	check(surcharge_open.last_progress_gained == 2, "a surcharge of 2 shares with an entry mark (%d)" % surcharge_open.last_progress_gained)

	var surcharge_fed = Rules.scripted_encounter(103, 2, ["entry_mark", "surcharge"], 2, Rules.SHIFT_WICK)
	check(play_named(surcharge_fed, "entry_mark", 1, 1), "the cell above the surcharge")
	check(play_named(surcharge_fed, "surcharge", 2, 1), "a surcharge of 5")
	check(surcharge_fed.last_progress_gained == 7, "a filled cell above changes the surcharge's number (%d)" % surcharge_fed.last_progress_gained)

	var jun_spared = Rules.scripted_encounter(103, 2, ["entry_mark", "entry_mark", "exemption"], 3, Rules.SHIFT_WICK)
	check(play_named(jun_spared, "entry_mark", 0, 0), "the earlier shared stamp")
	check(play_named(jun_spared, "entry_mark", 0, 2), "the later shared stamp")
	check(play_named(jun_spared, "exemption", 2, 1), "exemption is placed on Jun's bottom row")
	check(jun_spared.last_progress_gained == 5, "exemption on the bottom row lets the later stamp count (%d)" % jun_spared.last_progress_gained)

	var jun_open = Rules.scripted_encounter(103, 2, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_WICK)
	check(play_named(jun_open, "exemption", 0, 0), "exemption sits off Jun's bottom row")
	check(play_named(jun_open, "entry_mark", 0, 1), "an entry mark of 2")
	check(play_named(jun_open, "entry_mark", 0, 2), "a later entry mark of 2")
	check(jun_open.last_progress_gained == 3, "an exemption off the bottom row leaves the later stamp at 0 (%d)" % jun_open.last_progress_gained)

	var jun_reply = Rules.scripted_encounter(103, 2, ["entry_mark", "entry_mark", "reply"], 3, Rules.SHIFT_WICK)
	check(play_named(jun_reply, "entry_mark", 0, 0), "the earlier stamp")
	check(play_named(jun_reply, "entry_mark", 1, 0), "a later shared stamp")
	check(play_named(jun_reply, "reply", 2, 0), "reply retriggers the later shared stamp")
	check(jun_reply.last_chain_count == 1, "the reply still retriggers")
	check(jun_reply.last_progress_gained == 3, "a retrigger of a later shared stamp scores 0 (%d)" % jun_reply.last_progress_gained)

	var jun_early = Rules.scripted_encounter(103, 2, ["entry_mark", "reply", "entry_mark"], 3, Rules.SHIFT_WICK)
	check(play_named(jun_early, "entry_mark", 0, 0), "the earlier stamp")
	check(play_named(jun_early, "reply", 1, 0), "reply retriggers the earlier stamp")
	check(play_named(jun_early, "entry_mark", 2, 2), "a later shared stamp")
	check(jun_early.last_chain_count == 1, "the reply still retriggers the earlier stamp")
	check(jun_early.last_progress_gained == 5, "a retrigger of the earlier stamp scores its own number (%d)" % jun_early.last_progress_gained)

	var jun_held = Rules.scripted_encounter(103, 2, ["exemption", "hold"], 2, Rules.SHIFT_WICK)
	check(play_named(jun_held, "exemption", 0, 0), "an exemption of 1 off the bottom row")
	check(play_named(jun_held, "hold", 2, 2), "hold in Jun's column shares that number")
	check(jun_held.last_progress_gained == 1, "the later shared hold grants no progress")
	check(jun_held.last_patience_loss == 0 and jun_held.patience == 5, "a barred hold still delays Jun")

	var ives = Rules.scripted_encounter(104, 3, ["entry_mark"], 1, Rules.SHIFT_WICK)
	check(String(Rules.traveler(ives)["name"]) == "Ives Mire", "the wick bell's fourth form is Ives Mire")
	check(String(Rules.traveler(ives)["form_name"]) == "Empty Yield", "Ives brings the Empty Yield")
	check(String(Rules.traveler(ives)["rule_text"]) == "Each empty cell adds 1 to every filled stamp's own progress.", "Ives's form states the empty-cell yield")
	check(Rules.preview_progress(ives, "entry_mark", 0, 0) == 10, "preview adds 8 empty cells to a lone entry mark")
	check(Rules.preview_progress(ives, "entry_mark", 1, 1) == 10, "preview adds the same bonus to the center")
	check(play_named(ives, "entry_mark", 1, 1), "Ives receives a lone center entry mark, the correct stamp")
	check(ives.last_progress_gained == 10, "eight empty cells add 8 to the stamp's own 2 (%d)" % ives.last_progress_gained)

	var ives_pair = Rules.scripted_encounter(104, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_WICK)
	check(play_named(ives_pair, "entry_mark", 0, 0), "the first of two stamps")
	check(play_named(ives_pair, "entry_mark", 2, 2), "the second of two stamps")
	check(ives_pair.last_progress_gained == 18, "seven empty cells add 7 to each filled stamp (%d)" % ives_pair.last_progress_gained)

	var ives_three = Rules.scripted_encounter(104, 3, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_WICK)
	check(play_named(ives_three, "entry_mark", 0, 0), "the first of three stamps")
	check(play_named(ives_three, "entry_mark", 1, 1), "the center stamp")
	check(play_named(ives_three, "entry_mark", 2, 2), "the third stamp")
	check(ives_three.last_progress_gained == 24, "six empty cells add 6 to every filled stamp (%d)" % ives_three.last_progress_gained)

	var ives_muted = Rules.scripted_encounter(104, 3, ["exemption", "entry_mark"], 2, Rules.SHIFT_WICK)
	check(play_named(ives_muted, "exemption", 0, 1), "exemption is placed on Ives's top row")
	check(play_named(ives_muted, "entry_mark", 2, 2), "Ives receives an entry mark under that exemption, the wrong stamp")
	check(ives_muted.last_progress_gained == 3, "exemption on the top row cancels the empty-cell bonus (%d)" % ives_muted.last_progress_gained)

	var ives_kept = Rules.scripted_encounter(104, 3, ["exemption", "entry_mark"], 2, Rules.SHIFT_WICK)
	check(play_named(ives_kept, "exemption", 2, 0), "exemption sits off Ives's top row")
	check(play_named(ives_kept, "entry_mark", 0, 0), "an entry mark beside that exemption")
	check(ives_kept.last_progress_gained == 17, "an exemption off the top row leaves the empty-cell bonus (%d)" % ives_kept.last_progress_gained)

	var ives_echo = Rules.scripted_encounter(104, 3, ["echo", "entry_mark"], 2, Rules.SHIFT_WICK)
	check(play_named(ives_echo, "echo", 0, 0), "echo above a stamp")
	check(play_named(ives_echo, "entry_mark", 1, 0), "the stamp under the echo")
	check(ives_echo.last_chain_count == 1, "the echo still retriggers")
	check(ives_echo.last_progress_gained == 26, "a retrigger adds the empty-cell bonus again (%d)" % ives_echo.last_progress_gained)

	var ives_held = Rules.scripted_encounter(104, 3, ["hold"], 1, Rules.SHIFT_WICK)
	check(play_named(ives_held, "hold", 0, 1), "hold in Ives's column")
	check(ives_held.last_progress_gained == 9, "the held stamp still gains the empty-cell bonus")
	check(ives_held.last_patience_loss == 0 and ives_held.patience == 5, "hold delays Ives")

	var nell = Rules.scripted_encounter(8, 0, ["duty"], 1, Rules.SHIFT_LATE)
	check(play_named(nell, "duty", 2, 0), "Nell receives a lone column-1 duty")
	check(nell.last_progress_gained == 0, "the late shift still refuses a lone column-1 duty (%d)" % nell.last_progress_gained)
	var ida = Rules.scripted_encounter(64, 3, ["duty"], 1, Rules.SHIFT_QUIRE)
	check(play_named(ida, "duty", 2, 2), "Ida receives a lone bottom-row duty")
	check(ida.last_progress_gained == 8, "the quire watch still doubles a lone first stamp (%d)" % ida.last_progress_gained)
	var orla = Rules.scripted_encounter(31, 0, ["duty"], 1, Rules.SHIFT_ASH)
	check(play_named(orla, "duty", 2, 2), "Orla receives a lone bottom-row duty")
	check(orla.last_progress_gained == 0, "the ash watch still refuses a lone bottom-row duty (%d)" % orla.last_progress_gained)


func test_wick_bell_opens() -> void:
	check(Rules.WICK_BELL.size() == 4, "the wick bell has four travelers")
	check(String(Rules.WICK_BELL[0]["name"]) == "Odell Voss", "the wick bell begins with Odell Voss")
	check(String(Rules.WICK_BELL[1]["name"]) == "Cress Hart", "the wick bell's second traveler is Cress Hart")
	check(String(Rules.WICK_BELL[2]["name"]) == "Jun Solt", "the wick bell's third traveler is Jun Solt")
	check(String(Rules.WICK_BELL[3]["name"]) == "Ives Mire", "the wick bell ends with Ives Mire")
	check(Rules.FOLIO_BELL.size() == 4 and String(Rules.FOLIO_BELL[0]["name"]) == "Ness Hart", "the folio bell still begins with Ness Hart")
	check(String(Rules.FOLIO_BELL[3]["name"]) == "Pell Sallow", "the folio bell still ends with Pell Sallow")
	check(Rules.TRAVELERS.size() == 4 and String(Rules.TRAVELERS[0]["name"]) == "Ada Quill", "Act 1 still begins with Ada Quill")
	var wick = Rules.new_run(78, Rules.SHIFT_WICK)
	check(wick.shift == Rules.SHIFT_WICK, "the wick bell is a separate night")
	check(String(Rules.traveler(wick)["name"]) == "Odell Voss", "the wick bell begins with Odell Voss")
	check(wick.hand.size() == Rules.HAND_SIZE, "the wick bell draws 5")
	check(wick.ink == Rules.BASE_INK, "the wick bell starts at 3 ink")
	check(wick.library.size() == Rules.STARTING_DECK.size(), "the wick bell deals the starting deck")
	check(wick.relic_id == "", "an earlier night's relic does not carry")
	check(wick.phase == "play", "the wick bell opens in play")
	var dealt: Array = []
	for iid in wick.hand:
		dealt.append(Rules.card_id_of(wick, int(iid)))
	var before = wick.library.size()
	wick.progress = 4
	wick.patience = 1
	Rules.restart_encounter(wick)
	check(wick.shift == Rules.SHIFT_WICK and wick.traveler_index == 0, "restart encounter stays on the wick bell")
	check(wick.progress == 0 and wick.patience == int(Rules.WICK_BELL[0]["patience"]), "restart encounter resets Odell")
	check(wick.library.size() == before and wick.hand.size() == 5 and wick.phase == "play", "restart keeps the wick-bell deck and deals a hand")
	var redealt: Array = []
	for iid in wick.hand:
		redealt.append(Rules.card_id_of(wick, int(iid)))
	check(redealt == dealt, "restart deals Odell the same hand")

	var packed = load("res://game/main.tscn")
	var desk = packed.instantiate()
	root.add_child(desk)
	if desk.state == null:
		desk._ready()
	check(desk.state.shift == Rules.SHIFT_FIRST, "the desk still opens on Act 1")
	check(desk.wick_button.text == "Wick bell", "the desk offers the wick bell")
	check(desk.folio_button.text == "Folio bell", "the desk still offers the folio bell")
	desk.wick_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_WICK, "the desk can open the wick bell")
	check(String(Rules.traveler(desk.state)["name"]) == "Odell Voss", "the open desk shows Odell")
	check(String(desk.desk_label.text).begins_with("Wick bell"), "the desk title follows the wick bell")
	check(desk.meta_label.text.contains("Row Bar"), "the desk shows Odell's form")
	check(desk.wick_button.text == "First bell", "the wick bell can return to the first bell")
	check(desk.folio_button.text == "Folio bell", "the folio bell stays available from the wick bell")
	check(desk.shift_button.text == "Late shift", "the late shift stays available from the wick bell")
	desk._restart_act()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_WICK and String(Rules.traveler(desk.state)["name"]) == "Odell Voss", "restart act replays the wick bell")
	desk.wick_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the wick bell returns to Ada")
	var doors = [
		["_begin_late_shift", "Nell Parr", "the late shift"],
		["_begin_closing_bell", "Moss Quen", "the closing bell"],
		["_begin_ash_watch", "Orla Fen", "the ash watch"],
		["_begin_gutter_lamp", "Ivo Dane", "the gutter lamp"],
		["_begin_vellum_bell", "Edda Voss", "the vellum bell"],
		["_begin_quire_watch", "Tess Quern", "the quire watch"],
		["_begin_salt_watch", "Pell Voss", "the salt watch"],
		["_begin_quay_bell", "Mara Quill", "the quay bell"],
		["_begin_folio_bell", "Ness Hart", "the folio bell"],
	]
	for door in doors:
		desk.call(String(door[0]))
		desk._refresh_ui()
		check(desk.state.shift != Rules.SHIFT_WICK and String(Rules.traveler(desk.state)["name"]) == String(door[1]), "%s still opens" % String(door[2]))
		check(desk.wick_button.text == "Wick bell", "%s offers the wick bell" % String(door[2]))
		desk._begin_wick_bell()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_WICK and String(Rules.traveler(desk.state)["name"]) == "Odell Voss", "%s can open the wick bell" % String(door[2]))
	desk._begin_first_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "first bell still returns to Ada")
	var victories = [
		[Rules.SHIFT_FIRST, "Act 1"],
		[Rules.SHIFT_LATE, "the late shift"],
		[Rules.SHIFT_CLOSING, "the closing bell"],
		[Rules.SHIFT_ASH, "the ash watch"],
		[Rules.SHIFT_GUTTER, "the gutter lamp"],
		[Rules.SHIFT_VELLUM, "the vellum bell"],
		[Rules.SHIFT_QUIRE, "the quire watch"],
		[Rules.SHIFT_SALT, "the salt watch"],
		[Rules.SHIFT_QUAY, "the quay bell"],
		[Rules.SHIFT_FOLIO, "the folio bell"],
	]
	for victory in victories:
		desk._open_shift(int(victory[0]), desk.state.seed)
		desk._refresh_ui()
		desk.state.phase = "victory"
		desk._refresh_ui()
		var victory_wick = _button_named(desk, "Open the wick bell")
		check(victory_wick != null, "%s's victory desk offers the wick bell" % String(victory[1]))
		if victory_wick != null:
			victory_wick.pressed.emit()
			desk._refresh_ui()
			check(desk.state.shift == Rules.SHIFT_WICK and String(Rules.traveler(desk.state)["name"]) == "Odell Voss", "%s's victory desk opens the wick bell" % String(victory[1]))
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_first = _button_named(desk, "Open the first bell")
	check(victory_first != null, "the wick bell victory desk offers the first bell")
	if victory_first != null:
		victory_first.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the wick bell victory desk opens the first bell")
	desk._begin_wick_bell()
	desk._refresh_ui()
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_folio = _button_named(desk, "Open the folio bell")
	check(victory_folio != null, "the wick bell victory desk offers the folio bell")
	if victory_folio != null:
		victory_folio.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_FOLIO and String(Rules.traveler(desk.state)["name"]) == "Ness Hart", "the wick bell victory desk opens the folio bell")
	root.remove_child(desk)
	desk.free()


func test_policy_clears_wick_bell() -> void:
	var started = Time.get_ticks_msec()
	var state = Rules.new_run(12345, Rules.SHIFT_WICK)
	var steps = 0
	var seen = 0
	while state.phase != "victory":
		steps += 1
		if steps > 500 or state.phase == "defeat":
			check(false, "policy lost or stalled on the wick bell, seed 12345: " + Rules.debug_summary(state))
			return
		var action = Policy.choose(state)
		if not Rules.apply_action(state, action):
			check(false, "wick-bell policy action was rejected: %s / %s" % [str(action), Rules.debug_summary(state)])
			return
		if state.encounters_cleared != seen:
			seen = state.encounters_cleared
			print("cleared wick encounter %d after %d actions" % [seen, steps])
	var elapsed = Time.get_ticks_msec() - started
	check(state.encounters_cleared == 4, "policy cleared all 4 wick-bell encounters on seed 12345")
	check(state.phase == "victory", "wick bell ends in victory")
	check(state.shift == Rules.SHIFT_WICK, "the clear stayed on the wick bell")
	print("wick bell finished in %d actions, %d ms" % [steps, elapsed])


func test_margin_bell_rules() -> void:
	var nim = Rules.scripted_encounter(111, 0, ["entry_mark", "entry_mark"], 3, Rules.SHIFT_MARGIN)
	check(String(Rules.traveler(nim)["name"]) == "Nim Voss", "the margin bell's first form is Nim Voss")
	check(String(Rules.traveler(nim)["form_name"]) == "Side Bar", "Nim brings the Side Bar")
	check(String(Rules.traveler(nim)["rule_text"]) == "A stamp scores 0 when it shares a side with an earlier stamp. The earlier stamp scores its own number.", "Nim's form states the later-side rule")
	check(int(Rules.traveler(nim)["lane"]) == 1 and int(Rules.traveler(nim)["exemption_row"]) == 0, "Nim waits in column 2 and exempts the top row")
	check(Rules.preview_progress(nim, "entry_mark", 0, 0) == 2, "preview counts a lone entry mark for Nim")
	check(play_named(nim, "entry_mark", 0, 0), "the first stamp leaves Nim's turn open")
	check(nim.phase == "play", "Nim's first stamp does not end the turn")
	check(Rules.preview_progress(nim, "entry_mark", 0, 1) == 0, "preview zeros a later stamp that shares a side")
	check(Rules.preview_progress(nim, "entry_mark", 1, 1) == 2, "preview counts a corner-only touch")

	var sided = Rules.scripted_encounter(111, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(play_named(sided, "entry_mark", 0, 0), "the earlier stamp")
	check(play_named(sided, "entry_mark", 0, 1), "Nim receives a later side-sharing stamp, the wrong stamp")
	check(sided.last_progress_gained == 2, "the later side-sharing stamp scores 0 and the earlier stamp scores 2 (%d)" % sided.last_progress_gained)
	check(sided.last_patience_loss == 1, "a shared side does not change Nim's patience drop")

	var corner = Rules.scripted_encounter(111, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(play_named(corner, "entry_mark", 0, 0), "one corner of the pair")
	check(play_named(corner, "entry_mark", 1, 1), "Nim receives a corner-only touch, the correct stamp")
	check(corner.last_progress_gained == 4, "a corner-only touch does not zero either stamp (%d)" % corner.last_progress_gained)

	var lone = Rules.scripted_encounter(111, 0, ["duty"], 1, Rules.SHIFT_MARGIN)
	check(play_named(lone, "duty", 2, 0), "Nim receives a lone bottom-row duty")
	check(lone.last_progress_gained == 4, "a lone stamp scores its own number (%d)" % lone.last_progress_gained)
	check(lone.last_patience_loss == 1, "a lone stamp still spends the turn")

	var vertical = Rules.scripted_encounter(111, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(play_named(vertical, "entry_mark", 0, 0), "the upper stamp")
	check(play_named(vertical, "entry_mark", 1, 0), "the stamp directly below it")
	check(vertical.last_progress_gained == 2, "a vertical side zeros only the later stamp (%d)" % vertical.last_progress_gained)

	var row = Rules.scripted_encounter(111, 0, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_MARGIN)
	check(play_named(row, "entry_mark", 0, 0), "the first of three")
	check(play_named(row, "entry_mark", 0, 1), "the second of three")
	check(play_named(row, "entry_mark", 0, 2), "the third of three")
	check(row.last_progress_gained == 2, "the second and third stamps in a row score 0 (%d)" % row.last_progress_gained)

	var pressed = Rules.scripted_encounter(111, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(play_named(pressed, "entry_mark", 0, 1), "the later cell is pressed first")
	check(play_named(pressed, "entry_mark", 0, 0), "the earlier cell is pressed last")
	check(pressed.last_progress_gained == 2, "queue order, not press order, bars Nim's later stamp (%d)" % pressed.last_progress_gained)

	var freed = Rules.scripted_encounter(111, 0, ["exemption", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(play_named(freed, "exemption", 0, 0), "exemption is placed on Nim's top row")
	check(play_named(freed, "entry_mark", 0, 1), "a later side-sharing stamp under that exemption")
	check(freed.last_progress_gained == 3, "exemption on the top row lets the later stamp count (%d)" % freed.last_progress_gained)

	var later_exempt = Rules.scripted_encounter(111, 0, ["entry_mark", "exemption"], 2, Rules.SHIFT_MARGIN)
	check(play_named(later_exempt, "entry_mark", 0, 0), "the earlier stamp")
	check(play_named(later_exempt, "exemption", 0, 1), "exemption is the later stamp on the top row")
	check(later_exempt.last_progress_gained == 3, "an exemption on the top row cancels the bar even when it is later (%d)" % later_exempt.last_progress_gained)

	var still_barred = Rules.scripted_encounter(111, 0, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_MARGIN)
	check(play_named(still_barred, "exemption", 2, 2), "exemption sits off Nim's top row")
	check(play_named(still_barred, "entry_mark", 0, 0), "the earlier stamp")
	check(play_named(still_barred, "entry_mark", 0, 1), "the later side-sharing stamp")
	check(still_barred.last_progress_gained == 3, "an exemption off the top row leaves the later stamp at 0 (%d)" % still_barred.last_progress_gained)

	var nim_echo = Rules.scripted_encounter(111, 0, ["echo", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(play_named(nim_echo, "echo", 0, 0), "echo above a stamp")
	check(play_named(nim_echo, "entry_mark", 1, 0), "the stamp under the echo")
	check(nim_echo.last_chain_count == 1, "the echo still retriggers")
	check(nim_echo.last_progress_gained == 1, "a retrigger of a later side-sharing stamp scores 0 (%d)" % nim_echo.last_progress_gained)

	var nim_reply = Rules.scripted_encounter(111, 0, ["entry_mark", "reply"], 2, Rules.SHIFT_MARGIN)
	check(play_named(nim_reply, "entry_mark", 0, 0), "the earlier stamp")
	check(play_named(nim_reply, "reply", 1, 0), "reply retriggers the earlier stamp")
	check(nim_reply.last_chain_count == 1, "the reply still retriggers the earlier stamp")
	check(nim_reply.last_progress_gained == 4, "a retrigger of the earlier stamp scores its own number (%d)" % nim_reply.last_progress_gained)

	var nim_held = Rules.scripted_encounter(111, 0, ["entry_mark", "hold"], 2, Rules.SHIFT_MARGIN)
	check(play_named(nim_held, "entry_mark", 0, 0), "the earlier stamp")
	check(play_named(nim_held, "hold", 0, 1), "hold in Nim's column shares that side")
	check(nim_held.last_progress_gained == 2, "the later side-sharing hold grants no progress")
	check(nim_held.last_patience_loss == 0 and nim_held.patience == 5, "a barred hold still delays Nim")

	var nim_missed = Rules.scripted_encounter(111, 0, ["entry_mark", "hold"], 2, Rules.SHIFT_MARGIN)
	check(play_named(nim_missed, "entry_mark", 0, 1), "an earlier stamp in Nim's column")
	check(play_named(nim_missed, "hold", 0, 2), "hold outside Nim's column")
	check(nim_missed.last_progress_gained == 2, "the outside hold is still the later side")
	check(nim_missed.last_patience_loss == 1, "hold in another column does not delay Nim")

	var kit = Rules.scripted_encounter(41, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_GUTTER)
	check(String(Rules.traveler(kit)["rule"]) == "ignore_adjacent", "Kit Yarrow still ignores every orthogonal neighbor")
	check(play_named(kit, "entry_mark", 0, 0), "the earlier stamp for Kit")
	check(play_named(kit, "entry_mark", 0, 1), "the later stamp for Kit")
	check(kit.last_progress_gained == 0, "the gutter lamp still zeros both stamps that share a side (%d)" % kit.last_progress_gained)

	var orla = Rules.scripted_encounter(112, 1, ["entry_mark"], 1, Rules.SHIFT_MARGIN)
	check(String(Rules.traveler(orla)["name"]) == "Orla Quill", "the margin bell's second form is Orla Quill")
	check(String(Rules.traveler(orla)["form_name"]) == "Last Toll", "Orla brings the Last Toll")
	check(String(Rules.traveler(orla)["rule_text"]) == "Patience drops by 2 if the last filled cell is in column 3.", "Orla's form states the last-cell toll")
	check(int(Rules.traveler(orla)["lane"]) == 0 and int(Rules.traveler(orla)["exemption_row"]) == 2, "Orla waits in column 1 and exempts the bottom row")
	check(Rules.preview_progress(orla, "duty", 2, 2) == 4, "preview leaves a column-3 duty at its own number")
	check(play_named(orla, "entry_mark", 0, 2), "Orla receives a last cell in column 3, the wrong stamp")
	check(orla.last_progress_gained == 2, "the toll does not change the stamp's score (%d)" % orla.last_progress_gained)
	check(orla.last_patience_loss == 2 and orla.patience == 3, "a last cell in column 3 drops patience by 2")

	var spared = Rules.scripted_encounter(112, 1, ["duty"], 1, Rules.SHIFT_MARGIN)
	check(play_named(spared, "duty", 2, 1), "Orla receives a last cell in column 2, the correct stamp")
	check(spared.last_progress_gained == 4, "a last cell outside column 3 scores its own number (%d)" % spared.last_progress_gained)
	check(spared.last_patience_loss == 1 and spared.patience == 4, "a last cell outside column 3 drops patience by 1")

	var earlier_col3 = Rules.scripted_encounter(112, 1, ["entry_mark", "duty"], 2, Rules.SHIFT_MARGIN)
	check(play_named(earlier_col3, "entry_mark", 0, 2), "an earlier stamp in column 3")
	check(play_named(earlier_col3, "duty", 2, 1), "a later stamp outside column 3")
	check(earlier_col3.last_progress_gained == 6, "the later duty still scores 4 (%d)" % earlier_col3.last_progress_gained)
	check(earlier_col3.last_patience_loss == 1, "an earlier column-3 stamp does not raise the drop")

	var last_corner = Rules.scripted_encounter(112, 1, ["entry_mark", "duty"], 2, Rules.SHIFT_MARGIN)
	check(play_named(last_corner, "duty", 2, 2), "the bottom-right cell is pressed first")
	check(play_named(last_corner, "entry_mark", 0, 0), "an earlier cell is pressed last")
	check(last_corner.last_progress_gained == 6, "queue order, not press order, finds Orla's last cell (%d)" % last_corner.last_progress_gained)
	check(last_corner.last_patience_loss == 2, "the bottom-right cell is still the last cell")

	var empty = Rules.scripted_encounter(112, 1, ["entry_mark"], 3, Rules.SHIFT_MARGIN)
	Rules.end_turn(empty)
	check(empty.last_progress_gained == 0, "an empty form scores nothing")
	check(empty.last_patience_loss == 1, "an empty form has no last cell, so the drop stays 1")

	var orla_held = Rules.scripted_encounter(112, 1, ["hold", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(play_named(orla_held, "hold", 0, 0), "hold in Orla's column")
	check(play_named(orla_held, "entry_mark", 0, 2), "a later last cell in column 3")
	check(orla_held.last_progress_gained == 3, "the held turn still scores the stamps")
	check(orla_held.last_patience_loss == 0 and orla_held.patience == 5, "hold is applied before the last toll")

	var orla_missed = Rules.scripted_encounter(112, 1, ["hold"], 1, Rules.SHIFT_MARGIN)
	check(play_named(orla_missed, "hold", 0, 2), "hold outside Orla's column is the last cell")
	check(orla_missed.last_progress_gained == 1, "the outside hold still scores 1")
	check(orla_missed.last_patience_loss == 2, "hold in another column does not stop the last toll")

	var orla_spared = Rules.scripted_encounter(112, 1, ["exemption", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(play_named(orla_spared, "exemption", 2, 1), "exemption is placed on Orla's bottom row")
	check(play_named(orla_spared, "entry_mark", 2, 2), "the last cell is in column 3")
	check(orla_spared.last_progress_gained == 3, "the exempted stamps still score")
	check(orla_spared.last_patience_loss == 1, "exemption on the bottom row keeps the drop at 1")

	var orla_open = Rules.scripted_encounter(112, 1, ["exemption", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(play_named(orla_open, "exemption", 0, 0), "exemption sits off Orla's bottom row")
	check(play_named(orla_open, "entry_mark", 0, 2), "the last cell is in column 3")
	check(orla_open.last_patience_loss == 2, "an exemption off the bottom row leaves the drop at 2")

	var bram = Rules.scripted_encounter(113, 2, ["duty"], 1, Rules.SHIFT_MARGIN)
	check(String(Rules.traveler(bram)["name"]) == "Bram Hart", "the margin bell's third form is Bram Hart")
	check(String(Rules.traveler(bram)["form_name"]) == "Frame Slip", "Bram brings the Frame Slip")
	check(String(Rules.traveler(bram)["rule_text"]) == "A stamp on the outer frame scores twice when the center is filled. The center scores its own number.", "Bram's form states the frame slip")
	check(int(Rules.traveler(bram)["lane"]) == 2 and int(Rules.traveler(bram)["exemption_row"]) == 0, "Bram waits in column 3 and exempts the top row")
	check(Rules.preview_progress(bram, "duty", 2, 0) == 4, "preview leaves a frame duty at its own number when the center is empty")
	check(play_named(bram, "duty", 2, 0), "Bram receives a lone frame duty, the wrong stamp")
	check(bram.last_progress_gained == 4, "an empty center leaves the frame at its own number (%d)" % bram.last_progress_gained)

	var center_only = Rules.scripted_encounter(113, 2, ["entry_mark"], 1, Rules.SHIFT_MARGIN)
	check(play_named(center_only, "entry_mark", 1, 1), "Bram receives a lone center stamp")
	check(center_only.last_progress_gained == 2, "the center scores its own number (%d)" % center_only.last_progress_gained)

	var framed = Rules.scripted_encounter(113, 2, ["entry_mark", "entry_mark"], 3, Rules.SHIFT_MARGIN)
	check(play_named(framed, "entry_mark", 1, 1), "the center leaves the turn open")
	check(framed.phase == "play", "Bram's first stamp does not end the turn")
	check(Rules.preview_progress(framed, "entry_mark", 0, 0) == 4, "preview doubles a frame stamp once the center is filled")
	check(play_named(framed, "entry_mark", 0, 0), "Bram receives a frame stamp with the center filled, the correct stamp")
	check(framed.last_progress_gained == 6, "the frame scores twice and the center scores 2 (%d)" % framed.last_progress_gained)

	var open_frame = Rules.scripted_encounter(113, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(play_named(open_frame, "entry_mark", 0, 0), "one frame stamp")
	check(play_named(open_frame, "entry_mark", 0, 2), "another frame stamp")
	check(open_frame.last_progress_gained == 4, "frame stamps score their own number when the center is empty (%d)" % open_frame.last_progress_gained)

	var edge = Rules.scripted_encounter(113, 2, ["entry_mark", "duty"], 2, Rules.SHIFT_MARGIN)
	check(play_named(edge, "entry_mark", 1, 1), "the center")
	check(play_named(edge, "duty", 2, 1), "a bottom-edge duty")
	check(edge.last_progress_gained == 10, "the middle of a side scores twice when the center is filled (%d)" % edge.last_progress_gained)

	var bram_muted = Rules.scripted_encounter(113, 2, ["exemption", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(play_named(bram_muted, "exemption", 0, 1), "exemption is placed on Bram's top row")
	check(play_named(bram_muted, "entry_mark", 1, 1), "the center under that exemption")
	check(bram_muted.last_progress_gained == 3, "exemption on the top row cancels the doubling (%d)" % bram_muted.last_progress_gained)

	var bram_kept = Rules.scripted_encounter(113, 2, ["exemption", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(play_named(bram_kept, "exemption", 2, 0), "exemption sits off Bram's top row")
	check(play_named(bram_kept, "entry_mark", 1, 1), "the center")
	check(bram_kept.last_progress_gained == 4, "an exemption off the top row still doubles the frame (%d)" % bram_kept.last_progress_gained)

	var bram_center = Rules.scripted_encounter(113, 2, ["exemption", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(play_named(bram_center, "exemption", 1, 1), "exemption is the center")
	check(play_named(bram_center, "entry_mark", 0, 0), "a frame stamp")
	check(bram_center.last_progress_gained == 5, "an exemption in the center does not cancel the frame (%d)" % bram_center.last_progress_gained)

	var bram_echo = Rules.scripted_encounter(113, 2, ["echo", "entry_mark", "entry_mark"], 3, Rules.SHIFT_MARGIN)
	check(play_named(bram_echo, "echo", 0, 0), "echo on the frame")
	check(play_named(bram_echo, "entry_mark", 1, 0), "the stamp under the echo")
	check(play_named(bram_echo, "entry_mark", 1, 1), "the center")
	check(bram_echo.last_chain_count == 1, "the echo still retriggers")
	check(bram_echo.last_progress_gained == 12, "a retrigger of a frame stamp scores twice again (%d)" % bram_echo.last_progress_gained)

	var bram_reply = Rules.scripted_encounter(113, 2, ["entry_mark", "reply"], 2, Rules.SHIFT_MARGIN)
	check(play_named(bram_reply, "entry_mark", 1, 1), "the center")
	check(play_named(bram_reply, "reply", 2, 1), "reply retriggers the center")
	check(bram_reply.last_chain_count == 1, "the reply still retriggers the center")
	check(bram_reply.last_progress_gained == 6, "a retrigger of the center scores its own number (%d)" % bram_reply.last_progress_gained)

	var bram_open_echo = Rules.scripted_encounter(113, 2, ["echo", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(play_named(bram_open_echo, "echo", 0, 0), "echo with an empty center")
	check(play_named(bram_open_echo, "entry_mark", 1, 0), "the stamp under the echo")
	check(bram_open_echo.last_chain_count == 1, "the echo still retriggers when the center is empty")
	check(bram_open_echo.last_progress_gained == 5, "an empty center does not double the retrigger (%d)" % bram_open_echo.last_progress_gained)

	var bram_held = Rules.scripted_encounter(113, 2, ["hold", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(play_named(bram_held, "hold", 0, 2), "hold in Bram's column")
	check(play_named(bram_held, "entry_mark", 1, 1), "the center")
	check(bram_held.last_progress_gained == 4, "the held frame stamp still scores twice")
	check(bram_held.last_patience_loss == 0 and bram_held.patience == 5, "hold delays Bram")

	var sable = Rules.scripted_encounter(114, 3, ["entry_mark", "entry_mark"], 3, Rules.SHIFT_MARGIN)
	check(String(Rules.traveler(sable)["name"]) == "Sable Solt", "the margin bell's fourth form is Sable Solt")
	check(String(Rules.traveler(sable)["form_name"]) == "Gap Yield", "Sable brings the Gap Yield")
	check(String(Rules.traveler(sable)["rule_text"]) == "If two filled stamps have an empty cell between them, each of those stamps scores +2. Stamps that are not part of a gap score their own number.", "Sable's form states the gap yield")
	check(int(Rules.traveler(sable)["lane"]) == 1 and int(Rules.traveler(sable)["exemption_row"]) == 2, "Sable waits in column 2 and exempts the bottom row")
	check(Rules.preview_progress(sable, "entry_mark", 0, 0) == 2, "preview leaves a lone entry mark at its own number")
	check(play_named(sable, "entry_mark", 0, 0), "the first stamp leaves Sable's turn open")
	check(sable.phase == "play", "Sable's first stamp does not end the turn")
	check(Rules.preview_progress(sable, "entry_mark", 0, 1) == 2, "preview leaves a contiguous stamp at its own number")
	check(Rules.preview_progress(sable, "entry_mark", 0, 2) == 4, "preview adds 2 across a queue gap")

	var together = Rules.scripted_encounter(114, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(play_named(together, "entry_mark", 0, 0), "the first of a block")
	check(play_named(together, "entry_mark", 0, 1), "Sable receives a contiguous stamp, the wrong stamp")
	check(together.last_progress_gained == 4, "stamps that are not part of a gap score their own number (%d)" % together.last_progress_gained)
	check(together.last_patience_loss == 1, "a contiguous block drops patience by 1")

	var gapped = Rules.scripted_encounter(114, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(play_named(gapped, "entry_mark", 0, 0), "the stamp before the gap")
	check(play_named(gapped, "entry_mark", 0, 2), "Sable receives a stamp after the gap, the correct stamp")
	check(gapped.last_progress_gained == 8, "each stamp beside the gap scores +2 (%d)" % gapped.last_progress_gained)
	check(gapped.last_patience_loss == 1 and gapped.patience == 4, "the gap yield does not change patience")

	var spread = Rules.scripted_encounter(114, 3, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_MARGIN)
	check(play_named(spread, "entry_mark", 0, 0), "a stamp beside its neighbor")
	check(play_named(spread, "entry_mark", 0, 1), "the neighbor")
	check(play_named(spread, "entry_mark", 2, 2), "a later stamp after an empty cell")
	check(spread.last_progress_gained == 12, "every filled stamp in the gap scores +2 once (%d)" % spread.last_progress_gained)

	var diagonal = Rules.scripted_encounter(114, 3, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_MARGIN)
	check(play_named(diagonal, "entry_mark", 0, 0), "the first diagonal stamp")
	check(play_named(diagonal, "entry_mark", 1, 1), "the middle diagonal stamp")
	check(play_named(diagonal, "entry_mark", 2, 2), "the last diagonal stamp")
	check(diagonal.last_progress_gained == 12, "a stamp in two gap pairs still scores +2 once (%d)" % diagonal.last_progress_gained)

	var wrapped = Rules.scripted_encounter(114, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(play_named(wrapped, "entry_mark", 0, 2), "the last cell of the top row")
	check(play_named(wrapped, "entry_mark", 1, 0), "the first cell of the middle row")
	check(wrapped.last_progress_gained == 4, "stamps that follow across a row are not a gap (%d)" % wrapped.last_progress_gained)

	var wrapped_gap = Rules.scripted_encounter(114, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(play_named(wrapped_gap, "entry_mark", 0, 2), "the last cell of the top row")
	check(play_named(wrapped_gap, "entry_mark", 1, 1), "a later cell with an empty between")
	check(wrapped_gap.last_progress_gained == 8, "an empty cell across the row break is a gap (%d)" % wrapped_gap.last_progress_gained)

	var lone_sable = Rules.scripted_encounter(114, 3, ["entry_mark"], 1, Rules.SHIFT_MARGIN)
	check(play_named(lone_sable, "entry_mark", 1, 1), "Sable receives a lone stamp")
	check(lone_sable.last_progress_gained == 2, "a lone stamp scores its own number (%d)" % lone_sable.last_progress_gained)

	var sable_muted = Rules.scripted_encounter(114, 3, ["entry_mark", "entry_mark", "exemption"], 3, Rules.SHIFT_MARGIN)
	check(play_named(sable_muted, "entry_mark", 0, 0), "the stamp before the gap")
	check(play_named(sable_muted, "entry_mark", 0, 2), "the stamp after the gap")
	check(play_named(sable_muted, "exemption", 2, 0), "exemption is placed on Sable's bottom row")
	check(sable_muted.last_progress_gained == 5, "exemption on the bottom row cancels the bonus (%d)" % sable_muted.last_progress_gained)

	var sable_kept = Rules.scripted_encounter(114, 3, ["entry_mark", "exemption", "entry_mark"], 3, Rules.SHIFT_MARGIN)
	check(play_named(sable_kept, "entry_mark", 0, 0), "the first stamp")
	check(play_named(sable_kept, "exemption", 0, 1), "exemption sits off Sable's bottom row")
	check(play_named(sable_kept, "entry_mark", 2, 2), "a stamp after the gap")
	check(sable_kept.last_progress_gained == 11, "an exemption off the bottom row leaves the gap bonus (%d)" % sable_kept.last_progress_gained)

	var sable_echo = Rules.scripted_encounter(114, 3, ["echo", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(play_named(sable_echo, "echo", 0, 0), "echo before a gap")
	check(play_named(sable_echo, "entry_mark", 1, 0), "the stamp under the echo")
	check(sable_echo.last_chain_count == 1, "the echo still retriggers")
	check(sable_echo.last_progress_gained == 11, "a retrigger adds the gap bonus again (%d)" % sable_echo.last_progress_gained)

	var sable_block = Rules.scripted_encounter(114, 3, ["echo", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_MARGIN)
	check(play_named(sable_block, "echo", 0, 0), "echo at the start of a block")
	check(play_named(sable_block, "entry_mark", 0, 1), "the next cell")
	check(play_named(sable_block, "entry_mark", 0, 2), "the end of the top row")
	check(play_named(sable_block, "entry_mark", 1, 0), "the first cell of the next row")
	check(sable_block.last_chain_count == 1, "the echo still retriggers inside a block")
	check(sable_block.last_progress_gained == 9, "a retrigger with no gap does not add the bonus (%d)" % sable_block.last_progress_gained)

	var sable_held = Rules.scripted_encounter(114, 3, ["entry_mark", "hold"], 2, Rules.SHIFT_MARGIN)
	check(play_named(sable_held, "entry_mark", 0, 0), "a stamp before the gap")
	check(play_named(sable_held, "hold", 1, 1), "hold in Sable's column after the gap")
	check(sable_held.last_progress_gained == 7, "the held stamp still gains the gap bonus")
	check(sable_held.last_patience_loss == 0 and sable_held.patience == 5, "hold delays Sable")

	var pell = Rules.scripted_encounter(91, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(String(Rules.traveler(pell)["rule"]) == "drop_if_queue_gap", "Pell Sallow still tolls patience for a gap")
	check(play_named(pell, "entry_mark", 0, 0), "the stamp before Pell's gap")
	check(play_named(pell, "entry_mark", 0, 2), "the stamp after Pell's gap")
	check(pell.last_progress_gained == 4, "the folio bell still does not add the gap to the score (%d)" % pell.last_progress_gained)
	check(pell.last_patience_loss == 2, "the folio bell still drops patience by 2 for a gap")


func test_margin_bell_opens() -> void:
	check(Rules.MARGIN_BELL.size() == 4, "the margin bell has four travelers")
	check(String(Rules.MARGIN_BELL[0]["name"]) == "Nim Voss", "the margin bell begins with Nim Voss")
	check(String(Rules.MARGIN_BELL[1]["name"]) == "Orla Quill", "the margin bell's second traveler is Orla Quill")
	check(String(Rules.MARGIN_BELL[2]["name"]) == "Bram Hart", "the margin bell's third traveler is Bram Hart")
	check(String(Rules.MARGIN_BELL[3]["name"]) == "Sable Solt", "the margin bell ends with Sable Solt")
	check(Rules.WICK_BELL.size() == 4 and String(Rules.WICK_BELL[0]["name"]) == "Odell Voss", "the wick bell still begins with Odell Voss")
	check(String(Rules.WICK_BELL[3]["name"]) == "Ives Mire", "the wick bell still ends with Ives Mire")
	check(Rules.TRAVELERS.size() == 4 and String(Rules.TRAVELERS[0]["name"]) == "Ada Quill", "Act 1 still begins with Ada Quill")
	var margin = Rules.new_run(79, Rules.SHIFT_MARGIN)
	check(margin.shift == Rules.SHIFT_MARGIN, "the margin bell is a separate night")
	check(String(Rules.traveler(margin)["name"]) == "Nim Voss", "the margin bell begins with Nim Voss")
	check(margin.hand.size() == Rules.HAND_SIZE, "the margin bell draws 5")
	check(margin.ink == Rules.BASE_INK, "the margin bell starts at 3 ink")
	check(margin.library.size() == Rules.STARTING_DECK.size(), "the margin bell deals the starting deck")
	check(margin.relic_id == "", "an earlier night's relic does not carry")
	check(margin.phase == "play", "the margin bell opens in play")
	var dealt: Array = []
	for iid in margin.hand:
		dealt.append(Rules.card_id_of(margin, int(iid)))
	var before = margin.library.size()
	margin.progress = 4
	margin.patience = 1
	Rules.restart_encounter(margin)
	check(margin.shift == Rules.SHIFT_MARGIN and margin.traveler_index == 0, "restart encounter stays on the margin bell")
	check(margin.progress == 0 and margin.patience == int(Rules.MARGIN_BELL[0]["patience"]), "restart encounter resets Nim")
	check(margin.library.size() == before and margin.hand.size() == 5 and margin.phase == "play", "restart keeps the margin-bell deck and deals a hand")
	var redealt: Array = []
	for iid in margin.hand:
		redealt.append(Rules.card_id_of(margin, int(iid)))
	check(redealt == dealt, "restart deals Nim the same hand")

	var packed = load("res://game/main.tscn")
	var desk = packed.instantiate()
	root.add_child(desk)
	if desk.state == null:
		desk._ready()
	check(desk.state.shift == Rules.SHIFT_FIRST, "the desk still opens on Act 1")
	check(desk.margin_button.text == "Margin bell", "the desk offers the margin bell")
	check(desk.wick_button.text == "Wick bell", "the desk still offers the wick bell")
	desk.margin_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_MARGIN, "the desk can open the margin bell")
	check(String(Rules.traveler(desk.state)["name"]) == "Nim Voss", "the open desk shows Nim")
	check(String(desk.desk_label.text).begins_with("Margin bell"), "the desk title follows the margin bell")
	check(desk.meta_label.text.contains("Side Bar"), "the desk shows Nim's form")
	check(desk.margin_button.text == "First bell", "the margin bell can return to the first bell")
	check(desk.wick_button.text == "Wick bell", "the wick bell stays available from the margin bell")
	check(desk.shift_button.text == "Late shift", "the late shift stays available from the margin bell")
	desk._restart_act()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_MARGIN and String(Rules.traveler(desk.state)["name"]) == "Nim Voss", "restart act replays the margin bell")
	desk.margin_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the margin bell returns to Ada")
	var doors = [
		["_begin_late_shift", "Nell Parr", "the late shift"],
		["_begin_closing_bell", "Moss Quen", "the closing bell"],
		["_begin_ash_watch", "Orla Fen", "the ash watch"],
		["_begin_gutter_lamp", "Ivo Dane", "the gutter lamp"],
		["_begin_vellum_bell", "Edda Voss", "the vellum bell"],
		["_begin_quire_watch", "Tess Quern", "the quire watch"],
		["_begin_salt_watch", "Pell Voss", "the salt watch"],
		["_begin_quay_bell", "Mara Quill", "the quay bell"],
		["_begin_folio_bell", "Ness Hart", "the folio bell"],
		["_begin_wick_bell", "Odell Voss", "the wick bell"],
	]
	for door in doors:
		desk.call(String(door[0]))
		desk._refresh_ui()
		check(desk.state.shift != Rules.SHIFT_MARGIN and String(Rules.traveler(desk.state)["name"]) == String(door[1]), "%s still opens" % String(door[2]))
		check(desk.margin_button.text == "Margin bell", "%s offers the margin bell" % String(door[2]))
		desk._begin_margin_bell()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_MARGIN and String(Rules.traveler(desk.state)["name"]) == "Nim Voss", "%s can open the margin bell" % String(door[2]))
	desk._begin_first_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "first bell still returns to Ada")
	var victories = [
		[Rules.SHIFT_FIRST, "Act 1"],
		[Rules.SHIFT_LATE, "the late shift"],
		[Rules.SHIFT_CLOSING, "the closing bell"],
		[Rules.SHIFT_ASH, "the ash watch"],
		[Rules.SHIFT_GUTTER, "the gutter lamp"],
		[Rules.SHIFT_VELLUM, "the vellum bell"],
		[Rules.SHIFT_QUIRE, "the quire watch"],
		[Rules.SHIFT_SALT, "the salt watch"],
		[Rules.SHIFT_QUAY, "the quay bell"],
		[Rules.SHIFT_FOLIO, "the folio bell"],
		[Rules.SHIFT_WICK, "the wick bell"],
	]
	for victory in victories:
		desk._open_shift(int(victory[0]), desk.state.seed)
		desk._refresh_ui()
		desk.state.phase = "victory"
		desk._refresh_ui()
		var victory_margin = _button_named(desk, "Open the margin bell")
		check(victory_margin != null, "%s's victory desk offers the margin bell" % String(victory[1]))
		if victory_margin != null:
			victory_margin.pressed.emit()
			desk._refresh_ui()
			check(desk.state.shift == Rules.SHIFT_MARGIN and String(Rules.traveler(desk.state)["name"]) == "Nim Voss", "%s's victory desk opens the margin bell" % String(victory[1]))
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_first = _button_named(desk, "Open the first bell")
	check(victory_first != null, "the margin bell victory desk offers the first bell")
	if victory_first != null:
		victory_first.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the margin bell victory desk opens the first bell")
	desk._begin_margin_bell()
	desk._refresh_ui()
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_wick = _button_named(desk, "Open the wick bell")
	check(victory_wick != null, "the margin bell victory desk offers the wick bell")
	if victory_wick != null:
		victory_wick.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_WICK and String(Rules.traveler(desk.state)["name"]) == "Odell Voss", "the margin bell victory desk opens the wick bell")
	root.remove_child(desk)
	desk.free()


func test_policy_clears_margin_bell() -> void:
	var started = Time.get_ticks_msec()
	var state = Rules.new_run(12345, Rules.SHIFT_MARGIN)
	var steps = 0
	var seen = 0
	while state.phase != "victory":
		steps += 1
		if steps > 500 or state.phase == "defeat":
			check(false, "policy lost or stalled on the margin bell, seed 12345: " + Rules.debug_summary(state))
			return
		var action = Policy.choose(state)
		if not Rules.apply_action(state, action):
			check(false, "margin-bell policy action was rejected: %s / %s" % [str(action), Rules.debug_summary(state)])
			return
		if state.encounters_cleared != seen:
			seen = state.encounters_cleared
			print("cleared margin encounter %d after %d actions" % [seen, steps])
	var elapsed = Time.get_ticks_msec() - started
	check(state.encounters_cleared == 4, "policy cleared all 4 margin-bell encounters on seed 12345")
	check(state.phase == "victory", "margin bell ends in victory")
	check(state.shift == Rules.SHIFT_MARGIN, "the clear stayed on the margin bell")
	print("margin bell finished in %d actions, %d ms" % [steps, elapsed])


func test_index_bell_rules() -> void:
	var len = Rules.scripted_encounter(121, 0, ["entry_mark", "entry_mark"], 3, Rules.SHIFT_INDEX)
	check(String(Rules.traveler(len)["name"]) == "Len Quill", "the index bell's first form is Len Quill")
	check(String(Rules.traveler(len)["form_name"]) == "Corner Bar", "Len brings the Corner Bar")
	check(String(Rules.traveler(len)["rule_text"]) == "A stamp scores 0 only when it touches an earlier stamp at a corner and does not share a side with that same earlier stamp.", "Len's form states the corner bar")
	check(int(Rules.traveler(len)["lane"]) == 0 and int(Rules.traveler(len)["exemption_row"]) == 0, "Len waits in column 1 and exempts the top row")
	check(int(Rules.traveler(len)["goal"]) == 18, "Len's goal is 18")
	check(Rules.preview_progress(len, "entry_mark", 0, 0) == 2, "preview counts a lone entry mark for Len")
	check(play_named(len, "entry_mark", 0, 0), "the first stamp leaves Len's turn open")
	check(len.phase == "play", "Len's first stamp does not end the turn")
	check(Rules.preview_progress(len, "entry_mark", 0, 1) == 2, "preview counts a later stamp that only shares a side")
	check(Rules.preview_progress(len, "entry_mark", 1, 1) == 0, "preview zeros a later stamp that touches at a corner")

	var sided = Rules.scripted_encounter(121, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(sided, "entry_mark", 0, 0), "the earlier stamp")
	check(play_named(sided, "entry_mark", 0, 1), "Len receives a side-sharing stamp, the correct stamp")
	check(sided.last_progress_gained == 4, "a stamp that only shares a side scores its own number (%d)" % sided.last_progress_gained)
	check(sided.last_patience_loss == 1, "a shared side does not change Len's patience drop")

	var corner = Rules.scripted_encounter(121, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(corner, "entry_mark", 0, 0), "one corner of the pair")
	check(play_named(corner, "entry_mark", 1, 1), "Len receives a corner touch, the wrong stamp")
	check(corner.last_progress_gained == 2, "the later corner stamp scores 0 and the earlier stamp scores 2 (%d)" % corner.last_progress_gained)
	check(corner.last_patience_loss == 1, "a corner bar does not change patience")

	var other_corner = Rules.scripted_encounter(121, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(other_corner, "entry_mark", 0, 1), "the earlier stamp")
	check(play_named(other_corner, "entry_mark", 1, 0), "the later stamp on the other diagonal")
	check(other_corner.last_progress_gained == 2, "the other diagonal still zeros only the later stamp (%d)" % other_corner.last_progress_gained)

	var vertical = Rules.scripted_encounter(121, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(vertical, "entry_mark", 0, 0), "the upper stamp")
	check(play_named(vertical, "entry_mark", 1, 0), "the stamp directly below it")
	check(vertical.last_progress_gained == 4, "a vertical side does not zero either stamp (%d)" % vertical.last_progress_gained)

	var longer = Rules.scripted_encounter(121, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(longer, "entry_mark", 0, 0), "the first of a longer diagonal")
	check(play_named(longer, "entry_mark", 2, 2), "the stamp two cells away")
	check(longer.last_progress_gained == 4, "a longer diagonal does not bar either stamp (%d)" % longer.last_progress_gained)

	var knight = Rules.scripted_encounter(121, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(knight, "entry_mark", 0, 0), "the first of a wide step")
	check(play_named(knight, "entry_mark", 1, 2), "a stamp one row and two columns away")
	check(knight.last_progress_gained == 4, "a gap of two columns is not a corner (%d)" % knight.last_progress_gained)

	var lone = Rules.scripted_encounter(121, 0, ["duty"], 1, Rules.SHIFT_INDEX)
	check(play_named(lone, "duty", 2, 0), "Len receives a lone bottom-row duty")
	check(lone.last_progress_gained == 4, "a lone stamp scores its own number (%d)" % lone.last_progress_gained)
	check(lone.last_patience_loss == 1, "a lone stamp still spends the turn")

	var mixed = Rules.scripted_encounter(121, 0, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_INDEX)
	check(play_named(mixed, "entry_mark", 0, 0), "the earlier stamp of the side")
	check(play_named(mixed, "entry_mark", 0, 1), "the stamp that only shares that side")
	check(play_named(mixed, "entry_mark", 1, 0), "a later stamp that corners a different earlier stamp")
	check(mixed.last_progress_gained == 4, "a side shared with one stamp does not save a corner with another (%d)" % mixed.last_progress_gained)

	var pressed = Rules.scripted_encounter(121, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(pressed, "entry_mark", 1, 1), "the later cell is pressed first")
	check(play_named(pressed, "entry_mark", 0, 0), "the earlier cell is pressed last")
	check(pressed.last_progress_gained == 2, "queue order, not press order, bars Len's later stamp (%d)" % pressed.last_progress_gained)

	var freed = Rules.scripted_encounter(121, 0, ["exemption", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(freed, "exemption", 0, 0), "exemption is placed on Len's top row")
	check(play_named(freed, "entry_mark", 1, 1), "a later corner stamp under that exemption")
	check(freed.last_progress_gained == 3, "exemption on the top row lets the later stamp count (%d)" % freed.last_progress_gained)

	var later_exempt = Rules.scripted_encounter(121, 0, ["entry_mark", "exemption", "entry_mark"], 3, Rules.SHIFT_INDEX)
	check(play_named(later_exempt, "entry_mark", 0, 1), "the earlier stamp")
	check(play_named(later_exempt, "exemption", 0, 2), "exemption is later on the top row")
	check(play_named(later_exempt, "entry_mark", 1, 0), "the corner stamp")
	check(later_exempt.last_progress_gained == 5, "an exemption on the top row cancels the bar even when it is not the corner stamp (%d)" % later_exempt.last_progress_gained)

	var still_barred = Rules.scripted_encounter(121, 0, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_INDEX)
	check(play_named(still_barred, "exemption", 2, 0), "exemption sits off Len's top row")
	check(play_named(still_barred, "entry_mark", 0, 1), "the earlier stamp")
	check(play_named(still_barred, "entry_mark", 1, 2), "the later corner stamp")
	check(still_barred.last_progress_gained == 3, "an exemption off the top row leaves the later stamp at 0 (%d)" % still_barred.last_progress_gained)

	var len_echo = Rules.scripted_encounter(121, 0, ["entry_mark", "echo", "entry_mark"], 3, Rules.SHIFT_INDEX)
	check(play_named(len_echo, "entry_mark", 0, 0), "the earlier stamp")
	check(play_named(len_echo, "echo", 0, 1), "echo beside that stamp")
	check(play_named(len_echo, "entry_mark", 1, 1), "the stamp under the echo")
	check(len_echo.last_chain_count == 1, "the echo still retriggers")
	check(len_echo.last_progress_gained == 3, "a retrigger of a later corner stamp scores 0 (%d)" % len_echo.last_progress_gained)

	var len_reply = Rules.scripted_encounter(121, 0, ["entry_mark", "reply"], 2, Rules.SHIFT_INDEX)
	check(play_named(len_reply, "entry_mark", 0, 0), "the earlier stamp")
	check(play_named(len_reply, "reply", 1, 0), "reply shares a side and retriggers the earlier stamp")
	check(len_reply.last_chain_count == 1, "the reply still retriggers the earlier stamp")
	check(len_reply.last_progress_gained == 5, "a side-sharing retrigger scores its own number (%d)" % len_reply.last_progress_gained)

	var len_held = Rules.scripted_encounter(121, 0, ["entry_mark", "hold"], 2, Rules.SHIFT_INDEX)
	check(play_named(len_held, "entry_mark", 0, 1), "the earlier stamp")
	check(play_named(len_held, "hold", 1, 0), "hold in Len's column touches that stamp at a corner")
	check(len_held.last_progress_gained == 2, "the later corner hold grants no progress")
	check(len_held.last_patience_loss == 0 and len_held.patience == 5, "a barred hold still delays Len")

	var len_side_hold = Rules.scripted_encounter(121, 0, ["entry_mark", "hold"], 2, Rules.SHIFT_INDEX)
	check(play_named(len_side_hold, "entry_mark", 0, 0), "the earlier stamp")
	check(play_named(len_side_hold, "hold", 1, 0), "hold in Len's column only shares a side")
	check(len_side_hold.last_progress_gained == 3, "a side-sharing hold still scores 1")
	check(len_side_hold.last_patience_loss == 0, "hold in column 1 delays Len")

	var len_missed = Rules.scripted_encounter(121, 0, ["entry_mark", "hold"], 2, Rules.SHIFT_INDEX)
	check(play_named(len_missed, "entry_mark", 0, 0), "the earlier stamp")
	check(play_named(len_missed, "hold", 1, 1), "hold outside Len's column touches at a corner")
	check(len_missed.last_progress_gained == 2, "the outside corner hold grants no progress")
	check(len_missed.last_patience_loss == 1, "hold in another column does not delay Len")

	var nim = Rules.scripted_encounter(111, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(String(Rules.traveler(nim)["rule"]) == "zero_side_later", "Nim Voss still bars a later side")
	check(play_named(nim, "entry_mark", 0, 0), "the earlier stamp for Nim")
	check(play_named(nim, "entry_mark", 0, 1), "the later side for Nim")
	check(nim.last_progress_gained == 2, "the margin bell still zeros the later side and not the corner rule (%d)" % nim.last_progress_gained)

	var kit = Rules.scripted_encounter(41, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_GUTTER)
	check(String(Rules.traveler(kit)["rule"]) == "ignore_adjacent", "Kit Yarrow still ignores every orthogonal neighbor")
	check(play_named(kit, "entry_mark", 0, 0), "the earlier stamp for Kit")
	check(play_named(kit, "entry_mark", 0, 1), "the later stamp for Kit")
	check(kit.last_progress_gained == 0, "the gutter lamp still zeros both stamps that share a side (%d)" % kit.last_progress_gained)

	var ada = Rules.scripted_encounter(122, 1, ["entry_mark"], 1, Rules.SHIFT_INDEX)
	check(String(Rules.traveler(ada)["name"]) == "Ada Pell", "the index bell's second form is Ada Pell")
	check(String(Rules.traveler(ada)["form_name"]) == "First Toll", "Ada brings the First Toll")
	check(String(Rules.traveler(ada)["rule_text"]) == "Patience drops by 2 when the first filled cell is in column 1.", "Ada's form states the first-cell toll")
	check(int(Rules.traveler(ada)["lane"]) == 2 and int(Rules.traveler(ada)["exemption_row"]) == 2, "Ada waits in column 3 and exempts the bottom row")
	check(int(Rules.traveler(ada)["goal"]) == 16, "Ada's goal is 16")
	check(Rules.preview_progress(ada, "duty", 2, 0) == 4, "preview leaves a column-1 duty at its own number")
	check(play_named(ada, "entry_mark", 0, 0), "Ada receives a first cell in column 1, the wrong stamp")
	check(ada.last_progress_gained == 2, "the toll does not change the stamp's score (%d)" % ada.last_progress_gained)
	check(ada.last_patience_loss == 2 and ada.patience == 3, "a first cell in column 1 drops patience by 2")

	var spared = Rules.scripted_encounter(122, 1, ["duty"], 1, Rules.SHIFT_INDEX)
	check(play_named(spared, "duty", 2, 1), "Ada receives a first cell in column 2, the correct stamp")
	check(spared.last_progress_gained == 4, "a first cell in column 2 scores its own number (%d)" % spared.last_progress_gained)
	check(spared.last_patience_loss == 1 and spared.patience == 4, "a first cell in column 2 drops patience by 1")

	var column_three = Rules.scripted_encounter(122, 1, ["entry_mark"], 1, Rules.SHIFT_INDEX)
	check(play_named(column_three, "entry_mark", 0, 2), "Ada receives a first cell in column 3")
	check(column_three.last_progress_gained == 2, "a first cell in column 3 scores its own number (%d)" % column_three.last_progress_gained)
	check(column_three.last_patience_loss == 1, "a first cell in column 3 drops patience by 1")

	var later_col1 = Rules.scripted_encounter(122, 1, ["entry_mark", "duty"], 2, Rules.SHIFT_INDEX)
	check(play_named(later_col1, "entry_mark", 0, 1), "a first stamp outside column 1")
	check(play_named(later_col1, "duty", 2, 0), "a later stamp in column 1")
	check(later_col1.last_progress_gained == 6, "the later duty still scores 4 (%d)" % later_col1.last_progress_gained)
	check(later_col1.last_patience_loss == 1, "a later column-1 stamp does not raise the drop")

	var first_col1 = Rules.scripted_encounter(122, 1, ["entry_mark", "duty"], 2, Rules.SHIFT_INDEX)
	check(play_named(first_col1, "entry_mark", 0, 0), "the first cell is in column 1")
	check(play_named(first_col1, "duty", 2, 1), "a later stamp outside column 1")
	check(first_col1.last_progress_gained == 6, "both stamps still score (%d)" % first_col1.last_progress_gained)
	check(first_col1.last_patience_loss == 2, "the first cell in column 1 still drops patience by 2")

	var pressed_ada = Rules.scripted_encounter(122, 1, ["duty", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(pressed_ada, "duty", 2, 0), "the later cell is pressed first")
	check(play_named(pressed_ada, "entry_mark", 0, 1), "an earlier cell in column 2 is pressed last")
	check(pressed_ada.last_progress_gained == 6, "queue order, not press order, finds Ada's first cell (%d)" % pressed_ada.last_progress_gained)
	check(pressed_ada.last_patience_loss == 1, "the column-2 cell is the first cell")

	var pressed_toll = Rules.scripted_encounter(122, 1, ["duty", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(pressed_toll, "duty", 2, 2), "the bottom-right cell is pressed first")
	check(play_named(pressed_toll, "entry_mark", 0, 0), "an earlier cell in column 1 is pressed last")
	check(pressed_toll.last_patience_loss == 2, "the column-1 cell is still the first cell")

	var empty = Rules.scripted_encounter(122, 1, ["entry_mark"], 3, Rules.SHIFT_INDEX)
	Rules.end_turn(empty)
	check(empty.last_progress_gained == 0, "an empty form scores nothing")
	check(empty.last_patience_loss == 1, "an empty form has no first cell, so the drop stays 1")

	var ada_held = Rules.scripted_encounter(122, 1, ["hold", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(ada_held, "entry_mark", 0, 0), "a first cell in column 1")
	check(play_named(ada_held, "hold", 1, 2), "hold in Ada's column")
	check(ada_held.last_progress_gained == 3, "the held turn still scores the stamps")
	check(ada_held.last_patience_loss == 0 and ada_held.patience == 5, "hold is applied before the first toll")

	var ada_missed = Rules.scripted_encounter(122, 1, ["hold", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(ada_missed, "entry_mark", 0, 0), "a first cell in column 1")
	check(play_named(ada_missed, "hold", 0, 1), "hold outside Ada's column")
	check(ada_missed.last_progress_gained == 3, "the outside hold still scores 1")
	check(ada_missed.last_patience_loss == 2, "hold in another column does not stop the first toll")

	var ada_spared = Rules.scripted_encounter(122, 1, ["exemption", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(ada_spared, "entry_mark", 0, 0), "a first cell in column 1")
	check(play_named(ada_spared, "exemption", 2, 1), "exemption is placed on Ada's bottom row")
	check(ada_spared.last_progress_gained == 3, "the exempted stamps still score")
	check(ada_spared.last_patience_loss == 1, "exemption on the bottom row keeps the drop at 1")

	var ada_open = Rules.scripted_encounter(122, 1, ["exemption", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(ada_open, "entry_mark", 0, 0), "a first cell in column 1")
	check(play_named(ada_open, "exemption", 1, 1), "exemption sits off Ada's bottom row")
	check(ada_open.last_patience_loss == 2, "an exemption off the bottom row leaves the drop at 2")

	var orla = Rules.scripted_encounter(112, 1, ["entry_mark"], 1, Rules.SHIFT_MARGIN)
	check(String(Rules.traveler(orla)["rule"]) == "double_patience_if_last_col3", "Orla Quill still tolls the last cell")
	check(play_named(orla, "entry_mark", 0, 2), "Orla receives a last cell in column 3")
	check(orla.last_patience_loss == 2, "the margin bell still drops patience by 2 for a last cell in column 3")
	check(orla.last_progress_gained == 2, "Orla still leaves the score unchanged (%d)" % orla.last_progress_gained)

	var wynn = Rules.scripted_encounter(123, 2, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_INDEX)
	check(String(Rules.traveler(wynn)["name"]) == "Wynn Hart", "the index bell's third form is Wynn Hart")
	check(String(Rules.traveler(wynn)["form_name"]) == "Full Row", "Wynn brings the Full Row")
	check(String(Rules.traveler(wynn)["rule_text"]) == "A stamp scores twice only when its own row is full. A stamp in a row that is not full scores its own number.", "Wynn's form states the full row")
	check(int(Rules.traveler(wynn)["lane"]) == 1 and int(Rules.traveler(wynn)["exemption_row"]) == 0, "Wynn waits in column 2 and exempts the top row")
	check(int(Rules.traveler(wynn)["goal"]) == 24, "Wynn's goal is 24")
	check(Rules.preview_progress(wynn, "duty", 2, 0) == 4, "preview leaves a lone duty at its own number")
	check(play_named(wynn, "entry_mark", 0, 0), "the first stamp leaves Wynn's turn open")
	check(wynn.phase == "play", "Wynn's first stamp does not end the turn")
	check(Rules.preview_progress(wynn, "entry_mark", 0, 1) == 2, "preview leaves a pair at its own number")
	check(play_named(wynn, "entry_mark", 0, 1), "the second stamp of the row")
	check(Rules.preview_progress(wynn, "entry_mark", 0, 2) == 4, "preview doubles the stamp that fills the row")
	check(play_named(wynn, "entry_mark", 0, 2), "Wynn receives a full row, the correct stamp")
	check(wynn.last_progress_gained == 12, "each stamp in a full row scores twice (%d)" % wynn.last_progress_gained)
	check(wynn.last_patience_loss == 1, "a full row does not change patience")

	var pair = Rules.scripted_encounter(123, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(pair, "entry_mark", 0, 0), "one stamp in the row")
	check(play_named(pair, "entry_mark", 0, 1), "Wynn receives a row that is not full, the wrong stamp")
	check(pair.last_progress_gained == 4, "a stamp in a row that is not full scores its own number (%d)" % pair.last_progress_gained)

	var lone_wynn = Rules.scripted_encounter(123, 2, ["duty"], 1, Rules.SHIFT_INDEX)
	check(play_named(lone_wynn, "duty", 2, 1), "Wynn receives a lone bottom-row duty")
	check(lone_wynn.last_progress_gained == 4, "a lone stamp scores its own number (%d)" % lone_wynn.last_progress_gained)

	var other_row = Rules.scripted_encounter(123, 2, ["entry_mark", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_INDEX)
	check(play_named(other_row, "entry_mark", 0, 0), "a stamp in the top row")
	check(play_named(other_row, "entry_mark", 0, 1), "a second stamp in the top row")
	check(play_named(other_row, "entry_mark", 0, 2), "the top row is full")
	check(play_named(other_row, "entry_mark", 1, 1), "a stamp in an open row")
	check(other_row.last_progress_gained == 14, "another row does not double, and it does not stop the full row (%d)" % other_row.last_progress_gained)

	var open_center = Rules.scripted_encounter(123, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(open_center, "entry_mark", 1, 1), "the center")
	check(play_named(open_center, "entry_mark", 0, 0), "a frame stamp in an open row")
	check(open_center.last_progress_gained == 4, "a filled center does not double a row that is not full (%d)" % open_center.last_progress_gained)

	var wynn_muted = Rules.scripted_encounter(123, 2, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_INDEX)
	check(play_named(wynn_muted, "exemption", 0, 0), "exemption is placed on Wynn's top row")
	check(play_named(wynn_muted, "entry_mark", 0, 1), "a stamp beside that exemption")
	check(play_named(wynn_muted, "entry_mark", 0, 2), "the row is full")
	check(wynn_muted.last_progress_gained == 5, "exemption on the top row cancels the doubling (%d)" % wynn_muted.last_progress_gained)

	var wynn_other = Rules.scripted_encounter(123, 2, ["exemption", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_INDEX)
	check(play_named(wynn_other, "exemption", 0, 0), "exemption on the top row")
	check(play_named(wynn_other, "entry_mark", 2, 0), "a bottom-row stamp")
	check(play_named(wynn_other, "entry_mark", 2, 1), "a second bottom-row stamp")
	check(play_named(wynn_other, "entry_mark", 2, 2), "the bottom row is full")
	check(wynn_other.last_progress_gained == 7, "exemption on the top row cancels doubling in every row (%d)" % wynn_other.last_progress_gained)

	var wynn_kept = Rules.scripted_encounter(123, 2, ["exemption", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_INDEX)
	check(play_named(wynn_kept, "entry_mark", 0, 0), "a top-row stamp")
	check(play_named(wynn_kept, "entry_mark", 0, 1), "a second top-row stamp")
	check(play_named(wynn_kept, "entry_mark", 0, 2), "the top row is full")
	check(play_named(wynn_kept, "exemption", 2, 1), "exemption sits off Wynn's top row")
	check(wynn_kept.last_progress_gained == 13, "an exemption off the top row leaves the full row doubled (%d)" % wynn_kept.last_progress_gained)

	var wynn_bottom = Rules.scripted_encounter(123, 2, ["duty", "exemption", "duty"], 3, Rules.SHIFT_INDEX)
	check(play_named(wynn_bottom, "duty", 2, 0), "a bottom-row duty")
	check(play_named(wynn_bottom, "exemption", 2, 1), "exemption fills the middle of the bottom row")
	check(play_named(wynn_bottom, "duty", 2, 2), "the bottom row is full")
	check(wynn_bottom.last_progress_gained == 18, "an exemption off the top row doubles with its own full row (%d)" % wynn_bottom.last_progress_gained)

	var wynn_reply = Rules.scripted_encounter(123, 2, ["entry_mark", "entry_mark", "entry_mark", "reply"], 4, Rules.SHIFT_INDEX)
	check(play_named(wynn_reply, "entry_mark", 0, 0), "the first of a full row")
	check(play_named(wynn_reply, "entry_mark", 0, 1), "the second of a full row")
	check(play_named(wynn_reply, "entry_mark", 0, 2), "the third of a full row")
	check(play_named(wynn_reply, "reply", 1, 0), "reply retriggers the full row")
	check(wynn_reply.last_chain_count == 1, "the reply still retriggers")
	check(wynn_reply.last_progress_gained == 17, "a retrigger of a stamp in a full row scores twice again (%d)" % wynn_reply.last_progress_gained)

	var wynn_echo = Rules.scripted_encounter(123, 2, ["echo", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(wynn_echo, "echo", 0, 0), "echo in an open row")
	check(play_named(wynn_echo, "entry_mark", 1, 0), "the stamp under the echo")
	check(wynn_echo.last_chain_count == 1, "the echo still retriggers")
	check(wynn_echo.last_progress_gained == 5, "a retrigger in a row that is not full does not double (%d)" % wynn_echo.last_progress_gained)

	var wynn_held = Rules.scripted_encounter(123, 2, ["entry_mark", "hold", "entry_mark"], 3, Rules.SHIFT_INDEX)
	check(play_named(wynn_held, "entry_mark", 0, 0), "one stamp of the row")
	check(play_named(wynn_held, "hold", 0, 1), "hold in Wynn's column")
	check(play_named(wynn_held, "entry_mark", 0, 2), "the row is full")
	check(wynn_held.last_progress_gained == 10, "the held stamp in a full row still scores twice")
	check(wynn_held.last_patience_loss == 0 and wynn_held.patience == 5, "hold delays Wynn")

	var wynn_missed = Rules.scripted_encounter(123, 2, ["hold", "entry_mark", "entry_mark"], 3, Rules.SHIFT_INDEX)
	check(play_named(wynn_missed, "hold", 0, 0), "hold outside Wynn's column")
	check(play_named(wynn_missed, "entry_mark", 0, 1), "a stamp beside the hold")
	check(play_named(wynn_missed, "entry_mark", 0, 2), "the row is full")
	check(wynn_missed.last_progress_gained == 10, "the outside hold still doubles with the row")
	check(wynn_missed.last_patience_loss == 1, "hold in another column does not delay Wynn")

	var sol = Rules.scripted_encounter(21, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LATE)
	check(String(Rules.traveler(sol)["rule"]) == "yield_full_middle", "Sol Wicks still yields for a full middle row")
	check(play_named(sol, "entry_mark", 1, 0), "Sol's first middle stamp")
	check(play_named(sol, "entry_mark", 1, 1), "Sol's second middle stamp")
	check(play_named(sol, "entry_mark", 1, 2), "Sol's full middle row")
	check(sol.last_progress_gained == 10, "the late shift still yields +4 instead of doubling the row (%d)" % sol.last_progress_gained)

	var bram = Rules.scripted_encounter(113, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(String(Rules.traveler(bram)["rule"]) == "double_frame_if_center", "Bram Hart still doubles the frame when the center is filled")
	check(play_named(bram, "entry_mark", 1, 1), "Bram's center")
	check(play_named(bram, "entry_mark", 0, 0), "Bram's frame stamp")
	check(bram.last_progress_gained == 6, "the margin bell still doubles the frame and not the whole row (%d)" % bram.last_progress_gained)

	var sera = Rules.scripted_encounter(124, 3, ["entry_mark", "entry_mark", "visa_dot"], 3, Rules.SHIFT_INDEX)
	check(String(Rules.traveler(sera)["name"]) == "Sera Voss", "the index bell's fourth form is Sera Voss")
	check(String(Rules.traveler(sera)["form_name"]) == "End Match", "Sera brings the End Match")
	check(String(Rules.traveler(sera)["rule_text"]) == "If the first and last filled stamps show the same number, every filled stamp scores +2. A lone stamp scores its own number.", "Sera's form states the end match")
	check(int(Rules.traveler(sera)["lane"]) == 0 and int(Rules.traveler(sera)["exemption_row"]) == 2, "Sera waits in column 1 and exempts the bottom row")
	check(int(Rules.traveler(sera)["goal"]) == 20, "Sera's goal is 20")
	check(Rules.preview_progress(sera, "entry_mark", 0, 0) == 2, "preview leaves a lone entry mark at its own number")
	check(play_named(sera, "entry_mark", 0, 0), "the first stamp leaves Sera's turn open")
	check(sera.phase == "play", "Sera's first stamp does not end the turn")
	check(Rules.preview_progress(sera, "entry_mark", 0, 1) == 4, "preview adds 2 when the ends match")
	check(Rules.preview_progress(sera, "visa_dot", 0, 1) == 3, "preview leaves a different end at its own number")

	var matched = Rules.scripted_encounter(124, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(matched, "entry_mark", 0, 0), "the first end")
	check(play_named(matched, "entry_mark", 0, 1), "Sera receives a matching last stamp, the correct stamp")
	check(matched.last_progress_gained == 8, "matching ends add 2 to every filled stamp (%d)" % matched.last_progress_gained)
	check(matched.last_patience_loss == 1 and matched.patience == 4, "matching ends still drop patience by 1")

	var differed = Rules.scripted_encounter(124, 3, ["entry_mark", "visa_dot"], 2, Rules.SHIFT_INDEX)
	check(play_named(differed, "entry_mark", 0, 0), "the first end")
	check(play_named(differed, "visa_dot", 0, 1), "Sera receives a different last stamp, the wrong stamp")
	check(differed.last_progress_gained == 5, "ends that differ score their own number (%d)" % differed.last_progress_gained)
	check(differed.last_patience_loss == 1, "different ends drop patience by 1")

	var lone_sera = Rules.scripted_encounter(124, 3, ["entry_mark"], 1, Rules.SHIFT_INDEX)
	check(play_named(lone_sera, "entry_mark", 1, 1), "Sera receives a lone stamp")
	check(lone_sera.last_progress_gained == 2, "a lone stamp scores its own number (%d)" % lone_sera.last_progress_gained)

	var same_card = Rules.scripted_encounter(124, 3, ["duty", "duty"], 2, Rules.SHIFT_INDEX)
	check(play_named(same_card, "duty", 0, 0), "a top-row duty")
	check(play_named(same_card, "duty", 2, 2), "a bottom-row duty")
	check(same_card.last_progress_gained == 6, "the same card can fail to match when the numbers differ (%d)" % same_card.last_progress_gained)

	var shared_number = Rules.scripted_encounter(124, 3, ["duty", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(shared_number, "duty", 0, 0), "a top-row duty")
	check(play_named(shared_number, "entry_mark", 0, 2), "an entry mark with the same number")
	check(shared_number.last_progress_gained == 8, "different cards add 2 when the ends match (%d)" % shared_number.last_progress_gained)
	check(shared_number.last_patience_loss == 1, "a gap does not change Sera's patience")

	var middle = Rules.scripted_encounter(124, 3, ["entry_mark", "visa_dot", "entry_mark"], 3, Rules.SHIFT_INDEX)
	check(play_named(middle, "entry_mark", 0, 0), "the first end")
	check(play_named(middle, "visa_dot", 0, 1), "a middle stamp with a different number")
	check(play_named(middle, "entry_mark", 0, 2), "the matching last stamp")
	check(middle.last_progress_gained == 13, "every filled stamp scores +2 once, including the middle (%d)" % middle.last_progress_gained)

	var middle_only = Rules.scripted_encounter(124, 3, ["entry_mark", "entry_mark", "visa_dot"], 3, Rules.SHIFT_INDEX)
	check(play_named(middle_only, "entry_mark", 0, 0), "the first stamp")
	check(play_named(middle_only, "entry_mark", 0, 1), "a middle stamp that matches the first")
	check(play_named(middle_only, "visa_dot", 0, 2), "a last stamp that differs")
	check(middle_only.last_progress_gained == 7, "a middle match does not add the bonus when the ends differ (%d)" % middle_only.last_progress_gained)

	var wrapped = Rules.scripted_encounter(124, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(wrapped, "entry_mark", 0, 2), "the last cell of the top row")
	check(play_named(wrapped, "entry_mark", 1, 0), "the first cell of the middle row")
	check(wrapped.last_progress_gained == 8, "a contiguous block across a row still adds 2 when the ends match (%d)" % wrapped.last_progress_gained)

	var pressed_sera = Rules.scripted_encounter(124, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(pressed_sera, "entry_mark", 0, 2), "the later cell is pressed first")
	check(play_named(pressed_sera, "entry_mark", 0, 0), "the earlier cell is pressed last")
	check(pressed_sera.last_progress_gained == 8, "queue order, not press order, matches Sera's ends (%d)" % pressed_sera.last_progress_gained)

	var sera_muted = Rules.scripted_encounter(124, 3, ["entry_mark", "exemption", "entry_mark"], 3, Rules.SHIFT_INDEX)
	check(play_named(sera_muted, "entry_mark", 0, 0), "the first end")
	check(play_named(sera_muted, "exemption", 2, 0), "exemption is placed on Sera's bottom row")
	check(play_named(sera_muted, "entry_mark", 2, 2), "the matching last stamp")
	check(sera_muted.last_progress_gained == 5, "exemption on the bottom row cancels the bonus (%d)" % sera_muted.last_progress_gained)
	check(sera_muted.last_patience_loss == 1, "the cancelled match still drops patience by 1")

	var sera_kept = Rules.scripted_encounter(124, 3, ["entry_mark", "exemption", "entry_mark"], 3, Rules.SHIFT_INDEX)
	check(play_named(sera_kept, "entry_mark", 0, 0), "the first end")
	check(play_named(sera_kept, "exemption", 0, 1), "exemption sits off Sera's bottom row")
	check(play_named(sera_kept, "entry_mark", 2, 2), "the matching last stamp")
	check(sera_kept.last_progress_gained == 11, "an exemption off the bottom row leaves the bonus (%d)" % sera_kept.last_progress_gained)

	var sera_reply = Rules.scripted_encounter(124, 3, ["exemption", "reply"], 2, Rules.SHIFT_INDEX)
	check(play_named(sera_reply, "exemption", 0, 0), "an exemption off the bottom row")
	check(play_named(sera_reply, "reply", 1, 0), "a reply with the same number")
	check(sera_reply.last_chain_count == 1, "the reply still retriggers")
	check(sera_reply.last_progress_gained == 9, "a retrigger adds the end bonus again (%d)" % sera_reply.last_progress_gained)

	var sera_echo = Rules.scripted_encounter(124, 3, ["echo", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(play_named(sera_echo, "echo", 0, 0), "echo at the first end")
	check(play_named(sera_echo, "entry_mark", 1, 0), "an entry mark at the last end")
	check(sera_echo.last_chain_count == 1, "the echo still retriggers")
	check(sera_echo.last_progress_gained == 5, "a retrigger adds nothing when the ends differ (%d)" % sera_echo.last_progress_gained)

	var sera_held = Rules.scripted_encounter(124, 3, ["entry_mark", "hold", "entry_mark"], 3, Rules.SHIFT_INDEX)
	check(play_named(sera_held, "entry_mark", 0, 0), "the first end")
	check(play_named(sera_held, "hold", 2, 0), "hold in Sera's column")
	check(play_named(sera_held, "entry_mark", 2, 2), "the matching last stamp")
	check(sera_held.last_progress_gained == 11, "the held stamp still gains the end bonus")
	check(sera_held.last_patience_loss == 0 and sera_held.patience == 5, "hold delays Sera")

	var sera_missed = Rules.scripted_encounter(124, 3, ["entry_mark", "hold", "entry_mark"], 3, Rules.SHIFT_INDEX)
	check(play_named(sera_missed, "entry_mark", 0, 0), "the first end")
	check(play_named(sera_missed, "hold", 0, 1), "hold outside Sera's column")
	check(play_named(sera_missed, "entry_mark", 0, 2), "the matching last stamp")
	check(sera_missed.last_progress_gained == 11, "the outside hold still gains the end bonus")
	check(sera_missed.last_patience_loss == 1, "hold in another column does not delay Sera")

	var sable = Rules.scripted_encounter(114, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(String(Rules.traveler(sable)["rule"]) == "yield_queue_gap", "Sable Solt still yields for a gap")
	check(play_named(sable, "entry_mark", 0, 0), "the first of Sable's block")
	check(play_named(sable, "entry_mark", 0, 1), "Sable's contiguous stamp")
	check(sable.last_progress_gained == 4, "the margin bell still does not add 2 to a contiguous block (%d)" % sable.last_progress_gained)

	var jun = Rules.scripted_encounter(103, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_WICK)
	check(String(Rules.traveler(jun)["rule"]) == "zero_shared_later", "Jun Solt still zeros the later shared number")
	check(play_named(jun, "entry_mark", 0, 0), "Jun's earlier stamp")
	check(play_named(jun, "entry_mark", 0, 1), "Jun's later stamp")
	check(jun.last_progress_gained == 2, "the wick bell still zeros only the later shared stamp (%d)" % jun.last_progress_gained)

	var ivo = Rules.scripted_encounter(84, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_QUAY)
	check(String(Rules.traveler(ivo)["rule"]) == "double_shared_later", "Ivo Pell still doubles the later shared number")
	check(play_named(ivo, "entry_mark", 0, 0), "Ivo's earlier stamp")
	check(play_named(ivo, "entry_mark", 0, 1), "Ivo's later stamp")
	check(ivo.last_progress_gained == 6, "the quay bell still doubles only the later shared stamp (%d)" % ivo.last_progress_gained)

	var pell = Rules.scripted_encounter(91, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(String(Rules.traveler(pell)["rule"]) == "drop_if_queue_gap", "Pell Sallow still tolls patience for a gap")
	check(play_named(pell, "entry_mark", 0, 0), "the stamp before Pell's gap")
	check(play_named(pell, "entry_mark", 0, 2), "the stamp after Pell's gap")
	check(pell.last_progress_gained == 4, "the folio bell still does not add the gap to the score (%d)" % pell.last_progress_gained)
	check(pell.last_patience_loss == 2, "the folio bell still drops patience by 2 for a gap")


func test_index_bell_opens() -> void:
	check(Rules.INDEX_BELL.size() == 4, "the index bell has four travelers")
	check(String(Rules.INDEX_BELL[0]["name"]) == "Len Quill", "the index bell begins with Len Quill")
	check(String(Rules.INDEX_BELL[1]["name"]) == "Ada Pell", "the index bell's second traveler is Ada Pell")
	check(String(Rules.INDEX_BELL[2]["name"]) == "Wynn Hart", "the index bell's third traveler is Wynn Hart")
	check(String(Rules.INDEX_BELL[3]["name"]) == "Sera Voss", "the index bell ends with Sera Voss")
	check(Rules.MARGIN_BELL.size() == 4 and String(Rules.MARGIN_BELL[0]["name"]) == "Nim Voss", "the margin bell still begins with Nim Voss")
	check(String(Rules.MARGIN_BELL[3]["name"]) == "Sable Solt", "the margin bell still ends with Sable Solt")
	check(Rules.TRAVELERS.size() == 4 and String(Rules.TRAVELERS[0]["name"]) == "Ada Quill", "Act 1 still begins with Ada Quill")
	var index_run = Rules.new_run(80, Rules.SHIFT_INDEX)
	check(index_run.shift == Rules.SHIFT_INDEX, "the index bell is a separate night")
	check(String(Rules.traveler(index_run)["name"]) == "Len Quill", "the index bell begins with Len Quill")
	check(index_run.hand.size() == Rules.HAND_SIZE, "the index bell draws 5")
	check(index_run.ink == Rules.BASE_INK, "the index bell starts at 3 ink")
	check(index_run.library.size() == Rules.STARTING_DECK.size(), "the index bell deals the starting deck")
	check(index_run.relic_id == "", "an earlier night's relic does not carry")
	check(index_run.phase == "play", "the index bell opens in play")
	var dealt: Array = []
	for iid in index_run.hand:
		dealt.append(Rules.card_id_of(index_run, int(iid)))
	var before = index_run.library.size()
	index_run.progress = 4
	index_run.patience = 1
	Rules.restart_encounter(index_run)
	check(index_run.shift == Rules.SHIFT_INDEX and index_run.traveler_index == 0, "restart encounter stays on the index bell")
	check(index_run.progress == 0 and index_run.patience == int(Rules.INDEX_BELL[0]["patience"]), "restart encounter resets Len")
	check(index_run.library.size() == before and index_run.hand.size() == 5 and index_run.phase == "play", "restart keeps the index-bell deck and deals a hand")
	var redealt: Array = []
	for iid in index_run.hand:
		redealt.append(Rules.card_id_of(index_run, int(iid)))
	check(redealt == dealt, "restart deals Len the same hand")

	var packed = load("res://game/main.tscn")
	var desk = packed.instantiate()
	root.add_child(desk)
	if desk.state == null:
		desk._ready()
	check(desk.state.shift == Rules.SHIFT_FIRST, "the desk still opens on Act 1")
	check(desk.index_button.text == "Index bell", "the desk offers the index bell")
	check(desk.margin_button.text == "Margin bell", "the desk still offers the margin bell")
	desk.index_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_INDEX, "the desk can open the index bell")
	check(String(Rules.traveler(desk.state)["name"]) == "Len Quill", "the open desk shows Len")
	check(String(desk.desk_label.text).begins_with("Index bell"), "the desk title follows the index bell")
	check(desk.meta_label.text.contains("Corner Bar"), "the desk shows Len's form")
	check(desk.index_button.text == "First bell", "the index bell can return to the first bell")
	check(desk.margin_button.text == "Margin bell", "the margin bell stays available from the index bell")
	check(desk.shift_button.text == "Late shift", "the late shift stays available from the index bell")
	desk._restart_act()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_INDEX and String(Rules.traveler(desk.state)["name"]) == "Len Quill", "restart act replays the index bell")
	desk.index_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the index bell returns to Ada")
	var doors = [
		["_begin_late_shift", "Nell Parr", "the late shift"],
		["_begin_closing_bell", "Moss Quen", "the closing bell"],
		["_begin_ash_watch", "Orla Fen", "the ash watch"],
		["_begin_gutter_lamp", "Ivo Dane", "the gutter lamp"],
		["_begin_vellum_bell", "Edda Voss", "the vellum bell"],
		["_begin_quire_watch", "Tess Quern", "the quire watch"],
		["_begin_salt_watch", "Pell Voss", "the salt watch"],
		["_begin_quay_bell", "Mara Quill", "the quay bell"],
		["_begin_folio_bell", "Ness Hart", "the folio bell"],
		["_begin_wick_bell", "Odell Voss", "the wick bell"],
		["_begin_margin_bell", "Nim Voss", "the margin bell"],
	]
	for door in doors:
		desk.call(String(door[0]))
		desk._refresh_ui()
		check(desk.state.shift != Rules.SHIFT_INDEX and String(Rules.traveler(desk.state)["name"]) == String(door[1]), "%s still opens" % String(door[2]))
		check(desk.index_button.text == "Index bell", "%s offers the index bell" % String(door[2]))
		desk._begin_index_bell()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_INDEX and String(Rules.traveler(desk.state)["name"]) == "Len Quill", "%s can open the index bell" % String(door[2]))
	desk._begin_first_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "first bell still returns to Ada")
	var victories = [
		[Rules.SHIFT_FIRST, "Act 1"],
		[Rules.SHIFT_LATE, "the late shift"],
		[Rules.SHIFT_CLOSING, "the closing bell"],
		[Rules.SHIFT_ASH, "the ash watch"],
		[Rules.SHIFT_GUTTER, "the gutter lamp"],
		[Rules.SHIFT_VELLUM, "the vellum bell"],
		[Rules.SHIFT_QUIRE, "the quire watch"],
		[Rules.SHIFT_SALT, "the salt watch"],
		[Rules.SHIFT_QUAY, "the quay bell"],
		[Rules.SHIFT_FOLIO, "the folio bell"],
		[Rules.SHIFT_WICK, "the wick bell"],
		[Rules.SHIFT_MARGIN, "the margin bell"],
	]
	for victory in victories:
		desk._open_shift(int(victory[0]), desk.state.seed)
		desk._refresh_ui()
		desk.state.phase = "victory"
		desk._refresh_ui()
		var victory_index = _button_named(desk, "Open the index bell")
		check(victory_index != null, "%s's victory desk offers the index bell" % String(victory[1]))
		if victory_index != null:
			victory_index.pressed.emit()
			desk._refresh_ui()
			check(desk.state.shift == Rules.SHIFT_INDEX and String(Rules.traveler(desk.state)["name"]) == "Len Quill", "%s's victory desk opens the index bell" % String(victory[1]))
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_first = _button_named(desk, "Open the first bell")
	check(victory_first != null, "the index bell victory desk offers the first bell")
	if victory_first != null:
		victory_first.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the index bell victory desk opens the first bell")
	desk._begin_index_bell()
	desk._refresh_ui()
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_margin = _button_named(desk, "Open the margin bell")
	check(victory_margin != null, "the index bell victory desk offers the margin bell")
	if victory_margin != null:
		victory_margin.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_MARGIN and String(Rules.traveler(desk.state)["name"]) == "Nim Voss", "the index bell victory desk opens the margin bell")
	root.remove_child(desk)
	desk.free()


func test_policy_clears_index_bell() -> void:
	var started = Time.get_ticks_msec()
	var state = Rules.new_run(12345, Rules.SHIFT_INDEX)
	var steps = 0
	var seen = 0
	while state.phase != "victory":
		steps += 1
		if steps > 500 or state.phase == "defeat":
			check(false, "policy lost or stalled on the index bell, seed 12345: " + Rules.debug_summary(state))
			return
		var action = Policy.choose(state)
		if not Rules.apply_action(state, action):
			check(false, "index-bell policy action was rejected: %s / %s" % [str(action), Rules.debug_summary(state)])
			return
		if state.encounters_cleared != seen:
			seen = state.encounters_cleared
			print("cleared index encounter %d after %d actions" % [seen, steps])
	var elapsed = Time.get_ticks_msec() - started
	check(state.encounters_cleared == 4, "policy cleared all 4 index-bell encounters on seed 12345")
	check(state.phase == "victory", "index bell ends in victory")
	check(state.shift == Rules.SHIFT_INDEX, "the clear stayed on the index bell")
	print("index bell finished in %d actions, %d ms" % [steps, elapsed])


func test_ledger_bell_rules() -> void:
	var nell = Rules.scripted_encounter(131, 0, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LEDGER)
	check(String(Rules.traveler(nell)["name"]) == "Nell Voss", "the ledger bell's first form is Nell Voss")
	check(String(Rules.traveler(nell)["form_name"]) == "Wing Pair", "Nell brings the Wing Pair")
	check(String(Rules.traveler(nell)["rule_text"]) == "When column 1 and column 3 of the same row are both filled, those two stamps each score +3 once. Column 2 of that row scores its own number.", "Nell's form states the wing pair")
	check(int(Rules.traveler(nell)["lane"]) == 1 and int(Rules.traveler(nell)["exemption_row"]) == 2, "Nell waits in column 2 and exempts the bottom row")
	check(int(Rules.traveler(nell)["goal"]) == 22, "Nell's goal is 22")
	check(Rules.preview_progress(nell, "entry_mark", 0, 0) == 2, "preview counts a lone wing at its own number")
	check(play_named(nell, "entry_mark", 0, 0), "the first wing leaves Nell's turn open")
	check(nell.phase == "play", "Nell's first stamp does not end the turn")
	check(Rules.preview_progress(nell, "entry_mark", 0, 1) == 2, "preview leaves column 2 at its own number")
	check(Rules.preview_progress(nell, "entry_mark", 0, 2) == 5, "preview adds 3 to the stamp that completes the wings")
	check(play_named(nell, "entry_mark", 0, 1), "Nell receives column 2, the wrong stamp")
	check(play_named(nell, "entry_mark", 0, 2), "Nell receives the other wing, the correct stamp")
	check(nell.last_progress_gained == 12, "the two wings score +3 and column 2 scores its own number (%d)" % nell.last_progress_gained)
	check(nell.last_patience_loss == 1, "a wing pair does not change patience")

	var wings = Rules.scripted_encounter(131, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(wings, "entry_mark", 0, 0), "one wing")
	check(play_named(wings, "entry_mark", 0, 2), "the other wing, with the middle empty")
	check(wings.last_progress_gained == 10, "both wings score +3 when the middle cell is empty (%d)" % wings.last_progress_gained)

	var missing = Rules.scripted_encounter(131, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(missing, "entry_mark", 0, 0), "column 1")
	check(play_named(missing, "entry_mark", 0, 1), "Nell receives a row missing column 3, the wrong stamp")
	check(missing.last_progress_gained == 4, "a row missing either wing gets no bonus (%d)" % missing.last_progress_gained)

	var other_wing = Rules.scripted_encounter(131, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(other_wing, "entry_mark", 0, 1), "column 2")
	check(play_named(other_wing, "entry_mark", 0, 2), "a row missing column 1")
	check(other_wing.last_progress_gained == 4, "a row missing column 1 gets no bonus (%d)" % other_wing.last_progress_gained)

	var split = Rules.scripted_encounter(131, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(split, "entry_mark", 0, 0), "column 1 of the top row")
	check(play_named(split, "entry_mark", 1, 2), "column 3 of a different row")
	check(split.last_progress_gained == 4, "wings on different rows score their own number (%d)" % split.last_progress_gained)

	var lone = Rules.scripted_encounter(131, 0, ["duty"], 1, Rules.SHIFT_LEDGER)
	check(play_named(lone, "duty", 2, 0), "Nell receives a lone bottom-row duty")
	check(lone.last_progress_gained == 4, "a lone stamp scores its own number (%d)" % lone.last_progress_gained)
	check(lone.last_patience_loss == 1, "a lone stamp still spends the turn")

	var other_row = Rules.scripted_encounter(131, 0, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LEDGER)
	check(play_named(other_row, "entry_mark", 0, 0), "a top-row wing")
	check(play_named(other_row, "entry_mark", 0, 2), "the other top-row wing")
	check(play_named(other_row, "entry_mark", 1, 0), "a wing whose own row is missing column 3")
	check(other_row.last_progress_gained == 12, "another row does not gain the bonus, and it does not stop the winged row (%d)" % other_row.last_progress_gained)

	var pressed = Rules.scripted_encounter(131, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(pressed, "entry_mark", 0, 2), "the later wing is pressed first")
	check(play_named(pressed, "entry_mark", 0, 0), "the earlier wing is pressed last")
	check(pressed.last_progress_gained == 10, "both wings still score +3 (%d)" % pressed.last_progress_gained)

	var freed = Rules.scripted_encounter(131, 0, ["exemption", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(freed, "exemption", 2, 0), "exemption is a wing on Nell's bottom row")
	check(play_named(freed, "entry_mark", 2, 2), "the other bottom-row wing")
	check(freed.last_progress_gained == 3, "exemption on the bottom row cancels the bonus (%d)" % freed.last_progress_gained)

	var freed_middle = Rules.scripted_encounter(131, 0, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LEDGER)
	check(play_named(freed_middle, "entry_mark", 0, 0), "a top-row wing")
	check(play_named(freed_middle, "exemption", 2, 1), "exemption sits on the bottom row, in column 2")
	check(play_named(freed_middle, "entry_mark", 0, 2), "the other top-row wing")
	check(freed_middle.last_progress_gained == 5, "exemption on the bottom row cancels the bonus in every row (%d)" % freed_middle.last_progress_gained)

	var kept = Rules.scripted_encounter(131, 0, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LEDGER)
	check(play_named(kept, "entry_mark", 0, 0), "a top-row wing")
	check(play_named(kept, "exemption", 1, 1), "exemption sits off Nell's bottom row")
	check(play_named(kept, "entry_mark", 0, 2), "the other top-row wing")
	check(kept.last_progress_gained == 11, "an exemption off the bottom row leaves the bonus (%d)" % kept.last_progress_gained)

	var kept_wing = Rules.scripted_encounter(131, 0, ["exemption", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(kept_wing, "exemption", 0, 0), "exemption is a wing off the bottom row")
	check(play_named(kept_wing, "entry_mark", 0, 2), "the other wing")
	check(kept_wing.last_progress_gained == 9, "an exemption wing off the bottom row still adds 3 (%d)" % kept_wing.last_progress_gained)

	var nell_echo = Rules.scripted_encounter(131, 0, ["echo", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LEDGER)
	check(play_named(nell_echo, "echo", 0, 0), "echo above a wing")
	check(play_named(nell_echo, "entry_mark", 1, 0), "the wing under the echo")
	check(play_named(nell_echo, "entry_mark", 1, 2), "the other wing of that row")
	check(nell_echo.last_chain_count == 1, "the echo still retriggers")
	check(nell_echo.last_progress_gained == 16, "a retrigger of a wing adds 3 again (%d)" % nell_echo.last_progress_gained)

	var nell_reply = Rules.scripted_encounter(131, 0, ["entry_mark", "entry_mark", "entry_mark", "reply"], 4, Rules.SHIFT_LEDGER)
	check(play_named(nell_reply, "entry_mark", 0, 0), "a wing")
	check(play_named(nell_reply, "entry_mark", 0, 1), "column 2 of the winged row")
	check(play_named(nell_reply, "entry_mark", 0, 2), "the other wing")
	check(play_named(nell_reply, "reply", 1, 1), "reply retriggers column 2")
	check(nell_reply.last_chain_count == 1, "the reply still retriggers")
	check(nell_reply.last_progress_gained == 15, "a retrigger of column 2 scores its own number (%d)" % nell_reply.last_progress_gained)

	var nell_held = Rules.scripted_encounter(131, 0, ["entry_mark", "hold", "entry_mark"], 3, Rules.SHIFT_LEDGER)
	check(play_named(nell_held, "entry_mark", 0, 0), "a wing")
	check(play_named(nell_held, "hold", 0, 1), "hold in Nell's column")
	check(play_named(nell_held, "entry_mark", 0, 2), "the other wing")
	check(nell_held.last_progress_gained == 11, "column 2 hold scores 1 beside the wings")
	check(nell_held.last_patience_loss == 0 and nell_held.patience == 5, "hold delays Nell")

	var nell_missed = Rules.scripted_encounter(131, 0, ["hold", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(nell_missed, "hold", 0, 0), "hold is a wing outside Nell's column")
	check(play_named(nell_missed, "entry_mark", 0, 2), "the other wing")
	check(nell_missed.last_progress_gained == 9, "the outside wing hold still adds 3")
	check(nell_missed.last_patience_loss == 1, "hold in another column does not delay Nell")

	var kel = Rules.scripted_encounter(22, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_CLOSING)
	check(String(Rules.traveler(kel)["rule"]) == "yield_both_margins", "Kel Breck still yields when both margins are stamped")
	check(play_named(kel, "entry_mark", 0, 0), "Kel's column 1")
	check(play_named(kel, "entry_mark", 1, 2), "Kel's column 3 on another row")
	check(kel.last_progress_gained == 8, "the closing bell still yields +4 for margins on different rows (%d)" % kel.last_progress_gained)

	var wynn = Rules.scripted_encounter(123, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_INDEX)
	check(String(Rules.traveler(wynn)["rule"]) == "double_full_row", "Wynn Hart still doubles only a full row")
	check(play_named(wynn, "entry_mark", 0, 0), "Wynn's first wing")
	check(play_named(wynn, "entry_mark", 0, 2), "Wynn's other wing, with the middle empty")
	check(wynn.last_progress_gained == 4, "the index bell still does not bonus a row that is not full (%d)" % wynn.last_progress_gained)

	var pell = Rules.scripted_encounter(132, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LEDGER)
	check(String(Rules.traveler(pell)["name"]) == "Pell Dane", "the ledger bell's second form is Pell Dane")
	check(String(Rules.traveler(pell)["form_name"]) == "Three Toll", "Pell brings the Three Toll")
	check(String(Rules.traveler(pell)["rule_text"]) == "Patience drops by 2 when exactly three cells are filled.", "Pell's form states the three toll")
	check(int(Rules.traveler(pell)["lane"]) == 0 and int(Rules.traveler(pell)["exemption_row"]) == 2, "Pell waits in column 1 and exempts the bottom row")
	check(int(Rules.traveler(pell)["goal"]) == 18, "Pell's goal is 18")
	check(Rules.preview_progress(pell, "duty", 2, 0) == 4, "preview leaves a duty at its own number")
	check(play_named(pell, "entry_mark", 0, 0), "the first stamp leaves Pell's turn open")
	check(pell.phase == "play", "Pell's first stamp does not end the turn")
	check(play_named(pell, "entry_mark", 0, 1), "the second stamp")
	check(play_named(pell, "entry_mark", 0, 2), "Pell receives the third stamp, the wrong stamp")
	check(pell.last_progress_gained == 6, "exactly three stamps score their own numbers (%d)" % pell.last_progress_gained)
	check(pell.last_patience_loss == 2 and pell.patience == 3, "exactly three cells drop patience by 2")

	var pair = Rules.scripted_encounter(132, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(pair, "entry_mark", 0, 0), "the first of two")
	check(play_named(pair, "entry_mark", 0, 1), "Pell receives the second stamp, the correct stamp")
	check(pair.last_progress_gained == 4, "exactly two stamps score their own numbers (%d)" % pair.last_progress_gained)
	check(pair.last_patience_loss == 1 and pair.patience == 4, "a form of two keeps the drop at 1")

	var one = Rules.scripted_encounter(132, 1, ["duty"], 1, Rules.SHIFT_LEDGER)
	check(play_named(one, "duty", 2, 1), "Pell receives one bottom-row duty")
	check(one.last_progress_gained == 4, "one stamp scores its own number (%d)" % one.last_progress_gained)
	check(one.last_patience_loss == 1, "one stamp keeps the drop at 1")

	var four = Rules.scripted_encounter(132, 1, ["entry_mark", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_LEDGER)
	check(play_named(four, "entry_mark", 0, 0), "the first of four")
	check(play_named(four, "entry_mark", 0, 1), "the second of four")
	check(play_named(four, "entry_mark", 0, 2), "the third of four")
	check(play_named(four, "entry_mark", 1, 0), "Pell receives a fourth stamp")
	check(four.last_progress_gained == 8, "four stamps score their own numbers (%d)" % four.last_progress_gained)
	check(four.last_patience_loss == 1, "a form of four keeps the drop at 1")

	var scored = Rules.scripted_encounter(132, 1, ["duty", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LEDGER)
	check(play_named(scored, "duty", 2, 0), "a bottom-row duty")
	check(play_named(scored, "entry_mark", 0, 1), "an entry mark")
	check(play_named(scored, "entry_mark", 0, 2), "a second entry mark")
	check(scored.last_progress_gained == 8, "the toll does not change the score (%d)" % scored.last_progress_gained)
	check(scored.last_patience_loss == 2, "three stamps still drop patience by 2")

	var empty = Rules.scripted_encounter(132, 1, ["entry_mark"], 3, Rules.SHIFT_LEDGER)
	Rules.end_turn(empty)
	check(empty.last_progress_gained == 0, "an empty form scores nothing")
	check(empty.last_patience_loss == 1, "an empty form keeps the drop at 1")

	var pell_held = Rules.scripted_encounter(132, 1, ["hold", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LEDGER)
	check(play_named(pell_held, "entry_mark", 0, 1), "a stamp outside the lane")
	check(play_named(pell_held, "entry_mark", 0, 2), "a second stamp")
	check(play_named(pell_held, "hold", 1, 0), "hold in Pell's column")
	check(pell_held.last_progress_gained == 5, "the held turn still scores the stamps")
	check(pell_held.last_patience_loss == 0 and pell_held.patience == 5, "hold is applied before the three toll")

	var pell_missed = Rules.scripted_encounter(132, 1, ["hold", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LEDGER)
	check(play_named(pell_missed, "entry_mark", 0, 0), "a stamp in column 1 that is not a hold")
	check(play_named(pell_missed, "hold", 0, 1), "hold outside Pell's column")
	check(play_named(pell_missed, "entry_mark", 0, 2), "the third stamp")
	check(pell_missed.last_progress_gained == 5, "the outside hold still scores 1")
	check(pell_missed.last_patience_loss == 2, "hold in another column does not stop the three toll")

	var pell_spared = Rules.scripted_encounter(132, 1, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LEDGER)
	check(play_named(pell_spared, "entry_mark", 0, 1), "a stamp")
	check(play_named(pell_spared, "entry_mark", 1, 1), "a second stamp")
	check(play_named(pell_spared, "exemption", 2, 0), "exemption is placed on Pell's bottom row")
	check(pell_spared.last_progress_gained == 5, "the exempted stamps still score")
	check(pell_spared.last_patience_loss == 1, "exemption on the bottom row keeps the drop at 1")

	var pell_open = Rules.scripted_encounter(132, 1, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LEDGER)
	check(play_named(pell_open, "exemption", 0, 0), "exemption sits off Pell's bottom row")
	check(play_named(pell_open, "entry_mark", 0, 1), "a stamp beside that exemption")
	check(play_named(pell_open, "entry_mark", 0, 2), "the third stamp")
	check(pell_open.last_progress_gained == 5, "the off-row exemption still scores")
	check(pell_open.last_patience_loss == 2, "an exemption off the bottom row leaves the drop at 2")

	var joss = Rules.scripted_encounter(31, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_ASH)
	check(String(Rules.traveler(joss)["rule"]) == "yield_exact_two", "Joss Mire still yields for exactly two stamps")
	check(play_named(joss, "entry_mark", 0, 0), "Joss's first stamp")
	check(play_named(joss, "entry_mark", 0, 1), "Joss's second stamp")
	check(joss.last_progress_gained == 8, "the ash watch still yields +4 for exactly two stamps (%d)" % joss.last_progress_gained)

	var ida = Rules.scripted_encounter(133, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(String(Rules.traveler(ida)["name"]) == "Ida Mire", "the ledger bell's third form is Ida Mire")
	check(String(Rules.traveler(ida)["form_name"]) == "Low Slip", "Ida brings the Low Slip")
	check(String(Rules.traveler(ida)["rule_text"]) == "When two or more stamps are filled, the earliest stamp among those showing the lowest number scores twice. A lone stamp scores its own number.", "Ida's form states the low slip")
	check(int(Rules.traveler(ida)["lane"]) == 2 and int(Rules.traveler(ida)["exemption_row"]) == 0, "Ida waits in column 3 and exempts the top row")
	check(int(Rules.traveler(ida)["goal"]) == 20, "Ida's goal is 20")
	check(Rules.preview_progress(ida, "entry_mark", 0, 0) == 2, "preview leaves a lone entry mark at its own number")
	check(play_named(ida, "entry_mark", 0, 0), "the first stamp leaves Ida's turn open")
	check(ida.phase == "play", "Ida's first stamp does not end the turn")
	check(Rules.preview_progress(ida, "entry_mark", 0, 1) == 2, "preview leaves the later shared number at its own number")
	check(play_named(ida, "entry_mark", 0, 1), "Ida receives the later shared stamp, the wrong stamp")
	check(ida.last_progress_gained == 6, "only the earlier of the lowest number scores twice (%d)" % ida.last_progress_gained)
	check(ida.last_patience_loss == 1, "the low slip does not change patience")

	var later_low = Rules.scripted_encounter(133, 2, ["visa_dot", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(Rules.preview_progress(later_low, "visa_dot", 0, 0) == 3, "preview leaves a lone visa at its own number")
	check(play_named(later_low, "visa_dot", 0, 0), "a higher first stamp, the wrong stamp")
	check(Rules.preview_progress(later_low, "entry_mark", 0, 1) == 4, "preview doubles the later lowest number")
	check(play_named(later_low, "entry_mark", 0, 1), "Ida receives the later lowest stamp, the correct stamp")
	check(later_low.last_progress_gained == 7, "the first stamp does not double when a later stamp is lower (%d)" % later_low.last_progress_gained)

	var lone_ida = Rules.scripted_encounter(133, 2, ["entry_mark"], 1, Rules.SHIFT_LEDGER)
	check(play_named(lone_ida, "entry_mark", 1, 1), "Ida receives a lone stamp")
	check(lone_ida.last_progress_gained == 2, "a lone stamp scores its own number (%d)" % lone_ida.last_progress_gained)

	var duties = Rules.scripted_encounter(133, 2, ["duty", "duty"], 2, Rules.SHIFT_LEDGER)
	check(play_named(duties, "duty", 0, 0), "a top-row duty")
	check(play_named(duties, "duty", 2, 2), "a bottom-row duty")
	check(duties.last_progress_gained == 8, "only the lower duty doubles when the same card shows two numbers (%d)" % duties.last_progress_gained)

	var pressed_ida = Rules.scripted_encounter(133, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(pressed_ida, "entry_mark", 0, 1), "the later cell is pressed first")
	check(play_named(pressed_ida, "entry_mark", 0, 0), "the earlier cell is pressed last")
	check(pressed_ida.last_progress_gained == 6, "queue order, not press order, finds the earliest lowest stamp (%d)" % pressed_ida.last_progress_gained)

	var pressed_low = Rules.scripted_encounter(133, 2, ["entry_mark", "visa_dot"], 2, Rules.SHIFT_LEDGER)
	check(play_named(pressed_low, "entry_mark", 0, 1), "the lower stamp is pressed first, in a later cell")
	check(play_named(pressed_low, "visa_dot", 0, 0), "the higher stamp is pressed last, in an earlier cell")
	check(pressed_low.last_progress_gained == 7, "queue order still doubles the later lowest stamp (%d)" % pressed_low.last_progress_gained)

	var ida_muted = Rules.scripted_encounter(133, 2, ["exemption", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(ida_muted, "exemption", 0, 0), "exemption is placed on Ida's top row")
	check(play_named(ida_muted, "entry_mark", 0, 1), "a later stamp")
	check(ida_muted.last_progress_gained == 3, "exemption on the top row cancels the doubling (%d)" % ida_muted.last_progress_gained)

	var ida_later = Rules.scripted_encounter(133, 2, ["entry_mark", "exemption"], 2, Rules.SHIFT_LEDGER)
	check(play_named(ida_later, "entry_mark", 0, 0), "an earlier stamp")
	check(play_named(ida_later, "exemption", 0, 2), "exemption is later on the top row")
	check(ida_later.last_progress_gained == 3, "a later exemption on the top row still cancels the doubling (%d)" % ida_later.last_progress_gained)

	var ida_kept = Rules.scripted_encounter(133, 2, ["entry_mark", "exemption"], 2, Rules.SHIFT_LEDGER)
	check(play_named(ida_kept, "entry_mark", 0, 0), "an earlier higher stamp")
	check(play_named(ida_kept, "exemption", 2, 0), "exemption sits off Ida's top row")
	check(ida_kept.last_progress_gained == 4, "an exemption off the top row still doubles the lowest stamp (%d)" % ida_kept.last_progress_gained)

	var shared = Rules.scripted_encounter(133, 2, ["hold", "echo"], 2, Rules.SHIFT_LEDGER)
	check(play_named(shared, "hold", 1, 0), "the earlier of two stamps showing 1")
	check(play_named(shared, "echo", 1, 1), "the later stamp showing the same number")
	check(shared.last_progress_gained == 3, "only the earlier of a shared lowest number doubles (%d)" % shared.last_progress_gained)
	check(shared.last_patience_loss == 1, "hold outside Ida's column does not delay her")

	var ida_reply = Rules.scripted_encounter(133, 2, ["entry_mark", "reply", "reply"], 3, Rules.SHIFT_LEDGER)
	check(play_named(ida_reply, "entry_mark", 0, 0), "a higher stamp")
	check(play_named(ida_reply, "reply", 0, 1), "the earliest lowest stamp")
	check(play_named(ida_reply, "reply", 1, 1), "a later reply that retriggers it")
	check(ida_reply.last_chain_count == 1, "the reply still retriggers")
	check(ida_reply.last_progress_gained == 7, "a retrigger of the earliest lowest stamp scores twice again (%d)" % ida_reply.last_progress_gained)

	var ida_echo = Rules.scripted_encounter(133, 2, ["echo", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(ida_echo, "echo", 0, 0), "echo is the earliest lowest stamp")
	check(play_named(ida_echo, "entry_mark", 1, 0), "the stamp under the echo")
	check(ida_echo.last_chain_count == 1, "the echo still retriggers")
	check(ida_echo.last_progress_gained == 6, "a retrigger of any other stamp does not double (%d)" % ida_echo.last_progress_gained)

	var ida_held = Rules.scripted_encounter(133, 2, ["entry_mark", "hold"], 2, Rules.SHIFT_LEDGER)
	check(play_named(ida_held, "entry_mark", 0, 0), "a higher stamp")
	check(play_named(ida_held, "hold", 0, 2), "hold in Ida's column is the lowest stamp")
	check(ida_held.last_progress_gained == 4, "the lowest hold still scores twice")
	check(ida_held.last_patience_loss == 0 and ida_held.patience == 5, "hold delays Ida")

	var ida_missed = Rules.scripted_encounter(133, 2, ["hold", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(ida_missed, "hold", 0, 0), "hold outside Ida's column")
	check(play_named(ida_missed, "entry_mark", 0, 1), "a higher later stamp")
	check(ida_missed.last_progress_gained == 4, "the outside hold still doubles when it is lowest")
	check(ida_missed.last_patience_loss == 1, "hold in another column does not delay Ida")

	var ida_cress = Rules.scripted_encounter(71, 3, ["entry_mark"], 1, Rules.SHIFT_QUIRE)
	check(String(Rules.traveler(ida_cress)["rule"]) == "double_first", "Ida Cress still doubles the first stamp")
	check(play_named(ida_cress, "entry_mark", 1, 1), "Ida Cress receives a lone stamp")
	check(ida_cress.last_progress_gained == 4, "the quire watch still doubles a lone first stamp (%d)" % ida_cress.last_progress_gained)

	var cress = Rules.scripted_encounter(102, 1, ["visa_dot", "entry_mark"], 2, Rules.SHIFT_WICK)
	check(String(Rules.traveler(cress)["rule"]) == "double_first_if_followed", "Cress Hart still doubles a followed first stamp")
	check(play_named(cress, "visa_dot", 0, 0), "Cress's first stamp")
	check(play_named(cress, "entry_mark", 0, 1), "Cress's later stamp")
	check(cress.last_progress_gained == 8, "the wick bell still doubles the first stamp, not the lowest (%d)" % cress.last_progress_gained)

	var sable = Rules.scripted_encounter(134, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(String(Rules.traveler(sable)["name"]) == "Sable Quern", "the ledger bell's fourth form is Sable Quern")
	check(String(Rules.traveler(sable)["form_name"]) == "After Gap", "Sable brings the After Gap")
	check(String(Rules.traveler(sable)["rule_text"]) == "A stamp scores twice only when the queue cell immediately before it is empty and some earlier cell is filled.", "Sable's form states the after gap")
	check(int(Rules.traveler(sable)["lane"]) == 0 and int(Rules.traveler(sable)["exemption_row"]) == 0, "Sable waits in column 1 and exempts the top row")
	check(int(Rules.traveler(sable)["goal"]) == 21, "Sable's goal is 21")
	check(Rules.preview_progress(sable, "entry_mark", 0, 0) == 2, "preview leaves the start of the queue at its own number")
	check(play_named(sable, "entry_mark", 0, 0), "the stamp before the gap leaves Sable's turn open")
	check(sable.phase == "play", "Sable's first stamp does not end the turn")
	check(Rules.preview_progress(sable, "entry_mark", 0, 1) == 2, "preview leaves a contiguous stamp at its own number")
	check(Rules.preview_progress(sable, "entry_mark", 0, 2) == 4, "preview doubles the stamp immediately after the gap")
	check(play_named(sable, "entry_mark", 0, 2), "Sable receives the stamp after the gap, the correct stamp")
	check(sable.last_progress_gained == 6, "the stamp before the gap scores its own number and the stamp after it scores twice (%d)" % sable.last_progress_gained)
	check(sable.last_patience_loss == 1 and sable.patience == 4, "a gap does not change Sable's patience")

	var block = Rules.scripted_encounter(134, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(block, "entry_mark", 0, 0), "the first of a block")
	check(play_named(block, "entry_mark", 0, 1), "Sable receives a contiguous stamp, the wrong stamp")
	check(block.last_progress_gained == 4, "a contiguous block has no doubled stamp (%d)" % block.last_progress_gained)

	var lone_sable = Rules.scripted_encounter(134, 3, ["entry_mark"], 1, Rules.SHIFT_LEDGER)
	check(play_named(lone_sable, "entry_mark", 0, 0), "Sable receives a stamp at the start of the queue")
	check(lone_sable.last_progress_gained == 2, "a stamp at the start of the queue does not double (%d)" % lone_sable.last_progress_gained)

	var leading = Rules.scripted_encounter(134, 3, ["entry_mark"], 1, Rules.SHIFT_LEDGER)
	check(play_named(leading, "entry_mark", 1, 0), "the first filled stamp sits after empty cells")
	check(leading.last_progress_gained == 2, "leading empty cells do not double the first filled stamp (%d)" % leading.last_progress_gained)

	var wrapped = Rules.scripted_encounter(134, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(wrapped, "entry_mark", 0, 2), "the last cell of the top row")
	check(play_named(wrapped, "entry_mark", 1, 0), "the first cell of the next row")
	check(wrapped.last_progress_gained == 4, "a filled last cell keeps the next row's first cell at its own number (%d)" % wrapped.last_progress_gained)

	var wrapped_gap = Rules.scripted_encounter(134, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(wrapped_gap, "entry_mark", 0, 0), "an earlier cell")
	check(play_named(wrapped_gap, "entry_mark", 1, 0), "the next row begins after an empty last cell")
	check(wrapped_gap.last_progress_gained == 6, "across a row break, an empty last cell doubles the next row's first cell (%d)" % wrapped_gap.last_progress_gained)

	var after = Rules.scripted_encounter(134, 3, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LEDGER)
	check(play_named(after, "entry_mark", 0, 0), "the stamp before the gap")
	check(play_named(after, "entry_mark", 0, 2), "the stamp immediately after the gap")
	check(play_named(after, "entry_mark", 1, 0), "a stamp that follows a filled cell")
	check(after.last_progress_gained == 8, "an earlier gap does not double a stamp that follows a filled cell (%d)" % after.last_progress_gained)

	var pressed_sable = Rules.scripted_encounter(134, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(pressed_sable, "entry_mark", 0, 2), "the later cell is pressed first")
	check(play_named(pressed_sable, "entry_mark", 0, 0), "the earlier cell is pressed last")
	check(pressed_sable.last_progress_gained == 6, "queue order, not press order, doubles the stamp after the gap (%d)" % pressed_sable.last_progress_gained)

	var sable_muted = Rules.scripted_encounter(134, 3, ["exemption", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(sable_muted, "exemption", 0, 0), "exemption is placed on Sable's top row")
	check(play_named(sable_muted, "entry_mark", 0, 2), "the stamp after the gap")
	check(sable_muted.last_progress_gained == 3, "exemption on the top row cancels the doubling (%d)" % sable_muted.last_progress_gained)

	var sable_kept = Rules.scripted_encounter(134, 3, ["entry_mark", "entry_mark", "exemption"], 3, Rules.SHIFT_LEDGER)
	check(play_named(sable_kept, "entry_mark", 0, 0), "the stamp before the gap")
	check(play_named(sable_kept, "entry_mark", 0, 2), "the stamp after the gap")
	check(play_named(sable_kept, "exemption", 1, 0), "exemption sits off Sable's top row")
	check(sable_kept.last_progress_gained == 7, "an exemption off the top row leaves the doubling (%d)" % sable_kept.last_progress_gained)
	check(sable_kept.last_patience_loss == 1, "the off-row exemption still drops patience by 1")

	var sable_echo = Rules.scripted_encounter(134, 3, ["entry_mark", "echo", "entry_mark"], 3, Rules.SHIFT_LEDGER)
	check(play_named(sable_echo, "entry_mark", 0, 0), "the stamp before the gap")
	check(play_named(sable_echo, "echo", 0, 2), "echo immediately after the gap")
	check(play_named(sable_echo, "entry_mark", 1, 2), "the stamp under the echo")
	check(sable_echo.last_chain_count == 1, "the echo still retriggers")
	check(sable_echo.last_progress_gained == 12, "a retrigger of a stamp that follows a gap scores twice again (%d)" % sable_echo.last_progress_gained)

	var sable_block = Rules.scripted_encounter(134, 3, ["echo", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_LEDGER)
	check(play_named(sable_block, "echo", 0, 0), "echo at the start of the queue")
	check(play_named(sable_block, "entry_mark", 0, 1), "the next cell")
	check(play_named(sable_block, "entry_mark", 0, 2), "the last cell of the row")
	check(play_named(sable_block, "entry_mark", 1, 0), "the first cell of the next row")
	check(sable_block.last_chain_count == 1, "the echo still retriggers a contiguous stamp")
	check(sable_block.last_progress_gained == 9, "a retrigger in a contiguous block does not double (%d)" % sable_block.last_progress_gained)

	var sable_held = Rules.scripted_encounter(134, 3, ["hold", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(sable_held, "hold", 0, 0), "hold in Sable's column, before the gap")
	check(play_named(sable_held, "entry_mark", 0, 2), "the stamp after the gap")
	check(sable_held.last_progress_gained == 5, "the stamp before the gap still scores its own number")
	check(sable_held.last_patience_loss == 0 and sable_held.patience == 5, "hold delays Sable")

	var sable_missed = Rules.scripted_encounter(134, 3, ["entry_mark", "hold"], 2, Rules.SHIFT_LEDGER)
	check(play_named(sable_missed, "entry_mark", 0, 0), "the stamp before the gap")
	check(play_named(sable_missed, "hold", 0, 2), "hold outside Sable's column, after the gap")
	check(sable_missed.last_progress_gained == 4, "the outside hold still doubles after the gap")
	check(sable_missed.last_patience_loss == 1, "hold in another column does not delay Sable")

	var solt = Rules.scripted_encounter(114, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(String(Rules.traveler(solt)["rule"]) == "yield_queue_gap", "Sable Solt still adds 2 to every stamp in a gap")
	check(play_named(solt, "entry_mark", 0, 0), "Solt's stamp before the gap")
	check(play_named(solt, "entry_mark", 0, 2), "Solt's stamp after the gap")
	check(solt.last_progress_gained == 8, "the margin bell still adds 2 to every filled stamp (%d)" % solt.last_progress_gained)

	var sallow = Rules.scripted_encounter(91, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_FOLIO)
	check(String(Rules.traveler(sallow)["rule"]) == "drop_if_queue_gap", "Pell Sallow still tolls patience for a gap")
	check(play_named(sallow, "entry_mark", 0, 0), "the stamp before Sallow's gap")
	check(play_named(sallow, "entry_mark", 0, 2), "the stamp after Sallow's gap")
	check(sallow.last_progress_gained == 4, "the folio bell still does not double the stamp after the gap (%d)" % sallow.last_progress_gained)
	check(sallow.last_patience_loss == 2, "the folio bell still drops patience by 2 for a gap")


func test_ledger_bell_opens() -> void:
	check(Rules.LEDGER_BELL.size() == 4, "the ledger bell has four travelers")
	check(String(Rules.LEDGER_BELL[0]["name"]) == "Nell Voss", "the ledger bell begins with Nell Voss")
	check(String(Rules.LEDGER_BELL[1]["name"]) == "Pell Dane", "the ledger bell's second traveler is Pell Dane")
	check(String(Rules.LEDGER_BELL[2]["name"]) == "Ida Mire", "the ledger bell's third traveler is Ida Mire")
	check(String(Rules.LEDGER_BELL[3]["name"]) == "Sable Quern", "the ledger bell ends with Sable Quern")
	check(Rules.INDEX_BELL.size() == 4 and String(Rules.INDEX_BELL[0]["name"]) == "Len Quill", "the index bell still begins with Len Quill")
	check(String(Rules.INDEX_BELL[3]["name"]) == "Sera Voss", "the index bell still ends with Sera Voss")
	check(Rules.TRAVELERS.size() == 4 and String(Rules.TRAVELERS[0]["name"]) == "Ada Quill", "Act 1 still begins with Ada Quill")
	var ledger_run = Rules.new_run(81, Rules.SHIFT_LEDGER)
	check(ledger_run.shift == Rules.SHIFT_LEDGER, "the ledger bell is a separate night")
	check(String(Rules.traveler(ledger_run)["name"]) == "Nell Voss", "the ledger bell begins with Nell Voss")
	check(ledger_run.hand.size() == Rules.HAND_SIZE, "the ledger bell draws 5")
	check(ledger_run.ink == Rules.BASE_INK, "the ledger bell starts at 3 ink")
	check(ledger_run.library.size() == Rules.STARTING_DECK.size(), "the ledger bell deals the starting deck")
	check(ledger_run.relic_id == "", "an earlier night's relic does not carry")
	check(ledger_run.phase == "play", "the ledger bell opens in play")
	var dealt: Array = []
	for iid in ledger_run.hand:
		dealt.append(Rules.card_id_of(ledger_run, int(iid)))
	var before = ledger_run.library.size()
	ledger_run.progress = 4
	ledger_run.patience = 1
	Rules.restart_encounter(ledger_run)
	check(ledger_run.shift == Rules.SHIFT_LEDGER and ledger_run.traveler_index == 0, "restart encounter stays on the ledger bell")
	check(ledger_run.progress == 0 and ledger_run.patience == int(Rules.LEDGER_BELL[0]["patience"]), "restart encounter resets Nell")
	check(ledger_run.library.size() == before and ledger_run.hand.size() == 5 and ledger_run.phase == "play", "restart keeps the ledger-bell deck and deals a hand")
	var redealt: Array = []
	for iid in ledger_run.hand:
		redealt.append(Rules.card_id_of(ledger_run, int(iid)))
	check(redealt == dealt, "restart deals Nell the same hand")

	var packed = load("res://game/main.tscn")
	var desk = packed.instantiate()
	root.add_child(desk)
	if desk.state == null:
		desk._ready()
	check(desk.state.shift == Rules.SHIFT_FIRST, "the desk still opens on Act 1")
	check(desk.ledger_button.text == "Ledger bell", "the desk offers the ledger bell")
	check(desk.index_button.text == "Index bell", "the desk still offers the index bell")
	desk.ledger_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_LEDGER, "the desk can open the ledger bell")
	check(String(Rules.traveler(desk.state)["name"]) == "Nell Voss", "the open desk shows Nell")
	check(String(desk.desk_label.text).begins_with("Ledger bell"), "the desk title follows the ledger bell")
	check(desk.meta_label.text.contains("Wing Pair"), "the desk shows Nell's form")
	check(desk.ledger_button.text == "First bell", "the ledger bell can return to the first bell")
	check(desk.index_button.text == "Index bell", "the index bell stays available from the ledger bell")
	check(desk.shift_button.text == "Late shift", "the late shift stays available from the ledger bell")
	desk._restart_act()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_LEDGER and String(Rules.traveler(desk.state)["name"]) == "Nell Voss", "restart act replays the ledger bell")
	desk.ledger_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the ledger bell returns to Ada")
	var doors = [
		["_begin_late_shift", "Nell Parr", "the late shift"],
		["_begin_closing_bell", "Moss Quen", "the closing bell"],
		["_begin_ash_watch", "Orla Fen", "the ash watch"],
		["_begin_gutter_lamp", "Ivo Dane", "the gutter lamp"],
		["_begin_vellum_bell", "Edda Voss", "the vellum bell"],
		["_begin_quire_watch", "Tess Quern", "the quire watch"],
		["_begin_salt_watch", "Pell Voss", "the salt watch"],
		["_begin_quay_bell", "Mara Quill", "the quay bell"],
		["_begin_folio_bell", "Ness Hart", "the folio bell"],
		["_begin_wick_bell", "Odell Voss", "the wick bell"],
		["_begin_margin_bell", "Nim Voss", "the margin bell"],
		["_begin_index_bell", "Len Quill", "the index bell"],
	]
	for door in doors:
		desk.call(String(door[0]))
		desk._refresh_ui()
		check(desk.state.shift != Rules.SHIFT_LEDGER and String(Rules.traveler(desk.state)["name"]) == String(door[1]), "%s still opens" % String(door[2]))
		check(desk.ledger_button.text == "Ledger bell", "%s offers the ledger bell" % String(door[2]))
		desk._begin_ledger_bell()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_LEDGER and String(Rules.traveler(desk.state)["name"]) == "Nell Voss", "%s can open the ledger bell" % String(door[2]))
	desk._begin_first_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "first bell still returns to Ada")
	var victories = [
		[Rules.SHIFT_FIRST, "Act 1"],
		[Rules.SHIFT_LATE, "the late shift"],
		[Rules.SHIFT_CLOSING, "the closing bell"],
		[Rules.SHIFT_ASH, "the ash watch"],
		[Rules.SHIFT_GUTTER, "the gutter lamp"],
		[Rules.SHIFT_VELLUM, "the vellum bell"],
		[Rules.SHIFT_QUIRE, "the quire watch"],
		[Rules.SHIFT_SALT, "the salt watch"],
		[Rules.SHIFT_QUAY, "the quay bell"],
		[Rules.SHIFT_FOLIO, "the folio bell"],
		[Rules.SHIFT_WICK, "the wick bell"],
		[Rules.SHIFT_MARGIN, "the margin bell"],
		[Rules.SHIFT_INDEX, "the index bell"],
	]
	for victory in victories:
		desk._open_shift(int(victory[0]), desk.state.seed)
		desk._refresh_ui()
		desk.state.phase = "victory"
		desk._refresh_ui()
		var victory_ledger = _button_named(desk, "Open the ledger bell")
		check(victory_ledger != null, "%s's victory desk offers the ledger bell" % String(victory[1]))
		if victory_ledger != null:
			victory_ledger.pressed.emit()
			desk._refresh_ui()
			check(desk.state.shift == Rules.SHIFT_LEDGER and String(Rules.traveler(desk.state)["name"]) == "Nell Voss", "%s's victory desk opens the ledger bell" % String(victory[1]))
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_first = _button_named(desk, "Open the first bell")
	check(victory_first != null, "the ledger bell victory desk offers the first bell")
	if victory_first != null:
		victory_first.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the ledger bell victory desk opens the first bell")
	desk._begin_ledger_bell()
	desk._refresh_ui()
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_index = _button_named(desk, "Open the index bell")
	check(victory_index != null, "the ledger bell victory desk offers the index bell")
	if victory_index != null:
		victory_index.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_INDEX and String(Rules.traveler(desk.state)["name"]) == "Len Quill", "the ledger bell victory desk opens the index bell")
	root.remove_child(desk)
	desk.free()


func test_policy_clears_ledger_bell() -> void:
	var started = Time.get_ticks_msec()
	var state = Rules.new_run(12345, Rules.SHIFT_LEDGER)
	var steps = 0
	var seen = 0
	while state.phase != "victory":
		steps += 1
		if steps > 500 or state.phase == "defeat":
			check(false, "policy lost or stalled on the ledger bell, seed 12345: " + Rules.debug_summary(state))
			return
		var action = Policy.choose(state)
		if not Rules.apply_action(state, action):
			check(false, "ledger-bell policy action was rejected: %s / %s" % [str(action), Rules.debug_summary(state)])
			return
		if state.encounters_cleared != seen:
			seen = state.encounters_cleared
			print("cleared ledger encounter %d after %d actions" % [seen, steps])
	var elapsed = Time.get_ticks_msec() - started
	check(state.encounters_cleared == 4, "policy cleared all 4 ledger-bell encounters on seed 12345")
	check(state.phase == "victory", "ledger bell ends in victory")
	check(state.shift == Rules.SHIFT_LEDGER, "the clear stayed on the ledger bell")
	print("ledger bell finished in %d actions, %d ms" % [steps, elapsed])


func test_spine_bell_rules() -> void:
	var wynn = Rules.scripted_encounter(141, 0, ["visa_dot", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(String(Rules.traveler(wynn)["name"]) == "Wynn Quill", "the spine bell's first form is Wynn Quill")
	check(String(Rules.traveler(wynn)["form_name"]) == "High Slip", "Wynn brings the High Slip")
	check(String(Rules.traveler(wynn)["rule_text"]) == "When two or more stamps are filled, the earliest stamp among those showing the highest number scores twice. A lone stamp scores its own number.", "Wynn's form states the high slip")
	check(int(Rules.traveler(wynn)["lane"]) == 1 and int(Rules.traveler(wynn)["exemption_row"]) == 0, "Wynn waits in column 2 and exempts the top row")
	check(int(Rules.traveler(wynn)["goal"]) == 22, "Wynn's goal is 22")
	check(Rules.preview_progress(wynn, "visa_dot", 0, 0) == 3, "preview leaves a lone visa at its own number")
	check(play_named(wynn, "visa_dot", 0, 0), "the highest stamp leaves Wynn's turn open")
	check(wynn.phase == "play", "Wynn's first stamp does not end the turn")
	check(Rules.preview_progress(wynn, "entry_mark", 0, 1) == 2, "preview leaves the later lower stamp at its own number")
	check(play_named(wynn, "entry_mark", 0, 1), "Wynn receives the later lower stamp, the wrong stamp")
	check(wynn.last_progress_gained == 8, "the earliest highest stamp scores twice and the lower stamp scores its own number (%d)" % wynn.last_progress_gained)
	check(wynn.last_patience_loss == 1, "the high slip does not change patience")

	var later_high = Rules.scripted_encounter(141, 0, ["entry_mark", "visa_dot"], 2, Rules.SHIFT_SPINE)
	check(play_named(later_high, "entry_mark", 0, 0), "a lower first stamp, the wrong stamp")
	check(Rules.preview_progress(later_high, "visa_dot", 0, 1) == 6, "preview doubles the later highest number")
	check(play_named(later_high, "visa_dot", 0, 1), "Wynn receives the later highest stamp, the correct stamp")
	check(later_high.last_progress_gained == 8, "the first stamp does not double when a later stamp is higher (%d)" % later_high.last_progress_gained)

	var lone_wynn = Rules.scripted_encounter(141, 0, ["entry_mark"], 1, Rules.SHIFT_SPINE)
	check(play_named(lone_wynn, "entry_mark", 1, 1), "Wynn receives a lone stamp")
	check(lone_wynn.last_progress_gained == 2, "a lone stamp scores its own number (%d)" % lone_wynn.last_progress_gained)

	var shared_high = Rules.scripted_encounter(141, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(play_named(shared_high, "entry_mark", 0, 0), "the earlier of two stamps showing the highest number")
	check(play_named(shared_high, "entry_mark", 0, 1), "the later stamp showing that same number, the wrong stamp")
	check(shared_high.last_progress_gained == 6, "only the earlier of a shared highest number doubles (%d)" % shared_high.last_progress_gained)

	var duties_wynn = Rules.scripted_encounter(141, 0, ["duty", "duty"], 2, Rules.SHIFT_SPINE)
	check(play_named(duties_wynn, "duty", 0, 0), "a top-row duty")
	check(play_named(duties_wynn, "duty", 2, 2), "a bottom-row duty")
	check(duties_wynn.last_progress_gained == 10, "only the higher duty doubles when the same card shows two numbers (%d)" % duties_wynn.last_progress_gained)

	var pressed_wynn = Rules.scripted_encounter(141, 0, ["visa_dot", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(play_named(pressed_wynn, "entry_mark", 0, 1), "the later cell is pressed first")
	check(play_named(pressed_wynn, "visa_dot", 0, 0), "the earlier cell is pressed last")
	check(pressed_wynn.last_progress_gained == 8, "queue order, not press order, finds the earliest highest stamp (%d)" % pressed_wynn.last_progress_gained)

	var wynn_muted = Rules.scripted_encounter(141, 0, ["exemption", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(play_named(wynn_muted, "exemption", 0, 0), "exemption is placed on Wynn's top row")
	check(play_named(wynn_muted, "entry_mark", 0, 1), "a later stamp")
	check(wynn_muted.last_progress_gained == 3, "exemption on the top row cancels the doubling (%d)" % wynn_muted.last_progress_gained)

	var wynn_later = Rules.scripted_encounter(141, 0, ["entry_mark", "exemption"], 2, Rules.SHIFT_SPINE)
	check(play_named(wynn_later, "entry_mark", 0, 0), "an earlier stamp")
	check(play_named(wynn_later, "exemption", 0, 2), "exemption is later on the top row")
	check(wynn_later.last_progress_gained == 3, "a later exemption on the top row still cancels the doubling (%d)" % wynn_later.last_progress_gained)

	var wynn_kept = Rules.scripted_encounter(141, 0, ["entry_mark", "exemption"], 2, Rules.SHIFT_SPINE)
	check(play_named(wynn_kept, "entry_mark", 0, 0), "an earlier higher stamp")
	check(play_named(wynn_kept, "exemption", 2, 0), "exemption sits off Wynn's top row")
	check(wynn_kept.last_progress_gained == 5, "an exemption off the top row still doubles the highest stamp (%d)" % wynn_kept.last_progress_gained)

	var wynn_same = Rules.scripted_encounter(141, 0, ["hold", "echo"], 2, Rules.SHIFT_SPINE)
	check(play_named(wynn_same, "hold", 0, 0), "the earlier of two stamps showing 1")
	check(play_named(wynn_same, "echo", 0, 1), "the later stamp showing the same number")
	check(wynn_same.last_progress_gained == 3, "only the earlier of a shared highest number doubles (%d)" % wynn_same.last_progress_gained)
	check(wynn_same.last_patience_loss == 1, "hold outside Wynn's column does not delay her")

	var wynn_reply = Rules.scripted_encounter(141, 0, ["visa_dot", "reply"], 2, Rules.SHIFT_SPINE)
	check(play_named(wynn_reply, "visa_dot", 0, 0), "the earliest highest stamp")
	check(play_named(wynn_reply, "reply", 1, 0), "a later reply that retriggers it")
	check(wynn_reply.last_chain_count == 1, "the reply still retriggers")
	check(wynn_reply.last_progress_gained == 13, "a retrigger of the earliest highest stamp scores twice again (%d)" % wynn_reply.last_progress_gained)

	var wynn_echo = Rules.scripted_encounter(141, 0, ["echo", "entry_mark", "visa_dot"], 3, Rules.SHIFT_SPINE)
	check(play_named(wynn_echo, "echo", 0, 0), "echo is not the highest stamp")
	check(play_named(wynn_echo, "entry_mark", 1, 0), "the stamp under the echo")
	check(play_named(wynn_echo, "visa_dot", 0, 2), "the highest stamp")
	check(wynn_echo.last_chain_count == 1, "the echo still retriggers")
	check(wynn_echo.last_progress_gained == 11, "a retrigger of any other stamp does not double (%d)" % wynn_echo.last_progress_gained)

	var wynn_held = Rules.scripted_encounter(141, 0, ["entry_mark", "hold"], 2, Rules.SHIFT_SPINE)
	check(play_named(wynn_held, "entry_mark", 0, 0), "a higher stamp")
	check(play_named(wynn_held, "hold", 0, 1), "hold in Wynn's column")
	check(wynn_held.last_progress_gained == 5, "the higher stamp still scores twice beside the hold")
	check(wynn_held.last_patience_loss == 0 and wynn_held.patience == 5, "hold delays Wynn")

	var wynn_missed = Rules.scripted_encounter(141, 0, ["hold", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(play_named(wynn_missed, "hold", 0, 0), "hold outside Wynn's column")
	check(play_named(wynn_missed, "entry_mark", 0, 2), "a higher later stamp")
	check(wynn_missed.last_progress_gained == 5, "the higher stamp still doubles when the hold is earlier")
	check(wynn_missed.last_patience_loss == 1, "hold in another column does not delay Wynn")

	var ida_low = Rules.scripted_encounter(133, 2, ["visa_dot", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(String(Rules.traveler(ida_low)["rule"]) == "double_lowest_earliest", "Ida Mire still doubles the earliest lowest number")
	check(play_named(ida_low, "visa_dot", 0, 0), "Ida's higher stamp")
	check(play_named(ida_low, "entry_mark", 0, 1), "Ida's lower stamp")
	check(ida_low.last_progress_gained == 7, "the ledger bell still doubles the lowest number, not the highest (%d)" % ida_low.last_progress_gained)

	var ida_cress = Rules.scripted_encounter(71, 3, ["entry_mark"], 1, Rules.SHIFT_QUIRE)
	check(String(Rules.traveler(ida_cress)["rule"]) == "double_first", "Ida Cress still doubles a lone first stamp")
	check(play_named(ida_cress, "entry_mark", 1, 1), "Ida Cress receives a lone stamp")
	check(ida_cress.last_progress_gained == 4, "the quire watch still doubles a lone first stamp (%d)" % ida_cress.last_progress_gained)

	var ada = Rules.scripted_encounter(142, 1, ["entry_mark", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_SPINE)
	check(String(Rules.traveler(ada)["name"]) == "Ada Hart", "the spine bell's second form is Ada Hart")
	check(String(Rules.traveler(ada)["form_name"]) == "Four Toll", "Ada brings the Four Toll")
	check(String(Rules.traveler(ada)["rule_text"]) == "Patience drops by 2 when exactly four cells are filled.", "Ada's form states the four toll")
	check(int(Rules.traveler(ada)["lane"]) == 2 and int(Rules.traveler(ada)["exemption_row"]) == 2, "Ada waits in column 3 and exempts the bottom row")
	check(int(Rules.traveler(ada)["goal"]) == 16, "Ada's goal is 16")
	check(Rules.preview_progress(ada, "duty", 2, 2) == 4, "preview leaves a duty at its own number")
	check(play_named(ada, "entry_mark", 0, 0), "the first stamp leaves Ada's turn open")
	check(ada.phase == "play", "Ada's first stamp does not end the turn")
	check(play_named(ada, "entry_mark", 0, 1), "the second stamp")
	check(play_named(ada, "entry_mark", 0, 2), "the third stamp, the correct count")
	check(play_named(ada, "entry_mark", 1, 0), "Ada receives the fourth stamp, the wrong stamp")
	check(ada.last_progress_gained == 8, "exactly four stamps score their own numbers (%d)" % ada.last_progress_gained)
	check(ada.last_patience_loss == 2 and ada.patience == 3, "exactly four cells drop patience by 2")

	var ada_three = Rules.scripted_encounter(142, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_SPINE)
	check(play_named(ada_three, "entry_mark", 0, 0), "the first of three")
	check(play_named(ada_three, "entry_mark", 0, 1), "the second of three")
	check(play_named(ada_three, "entry_mark", 0, 2), "Ada receives the third stamp, the correct stamp")
	check(ada_three.last_progress_gained == 6, "exactly three stamps score their own numbers (%d)" % ada_three.last_progress_gained)
	check(ada_three.last_patience_loss == 1 and ada_three.patience == 4, "a form of three keeps the drop at 1")

	var ada_one = Rules.scripted_encounter(142, 1, ["duty"], 1, Rules.SHIFT_SPINE)
	check(play_named(ada_one, "duty", 2, 1), "Ada receives one bottom-row duty")
	check(ada_one.last_progress_gained == 4, "one stamp scores its own number (%d)" % ada_one.last_progress_gained)
	check(ada_one.last_patience_loss == 1, "one stamp keeps the drop at 1")

	var ada_two = Rules.scripted_encounter(142, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(play_named(ada_two, "entry_mark", 0, 0), "the first of two")
	check(play_named(ada_two, "entry_mark", 0, 1), "Ada receives the second stamp")
	check(ada_two.last_progress_gained == 4, "exactly two stamps score their own numbers (%d)" % ada_two.last_progress_gained)
	check(ada_two.last_patience_loss == 1, "a form of two keeps the drop at 1")

	var ada_five = Rules.scripted_encounter(142, 1, ["entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 5, Rules.SHIFT_SPINE)
	check(play_named(ada_five, "entry_mark", 0, 0), "the first of five")
	check(play_named(ada_five, "entry_mark", 0, 1), "the second of five")
	check(play_named(ada_five, "entry_mark", 0, 2), "the third of five")
	check(play_named(ada_five, "entry_mark", 1, 0), "the fourth of five")
	check(play_named(ada_five, "entry_mark", 1, 1), "Ada receives a fifth stamp")
	check(ada_five.last_progress_gained == 10, "five stamps score their own numbers (%d)" % ada_five.last_progress_gained)
	check(ada_five.last_patience_loss == 1, "a form of five keeps the drop at 1")

	var ada_scored = Rules.scripted_encounter(142, 1, ["duty", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_SPINE)
	check(play_named(ada_scored, "duty", 2, 0), "a bottom-row duty")
	check(play_named(ada_scored, "entry_mark", 0, 1), "an entry mark")
	check(play_named(ada_scored, "entry_mark", 0, 2), "a second entry mark")
	check(play_named(ada_scored, "entry_mark", 1, 0), "a third entry mark")
	check(ada_scored.last_progress_gained == 10, "the toll does not change the score (%d)" % ada_scored.last_progress_gained)
	check(ada_scored.last_patience_loss == 2, "four stamps still drop patience by 2")

	var ada_empty = Rules.scripted_encounter(142, 1, ["entry_mark"], 3, Rules.SHIFT_SPINE)
	Rules.end_turn(ada_empty)
	check(ada_empty.last_progress_gained == 0, "an empty form scores nothing")
	check(ada_empty.last_patience_loss == 1, "an empty form keeps the drop at 1")

	var ada_held = Rules.scripted_encounter(142, 1, ["hold", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_SPINE)
	check(play_named(ada_held, "entry_mark", 0, 0), "a stamp outside the lane")
	check(play_named(ada_held, "entry_mark", 0, 1), "a second stamp")
	check(play_named(ada_held, "entry_mark", 1, 0), "a third stamp")
	check(play_named(ada_held, "hold", 1, 2), "hold in Ada's column")
	check(ada_held.last_progress_gained == 7, "the held turn still scores the stamps")
	check(ada_held.last_patience_loss == 0 and ada_held.patience == 5, "hold is applied before the four toll")

	var ada_missed = Rules.scripted_encounter(142, 1, ["hold", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_SPINE)
	check(play_named(ada_missed, "hold", 0, 0), "hold outside Ada's column")
	check(play_named(ada_missed, "entry_mark", 0, 1), "a stamp")
	check(play_named(ada_missed, "entry_mark", 0, 2), "a second stamp")
	check(play_named(ada_missed, "entry_mark", 1, 0), "the fourth stamp")
	check(ada_missed.last_progress_gained == 7, "the outside hold still scores 1")
	check(ada_missed.last_patience_loss == 2, "hold in another column does not stop the four toll")

	var ada_spared = Rules.scripted_encounter(142, 1, ["exemption", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_SPINE)
	check(play_named(ada_spared, "entry_mark", 0, 0), "a stamp")
	check(play_named(ada_spared, "entry_mark", 0, 1), "a second stamp")
	check(play_named(ada_spared, "entry_mark", 0, 2), "a third stamp")
	check(play_named(ada_spared, "exemption", 2, 0), "exemption is placed on Ada's bottom row")
	check(ada_spared.last_progress_gained == 7, "the exempted stamps still score")
	check(ada_spared.last_patience_loss == 1, "exemption on the bottom row keeps the drop at 1")

	var ada_open = Rules.scripted_encounter(142, 1, ["exemption", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_SPINE)
	check(play_named(ada_open, "exemption", 0, 0), "exemption sits off Ada's bottom row")
	check(play_named(ada_open, "entry_mark", 0, 1), "a stamp beside that exemption")
	check(play_named(ada_open, "entry_mark", 0, 2), "a third stamp")
	check(play_named(ada_open, "entry_mark", 1, 0), "the fourth stamp")
	check(ada_open.last_progress_gained == 7, "the off-row exemption still scores")
	check(ada_open.last_patience_loss == 2, "an exemption off the bottom row leaves the drop at 2")

	var pell_three = Rules.scripted_encounter(132, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LEDGER)
	check(String(Rules.traveler(pell_three)["rule"]) == "drop_if_exact_three", "Pell Dane still tolls exactly three stamps")
	check(play_named(pell_three, "entry_mark", 0, 0), "Pell's first stamp")
	check(play_named(pell_three, "entry_mark", 0, 1), "Pell's second stamp")
	check(play_named(pell_three, "entry_mark", 0, 2), "Pell's third stamp")
	check(pell_three.last_patience_loss == 2, "the ledger bell still drops patience by 2 for exactly three cells")

	var pell_four = Rules.scripted_encounter(132, 1, ["entry_mark", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_LEDGER)
	check(play_named(pell_four, "entry_mark", 0, 0), "Pell's first of four")
	check(play_named(pell_four, "entry_mark", 0, 1), "Pell's second of four")
	check(play_named(pell_four, "entry_mark", 0, 2), "Pell's third of four")
	check(play_named(pell_four, "entry_mark", 1, 0), "Pell's fourth stamp")
	check(pell_four.last_patience_loss == 1, "the ledger bell still keeps the drop at 1 for a form of four")

	var bram = Rules.scripted_encounter(143, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(String(Rules.traveler(bram)["name"]) == "Bram Solt", "the spine bell's third form is Bram Solt")
	check(String(Rules.traveler(bram)["form_name"]) == "Before Gap", "Bram brings the Before Gap")
	check(String(Rules.traveler(bram)["rule_text"]) == "A stamp scores twice only when the queue cell immediately after it is empty and some later cell is filled.", "Bram's form states the before gap")
	check(int(Rules.traveler(bram)["lane"]) == 0 and int(Rules.traveler(bram)["exemption_row"]) == 0, "Bram waits in column 1 and exempts the top row")
	check(int(Rules.traveler(bram)["goal"]) == 20, "Bram's goal is 20")
	check(Rules.preview_progress(bram, "entry_mark", 0, 0) == 2, "preview leaves a stamp with nothing later at its own number")
	check(play_named(bram, "entry_mark", 0, 0), "the stamp before the gap leaves Bram's turn open")
	check(bram.phase == "play", "Bram's first stamp does not end the turn")
	check(Rules.preview_progress(bram, "entry_mark", 0, 1) == 2, "preview leaves a contiguous stamp at its own number")
	check(Rules.preview_progress(bram, "entry_mark", 0, 2) == 2, "preview leaves the stamp after the gap at its own number")
	check(play_named(bram, "entry_mark", 0, 2), "Bram receives the stamp after the gap, the wrong stamp")
	check(bram.last_progress_gained == 6, "the stamp before the gap scores twice and the stamp after it scores its own number (%d)" % bram.last_progress_gained)
	check(bram.last_patience_loss == 1 and bram.patience == 4, "a gap does not change Bram's patience")

	var bram_block = Rules.scripted_encounter(143, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(play_named(bram_block, "entry_mark", 0, 0), "the first of a block")
	check(play_named(bram_block, "entry_mark", 0, 1), "Bram receives a contiguous stamp, the wrong stamp")
	check(bram_block.last_progress_gained == 4, "a contiguous block has no doubled stamp (%d)" % bram_block.last_progress_gained)

	var bram_lone = Rules.scripted_encounter(143, 2, ["entry_mark"], 1, Rules.SHIFT_SPINE)
	check(play_named(bram_lone, "entry_mark", 0, 0), "Bram receives a stamp at the start of the queue")
	check(bram_lone.last_progress_gained == 2, "a lone stamp does not double (%d)" % bram_lone.last_progress_gained)

	var bram_end = Rules.scripted_encounter(143, 2, ["entry_mark"], 1, Rules.SHIFT_SPINE)
	check(play_named(bram_end, "entry_mark", 2, 2), "Bram receives a stamp at the end of the queue")
	check(bram_end.last_progress_gained == 2, "a stamp at the end of the queue does not double (%d)" % bram_end.last_progress_gained)

	var bram_leading = Rules.scripted_encounter(143, 2, ["entry_mark"], 1, Rules.SHIFT_SPINE)
	check(play_named(bram_leading, "entry_mark", 1, 0), "the first filled stamp sits after empty cells")
	check(bram_leading.last_progress_gained == 2, "a first filled stamp with nothing later does not double (%d)" % bram_leading.last_progress_gained)

	var bram_wrap = Rules.scripted_encounter(143, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(play_named(bram_wrap, "entry_mark", 0, 2), "the last cell of the top row")
	check(play_named(bram_wrap, "entry_mark", 1, 0), "the first cell of the next row")
	check(bram_wrap.last_progress_gained == 4, "a filled next cell keeps the previous stamp at its own number (%d)" % bram_wrap.last_progress_gained)

	var bram_wrap_gap = Rules.scripted_encounter(143, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(play_named(bram_wrap_gap, "entry_mark", 0, 2), "the last cell of the top row")
	check(play_named(bram_wrap_gap, "entry_mark", 1, 1), "a later cell after an empty first cell")
	check(bram_wrap_gap.last_progress_gained == 6, "across a row break, an empty first cell doubles the previous row's last cell (%d)" % bram_wrap_gap.last_progress_gained)

	var bram_after = Rules.scripted_encounter(143, 2, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_SPINE)
	check(play_named(bram_after, "entry_mark", 0, 0), "the stamp before the gap, the correct stamp")
	check(play_named(bram_after, "entry_mark", 0, 2), "the stamp immediately after the gap")
	check(play_named(bram_after, "entry_mark", 1, 0), "a stamp that follows a filled cell")
	check(bram_after.last_progress_gained == 8, "a stamp that follows a filled cell does not double (%d)" % bram_after.last_progress_gained)

	var bram_pressed = Rules.scripted_encounter(143, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(play_named(bram_pressed, "entry_mark", 0, 2), "the later cell is pressed first")
	check(Rules.preview_progress(bram_pressed, "entry_mark", 0, 0) == 4, "preview doubles the stamp before the gap once a later cell is filled")
	check(play_named(bram_pressed, "entry_mark", 0, 0), "the earlier cell is pressed last, the correct stamp")
	check(bram_pressed.last_progress_gained == 6, "queue order, not press order, doubles the stamp before the gap (%d)" % bram_pressed.last_progress_gained)

	var bram_muted = Rules.scripted_encounter(143, 2, ["exemption", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(play_named(bram_muted, "exemption", 0, 0), "exemption is placed on Bram's top row")
	check(play_named(bram_muted, "entry_mark", 0, 2), "the stamp after the gap")
	check(bram_muted.last_progress_gained == 3, "exemption on the top row cancels the doubling (%d)" % bram_muted.last_progress_gained)

	var bram_kept = Rules.scripted_encounter(143, 2, ["entry_mark", "entry_mark", "exemption"], 3, Rules.SHIFT_SPINE)
	check(play_named(bram_kept, "entry_mark", 0, 0), "the stamp before the gap")
	check(play_named(bram_kept, "entry_mark", 0, 2), "the stamp after the gap")
	check(play_named(bram_kept, "exemption", 1, 0), "exemption sits off Bram's top row")
	check(bram_kept.last_progress_gained == 7, "an exemption off the top row leaves the doubling (%d)" % bram_kept.last_progress_gained)
	check(bram_kept.last_patience_loss == 1, "the off-row exemption still drops patience by 1")

	var bram_echo = Rules.scripted_encounter(143, 2, ["echo", "entry_mark", "entry_mark"], 3, Rules.SHIFT_SPINE)
	check(play_named(bram_echo, "echo", 0, 0), "echo before the gap")
	check(play_named(bram_echo, "entry_mark", 0, 2), "the stamp after the gap")
	check(play_named(bram_echo, "entry_mark", 1, 0), "the stamp under the echo")
	check(bram_echo.last_chain_count == 1, "the echo still retriggers")
	check(bram_echo.last_progress_gained == 8, "a retrigger of a stamp that does not precede a gap scores its own number (%d)" % bram_echo.last_progress_gained)

	var bram_reply = Rules.scripted_encounter(143, 2, ["entry_mark", "entry_mark", "reply"], 3, Rules.SHIFT_SPINE)
	check(play_named(bram_reply, "entry_mark", 0, 0), "the stamp before the gap")
	check(play_named(bram_reply, "entry_mark", 0, 2), "the stamp after the gap")
	check(play_named(bram_reply, "reply", 1, 0), "reply retriggers the stamp before the gap")
	check(bram_reply.last_chain_count == 1, "the reply still retriggers")
	check(bram_reply.last_progress_gained == 11, "a retrigger of a stamp that precedes a gap scores twice again (%d)" % bram_reply.last_progress_gained)

	var bram_block_echo = Rules.scripted_encounter(143, 2, ["echo", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_SPINE)
	check(play_named(bram_block_echo, "echo", 0, 0), "echo at the start of a block")
	check(play_named(bram_block_echo, "entry_mark", 0, 1), "the next cell")
	check(play_named(bram_block_echo, "entry_mark", 0, 2), "the last cell of the row")
	check(play_named(bram_block_echo, "entry_mark", 1, 0), "the first cell of the next row")
	check(bram_block_echo.last_chain_count == 1, "the echo still retriggers a contiguous stamp")
	check(bram_block_echo.last_progress_gained == 9, "a retrigger in a contiguous block does not double (%d)" % bram_block_echo.last_progress_gained)

	var bram_held = Rules.scripted_encounter(143, 2, ["hold", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(play_named(bram_held, "hold", 0, 0), "hold in Bram's column, before the gap")
	check(play_named(bram_held, "entry_mark", 0, 2), "the stamp after the gap")
	check(bram_held.last_progress_gained == 4, "the stamp before the gap still scores twice")
	check(bram_held.last_patience_loss == 0 and bram_held.patience == 5, "hold delays Bram")

	var bram_missed = Rules.scripted_encounter(143, 2, ["entry_mark", "hold"], 2, Rules.SHIFT_SPINE)
	check(play_named(bram_missed, "entry_mark", 0, 0), "the stamp before the gap")
	check(play_named(bram_missed, "hold", 0, 2), "hold outside Bram's column, after the gap")
	check(bram_missed.last_progress_gained == 5, "the outside hold scores its own number after the gap")
	check(bram_missed.last_patience_loss == 1, "hold in another column does not delay Bram")

	var sable_after = Rules.scripted_encounter(134, 3, ["entry_mark", "visa_dot"], 2, Rules.SHIFT_LEDGER)
	check(String(Rules.traveler(sable_after)["rule"]) == "double_after_gap", "Sable Quern still doubles the stamp after a gap")
	check(play_named(sable_after, "entry_mark", 0, 0), "Sable's stamp before the gap")
	check(play_named(sable_after, "visa_dot", 0, 2), "Sable's stamp after the gap")
	check(sable_after.last_progress_gained == 8, "the ledger bell still doubles the stamp after the gap, not the stamp before it (%d)" % sable_after.last_progress_gained)

	var solt_gap = Rules.scripted_encounter(114, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(String(Rules.traveler(solt_gap)["rule"]) == "yield_queue_gap", "Sable Solt still adds 2 to every stamp in a gap")
	check(play_named(solt_gap, "entry_mark", 0, 0), "Solt's stamp before the gap")
	check(play_named(solt_gap, "entry_mark", 0, 2), "Solt's stamp after the gap")
	check(solt_gap.last_progress_gained == 8, "the margin bell still adds 2 to every filled stamp (%d)" % solt_gap.last_progress_gained)

	var sera = Rules.scripted_encounter(144, 3, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_SPINE)
	check(String(Rules.traveler(sera)["name"]) == "Sera Pell", "the spine bell's fourth form is Sera Pell")
	check(String(Rules.traveler(sera)["form_name"]) == "Column Pair", "Sera brings the Column Pair")
	check(String(Rules.traveler(sera)["rule_text"]) == "When two filled stamps in the same column have exactly one empty cell between them, those two stamps each score +3 once. A third stamp in that column does not get the bonus unless it is one of such a pair.", "Sera's form states the column pair")
	check(int(Rules.traveler(sera)["lane"]) == 1 and int(Rules.traveler(sera)["exemption_row"]) == 2, "Sera waits in column 2 and exempts the bottom row")
	check(int(Rules.traveler(sera)["goal"]) == 24, "Sera's goal is 24")
	check(Rules.preview_progress(sera, "entry_mark", 0, 0) == 2, "preview leaves a lone column stamp at its own number")
	check(play_named(sera, "entry_mark", 0, 0), "the first of a column pair leaves Sera's turn open")
	check(sera.phase == "play", "Sera's first stamp does not end the turn")
	check(Rules.preview_progress(sera, "entry_mark", 0, 1) == 2, "preview leaves a stamp in another column at its own number")
	check(Rules.preview_progress(sera, "entry_mark", 1, 0) == 2, "preview leaves a contiguous stamp at its own number")
	check(Rules.preview_progress(sera, "entry_mark", 2, 0) == 5, "preview adds 3 to the stamp that completes the column pair")
	check(play_named(sera, "entry_mark", 0, 1), "Sera receives a stamp in another column, the wrong stamp")
	check(play_named(sera, "entry_mark", 2, 0), "Sera receives the other end of the column, the correct stamp")
	check(sera.last_progress_gained == 12, "the two paired stamps score +3 and the other column scores its own number (%d)" % sera.last_progress_gained)
	check(sera.last_patience_loss == 1, "a column pair does not change patience")

	var sera_pair = Rules.scripted_encounter(144, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(play_named(sera_pair, "entry_mark", 0, 0), "the top of the column")
	check(play_named(sera_pair, "entry_mark", 2, 0), "the bottom of the column, with the middle empty")
	check(sera_pair.last_progress_gained == 10, "both ends score +3 when the middle cell is empty (%d)" % sera_pair.last_progress_gained)

	var sera_touch = Rules.scripted_encounter(144, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(play_named(sera_touch, "entry_mark", 0, 0), "the top of the column")
	check(play_named(sera_touch, "entry_mark", 1, 0), "Sera receives a contiguous stamp, the wrong stamp")
	check(sera_touch.last_progress_gained == 4, "contiguous stamps in a column get no bonus (%d)" % sera_touch.last_progress_gained)

	var sera_split = Rules.scripted_encounter(144, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(play_named(sera_split, "entry_mark", 0, 0), "column 1")
	check(play_named(sera_split, "entry_mark", 2, 1), "the bottom of a different column")
	check(sera_split.last_progress_gained == 4, "stamps in different columns do not pair (%d)" % sera_split.last_progress_gained)

	var sera_full = Rules.scripted_encounter(144, 3, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_SPINE)
	check(play_named(sera_full, "entry_mark", 0, 0), "the top of a full column")
	check(play_named(sera_full, "entry_mark", 1, 0), "the middle, a third stamp")
	check(play_named(sera_full, "entry_mark", 2, 0), "the bottom of a full column")
	check(sera_full.last_progress_gained == 6, "a full column has no empty cell, so no stamp gains the bonus (%d)" % sera_full.last_progress_gained)

	var sera_columns = Rules.scripted_encounter(144, 3, ["entry_mark", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_SPINE)
	check(play_named(sera_columns, "entry_mark", 0, 0), "the first column's top")
	check(play_named(sera_columns, "entry_mark", 2, 0), "the first column's bottom")
	check(play_named(sera_columns, "entry_mark", 0, 2), "the other column's top")
	check(play_named(sera_columns, "entry_mark", 2, 2), "the other column's bottom")
	check(sera_columns.last_progress_gained == 20, "each column pair adds 3 to its own two stamps (%d)" % sera_columns.last_progress_gained)

	var sera_pressed = Rules.scripted_encounter(144, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(play_named(sera_pressed, "entry_mark", 2, 0), "the later end is pressed first")
	check(play_named(sera_pressed, "entry_mark", 0, 0), "the earlier end is pressed last")
	check(sera_pressed.last_progress_gained == 10, "both ends still score +3 (%d)" % sera_pressed.last_progress_gained)

	var sera_freed = Rules.scripted_encounter(144, 3, ["exemption", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(play_named(sera_freed, "entry_mark", 0, 0), "the top of the column")
	check(play_named(sera_freed, "exemption", 2, 0), "exemption is one end of the pair on Sera's bottom row")
	check(sera_freed.last_progress_gained == 3, "exemption on the bottom row cancels the bonus (%d)" % sera_freed.last_progress_gained)

	var sera_freed_side = Rules.scripted_encounter(144, 3, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_SPINE)
	check(play_named(sera_freed_side, "entry_mark", 0, 0), "the top of the column")
	check(play_named(sera_freed_side, "entry_mark", 2, 0), "the bottom of the column")
	check(play_named(sera_freed_side, "exemption", 2, 1), "exemption sits on the bottom row, in another column")
	check(sera_freed_side.last_progress_gained == 5, "exemption on the bottom row cancels the bonus in every column (%d)" % sera_freed_side.last_progress_gained)

	var sera_kept = Rules.scripted_encounter(144, 3, ["exemption", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(play_named(sera_kept, "exemption", 0, 0), "exemption is one end of the pair off the bottom row")
	check(play_named(sera_kept, "entry_mark", 2, 0), "the bottom of that column")
	check(sera_kept.last_progress_gained == 9, "an exemption pair off the bottom row still adds 3 (%d)" % sera_kept.last_progress_gained)

	var sera_kept_off = Rules.scripted_encounter(144, 3, ["entry_mark", "entry_mark", "exemption"], 3, Rules.SHIFT_SPINE)
	check(play_named(sera_kept_off, "entry_mark", 0, 0), "the top of the column")
	check(play_named(sera_kept_off, "entry_mark", 2, 0), "the bottom of the column")
	check(play_named(sera_kept_off, "exemption", 1, 1), "exemption sits off Sera's bottom row")
	check(sera_kept_off.last_progress_gained == 11, "an exemption off the bottom row leaves the bonus (%d)" % sera_kept_off.last_progress_gained)

	var sera_ripple = Rules.scripted_encounter(144, 3, ["entry_mark", "entry_mark", "ripple"], 4, Rules.SHIFT_SPINE)
	check(play_named(sera_ripple, "entry_mark", 0, 0), "one end of the pair")
	check(play_named(sera_ripple, "entry_mark", 2, 0), "the other end of the pair")
	check(play_named(sera_ripple, "ripple", 0, 1), "ripple beside the top of the pair")
	check(sera_ripple.last_chain_count == 1, "the ripple still retriggers")
	check(sera_ripple.last_progress_gained == 17, "a retrigger of a paired stamp adds 3 again (%d)" % sera_ripple.last_progress_gained)

	var sera_reply = Rules.scripted_encounter(144, 3, ["entry_mark", "entry_mark", "entry_mark", "reply"], 4, Rules.SHIFT_SPINE)
	check(play_named(sera_reply, "entry_mark", 0, 0), "one end of the pair")
	check(play_named(sera_reply, "entry_mark", 0, 1), "a stamp that is not in a pair")
	check(play_named(sera_reply, "reply", 1, 1), "reply retriggers that stamp")
	check(play_named(sera_reply, "entry_mark", 2, 0), "the other end of the pair")
	check(sera_reply.last_chain_count == 1, "the reply still retriggers")
	check(sera_reply.last_progress_gained == 15, "a retrigger of a stamp that is not in a pair scores its own number (%d)" % sera_reply.last_progress_gained)

	var sera_held = Rules.scripted_encounter(144, 3, ["hold", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(play_named(sera_held, "hold", 0, 1), "hold is one end of the pair in Sera's column")
	check(play_named(sera_held, "entry_mark", 2, 1), "the other end of that column")
	check(sera_held.last_progress_gained == 9, "the paired hold still adds 3")
	check(sera_held.last_patience_loss == 0 and sera_held.patience == 5, "hold delays Sera")

	var sera_missed = Rules.scripted_encounter(144, 3, ["hold", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(play_named(sera_missed, "hold", 0, 0), "hold is one end of a pair outside Sera's column")
	check(play_named(sera_missed, "entry_mark", 2, 0), "the other end of that column")
	check(sera_missed.last_progress_gained == 9, "the outside pair still adds 3")
	check(sera_missed.last_patience_loss == 1, "hold in another column does not delay Sera")

	var nell_row = Rules.scripted_encounter(131, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(String(Rules.traveler(nell_row)["rule"]) == "yield_row_wings", "Nell Voss still pays the wings of one row")
	check(play_named(nell_row, "entry_mark", 0, 0), "Nell's column 1")
	check(play_named(nell_row, "entry_mark", 0, 2), "Nell's column 3 of the same row")
	check(nell_row.last_progress_gained == 10, "the ledger bell still adds 3 to the wings of one row (%d)" % nell_row.last_progress_gained)

	var nell_column = Rules.scripted_encounter(131, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(nell_column, "entry_mark", 0, 0), "Nell's top of column 1")
	check(play_named(nell_column, "entry_mark", 2, 0), "Nell's bottom of column 1")
	check(nell_column.last_progress_gained == 4, "the ledger bell still does not bonus a column pair (%d)" % nell_column.last_progress_gained)


func test_spine_bell_opens() -> void:
	check(Rules.SPINE_BELL.size() == 4, "the spine bell has four travelers")
	check(String(Rules.SPINE_BELL[0]["name"]) == "Wynn Quill", "the spine bell begins with Wynn Quill")
	check(String(Rules.SPINE_BELL[1]["name"]) == "Ada Hart", "the spine bell's second traveler is Ada Hart")
	check(String(Rules.SPINE_BELL[2]["name"]) == "Bram Solt", "the spine bell's third traveler is Bram Solt")
	check(String(Rules.SPINE_BELL[3]["name"]) == "Sera Pell", "the spine bell ends with Sera Pell")
	check(Rules.LEDGER_BELL.size() == 4 and String(Rules.LEDGER_BELL[0]["name"]) == "Nell Voss", "the ledger bell still begins with Nell Voss")
	check(String(Rules.LEDGER_BELL[3]["name"]) == "Sable Quern", "the ledger bell still ends with Sable Quern")
	check(Rules.TRAVELERS.size() == 4 and String(Rules.TRAVELERS[0]["name"]) == "Ada Quill", "Act 1 still begins with Ada Quill")
	var spine_run = Rules.new_run(81, Rules.SHIFT_SPINE)
	check(spine_run.shift == Rules.SHIFT_SPINE, "the spine bell is a separate night")
	check(String(Rules.traveler(spine_run)["name"]) == "Wynn Quill", "the spine bell begins with Wynn Quill")
	check(spine_run.hand.size() == Rules.HAND_SIZE, "the spine bell draws 5")
	check(spine_run.ink == Rules.BASE_INK, "the spine bell starts at 3 ink")
	check(spine_run.library.size() == Rules.STARTING_DECK.size(), "the spine bell deals the starting deck")
	check(spine_run.relic_id == "", "an earlier night's relic does not carry")
	check(spine_run.phase == "play", "the spine bell opens in play")
	var dealt: Array = []
	for iid in spine_run.hand:
		dealt.append(Rules.card_id_of(spine_run, int(iid)))
	var before = spine_run.library.size()
	spine_run.progress = 4
	spine_run.patience = 1
	Rules.restart_encounter(spine_run)
	check(spine_run.shift == Rules.SHIFT_SPINE and spine_run.traveler_index == 0, "restart encounter stays on the spine bell")
	check(spine_run.progress == 0 and spine_run.patience == int(Rules.SPINE_BELL[0]["patience"]), "restart encounter resets Wynn")
	check(spine_run.library.size() == before and spine_run.hand.size() == 5 and spine_run.phase == "play", "restart keeps the spine-bell deck and deals a hand")
	var redealt: Array = []
	for iid in spine_run.hand:
		redealt.append(Rules.card_id_of(spine_run, int(iid)))
	check(redealt == dealt, "restart deals Wynn the same hand")

	var packed = load("res://game/main.tscn")
	var desk = packed.instantiate()
	root.add_child(desk)
	if desk.state == null:
		desk._ready()
	check(desk.state.shift == Rules.SHIFT_FIRST, "the desk still opens on Act 1")
	check(desk.spine_button.text == "Spine bell", "the desk offers the spine bell")
	check(desk.ledger_button.text == "Ledger bell", "the desk still offers the ledger bell")
	desk.spine_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_SPINE, "the desk can open the spine bell")
	check(String(Rules.traveler(desk.state)["name"]) == "Wynn Quill", "the open desk shows Wynn")
	check(String(desk.desk_label.text).begins_with("Spine bell"), "the desk title follows the spine bell")
	check(desk.meta_label.text.contains("High Slip"), "the desk shows Wynn's form")
	check(desk.spine_button.text == "First bell", "the spine bell can return to the first bell")
	check(desk.ledger_button.text == "Ledger bell", "the ledger bell stays available from the spine bell")
	check(desk.shift_button.text == "Late shift", "the late shift stays available from the spine bell")
	desk._restart_act()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_SPINE and String(Rules.traveler(desk.state)["name"]) == "Wynn Quill", "restart act replays the spine bell")
	desk.spine_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the spine bell returns to Ada")
	var doors = [
		["_begin_late_shift", "Nell Parr", "the late shift"],
		["_begin_closing_bell", "Moss Quen", "the closing bell"],
		["_begin_ash_watch", "Orla Fen", "the ash watch"],
		["_begin_gutter_lamp", "Ivo Dane", "the gutter lamp"],
		["_begin_vellum_bell", "Edda Voss", "the vellum bell"],
		["_begin_quire_watch", "Tess Quern", "the quire watch"],
		["_begin_salt_watch", "Pell Voss", "the salt watch"],
		["_begin_quay_bell", "Mara Quill", "the quay bell"],
		["_begin_folio_bell", "Ness Hart", "the folio bell"],
		["_begin_wick_bell", "Odell Voss", "the wick bell"],
		["_begin_margin_bell", "Nim Voss", "the margin bell"],
		["_begin_index_bell", "Len Quill", "the index bell"],
		["_begin_ledger_bell", "Nell Voss", "the ledger bell"],
	]
	for door in doors:
		desk.call(String(door[0]))
		desk._refresh_ui()
		check(desk.state.shift != Rules.SHIFT_SPINE and String(Rules.traveler(desk.state)["name"]) == String(door[1]), "%s still opens" % String(door[2]))
		check(desk.spine_button.text == "Spine bell", "%s offers the spine bell" % String(door[2]))
		desk._begin_spine_bell()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_SPINE and String(Rules.traveler(desk.state)["name"]) == "Wynn Quill", "%s can open the spine bell" % String(door[2]))
	desk._begin_first_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "first bell still returns to Ada")
	var victories = [
		[Rules.SHIFT_FIRST, "Act 1"],
		[Rules.SHIFT_LATE, "the late shift"],
		[Rules.SHIFT_CLOSING, "the closing bell"],
		[Rules.SHIFT_ASH, "the ash watch"],
		[Rules.SHIFT_GUTTER, "the gutter lamp"],
		[Rules.SHIFT_VELLUM, "the vellum bell"],
		[Rules.SHIFT_QUIRE, "the quire watch"],
		[Rules.SHIFT_SALT, "the salt watch"],
		[Rules.SHIFT_QUAY, "the quay bell"],
		[Rules.SHIFT_FOLIO, "the folio bell"],
		[Rules.SHIFT_WICK, "the wick bell"],
		[Rules.SHIFT_MARGIN, "the margin bell"],
		[Rules.SHIFT_INDEX, "the index bell"],
		[Rules.SHIFT_LEDGER, "the ledger bell"],
	]
	for victory in victories:
		desk._open_shift(int(victory[0]), desk.state.seed)
		desk._refresh_ui()
		desk.state.phase = "victory"
		desk._refresh_ui()
		var victory_spine = _button_named(desk, "Open the spine bell")
		check(victory_spine != null, "%s's victory desk offers the spine bell" % String(victory[1]))
		if victory_spine != null:
			victory_spine.pressed.emit()
			desk._refresh_ui()
			check(desk.state.shift == Rules.SHIFT_SPINE and String(Rules.traveler(desk.state)["name"]) == "Wynn Quill", "%s's victory desk opens the spine bell" % String(victory[1]))
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_first = _button_named(desk, "Open the first bell")
	check(victory_first != null, "the spine bell victory desk offers the first bell")
	if victory_first != null:
		victory_first.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the spine bell victory desk opens the first bell")
	desk._begin_spine_bell()
	desk._refresh_ui()
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_ledger = _button_named(desk, "Open the ledger bell")
	check(victory_ledger != null, "the spine bell victory desk offers the ledger bell")
	if victory_ledger != null:
		victory_ledger.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_LEDGER and String(Rules.traveler(desk.state)["name"]) == "Nell Voss", "the spine bell victory desk opens the ledger bell")
	root.remove_child(desk)
	desk.free()


func test_policy_clears_spine_bell() -> void:
	var started = Time.get_ticks_msec()
	var state = Rules.new_run(12345, Rules.SHIFT_SPINE)
	var steps = 0
	var seen = 0
	while state.phase != "victory":
		steps += 1
		if steps > 500 or state.phase == "defeat":
			check(false, "policy lost or stalled on the spine bell, seed 12345: " + Rules.debug_summary(state))
			return
		var action = Policy.choose(state)
		if not Rules.apply_action(state, action):
			check(false, "spine-bell policy action was rejected: %s / %s" % [str(action), Rules.debug_summary(state)])
			return
		if state.encounters_cleared != seen:
			seen = state.encounters_cleared
			print("cleared spine encounter %d after %d actions" % [seen, steps])
	var elapsed = Time.get_ticks_msec() - started
	check(state.encounters_cleared == 4, "policy cleared all 4 spine-bell encounters on seed 12345")
	check(state.phase == "victory", "spine bell ends in victory")
	check(state.shift == Rules.SHIFT_SPINE, "the clear stayed on the spine bell")
	print("spine bell finished in %d actions, %d ms" % [steps, elapsed])


func test_headband_bell_rules() -> void:
	var len = Rules.scripted_encounter(151, 0, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_HEADBAND)
	check(String(Rules.traveler(len)["name"]) == "Len Hart", "the headband bell's first form is Len Hart")
	check(String(Rules.traveler(len)["form_name"]) == "Open Wing", "Len brings the Open Wing")
	check(String(Rules.traveler(len)["rule_text"]) == "When column 1 and column 3 of the same row are both filled and column 2 of that row is empty, those two stamps each score +3 once. If column 2 of that row is filled, that row gets no bonus.", "Len's form states the open wing")
	check(int(Rules.traveler(len)["lane"]) == 0 and int(Rules.traveler(len)["exemption_row"]) == 0, "Len waits in column 1 and exempts the top row")
	check(int(Rules.traveler(len)["goal"]) == 18, "Len's goal is 18")
	check(Rules.preview_progress(len, "entry_mark", 0, 0) == 2, "preview leaves a lone wing at its own number")
	check(play_named(len, "entry_mark", 0, 0), "the first wing leaves Len's turn open")
	check(len.phase == "play", "Len's first stamp does not end the turn")
	check(Rules.preview_progress(len, "entry_mark", 1, 1) == 2, "preview leaves a stamp off the open row at its own number")
	check(Rules.preview_progress(len, "entry_mark", 0, 2) == 5, "preview adds 3 to the stamp that completes the open wing")
	check(play_named(len, "entry_mark", 1, 1), "Len receives a stamp in another row, the wrong stamp")
	check(play_named(len, "entry_mark", 0, 2), "Len receives the other wing, the correct stamp")
	check(len.last_progress_gained == 12, "the two open wings score +3 and the other row scores its own number (%d)" % len.last_progress_gained)
	check(len.last_patience_loss == 1, "an open wing does not change patience")

	var len_closed = Rules.scripted_encounter(151, 0, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_HEADBAND)
	check(play_named(len_closed, "entry_mark", 0, 0), "one wing of a row")
	check(play_named(len_closed, "entry_mark", 0, 1), "Len receives column 2 of that row, the wrong stamp")
	check(play_named(len_closed, "entry_mark", 0, 2), "the other wing beside a filled column 2")
	check(len_closed.last_progress_gained == 6, "a filled column 2 cancels that row, and column 2 gets no bonus (%d)" % len_closed.last_progress_gained)

	var len_one = Rules.scripted_encounter(151, 0, ["entry_mark"], 1, Rules.SHIFT_HEADBAND)
	check(play_named(len_one, "entry_mark", 0, 0), "Len receives a single wing")
	check(len_one.last_progress_gained == 2, "a row with only one wing filled gets no bonus (%d)" % len_one.last_progress_gained)

	var len_spine = Rules.scripted_encounter(151, 0, ["entry_mark"], 1, Rules.SHIFT_HEADBAND)
	check(play_named(len_spine, "entry_mark", 0, 1), "Len receives a stamp in column 2")
	check(len_spine.last_progress_gained == 2, "column 2 never receives the open-wing bonus (%d)" % len_spine.last_progress_gained)

	var len_column = Rules.scripted_encounter(151, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(len_column, "entry_mark", 0, 0), "the top of column 1")
	check(play_named(len_column, "entry_mark", 2, 0), "the bottom of column 1")
	check(len_column.last_progress_gained == 4, "stamps in one column are not an open wing (%d)" % len_column.last_progress_gained)

	var len_rows = Rules.scripted_encounter(151, 0, ["entry_mark", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_HEADBAND)
	check(play_named(len_rows, "entry_mark", 0, 0), "the first row's column 1")
	check(play_named(len_rows, "entry_mark", 0, 2), "the first row's column 3")
	check(play_named(len_rows, "entry_mark", 2, 0), "the other row's column 1")
	check(play_named(len_rows, "entry_mark", 2, 2), "the other row's column 3")
	check(len_rows.last_progress_gained == 20, "each open row adds 3 to its own two wings (%d)" % len_rows.last_progress_gained)
	check(len_rows.last_won, "two open rows clear Len")

	var len_pressed = Rules.scripted_encounter(151, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(len_pressed, "entry_mark", 0, 2), "the later wing is pressed first")
	check(play_named(len_pressed, "entry_mark", 0, 0), "the earlier wing is pressed last")
	check(len_pressed.last_progress_gained == 10, "both wings still score +3 (%d)" % len_pressed.last_progress_gained)

	var len_muted = Rules.scripted_encounter(151, 0, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_HEADBAND)
	check(play_named(len_muted, "exemption", 0, 1), "exemption is placed on Len's top row")
	check(play_named(len_muted, "entry_mark", 2, 0), "one wing of the bottom row")
	check(play_named(len_muted, "entry_mark", 2, 2), "the other wing of the bottom row")
	check(len_muted.last_progress_gained == 5, "exemption on the top row cancels the bonus (%d)" % len_muted.last_progress_gained)

	var len_kept = Rules.scripted_encounter(151, 0, ["exemption", "entry_mark"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(len_kept, "exemption", 2, 0), "exemption is one wing off Len's top row")
	check(play_named(len_kept, "entry_mark", 2, 2), "the other wing of that row")
	check(len_kept.last_progress_gained == 9, "an exemption wing off the top row still adds 3 (%d)" % len_kept.last_progress_gained)

	var len_kept_off = Rules.scripted_encounter(151, 0, ["entry_mark", "entry_mark", "exemption"], 3, Rules.SHIFT_HEADBAND)
	check(play_named(len_kept_off, "entry_mark", 0, 0), "one open wing")
	check(play_named(len_kept_off, "entry_mark", 0, 2), "the other open wing")
	check(play_named(len_kept_off, "exemption", 2, 1), "exemption sits off Len's top row")
	check(len_kept_off.last_progress_gained == 11, "an exemption off the top row leaves the bonus (%d)" % len_kept_off.last_progress_gained)

	var len_ripple = Rules.scripted_encounter(151, 0, ["entry_mark", "entry_mark", "ripple"], 4, Rules.SHIFT_HEADBAND)
	check(play_named(len_ripple, "entry_mark", 0, 0), "one open wing")
	check(play_named(len_ripple, "entry_mark", 0, 2), "the other open wing")
	check(play_named(len_ripple, "ripple", 1, 0), "ripple retriggers one open wing")
	check(len_ripple.last_chain_count == 1, "the ripple still retriggers")
	check(len_ripple.last_progress_gained == 17, "a retrigger of an open wing adds 3 again (%d)" % len_ripple.last_progress_gained)

	var len_reply = Rules.scripted_encounter(151, 0, ["entry_mark", "entry_mark", "entry_mark", "reply"], 4, Rules.SHIFT_HEADBAND)
	check(play_named(len_reply, "entry_mark", 0, 0), "a stamp that is not an open wing")
	check(play_named(len_reply, "reply", 1, 0), "reply retriggers that stamp")
	check(play_named(len_reply, "entry_mark", 2, 0), "one open wing")
	check(play_named(len_reply, "entry_mark", 2, 2), "the other open wing")
	check(len_reply.last_chain_count == 1, "the reply still retriggers")
	check(len_reply.last_progress_gained == 15, "a retrigger of a stamp that is not an open wing scores its own number (%d)" % len_reply.last_progress_gained)

	var len_held = Rules.scripted_encounter(151, 0, ["hold", "entry_mark"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(len_held, "hold", 0, 0), "hold is one open wing in Len's column")
	check(play_named(len_held, "entry_mark", 0, 2), "the other wing of that row")
	check(len_held.last_progress_gained == 9, "the paired hold still adds 3")
	check(len_held.last_patience_loss == 0 and len_held.patience == 5, "hold delays Len")

	var len_missed = Rules.scripted_encounter(151, 0, ["hold", "entry_mark"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(len_missed, "entry_mark", 0, 0), "one open wing in Len's column")
	check(play_named(len_missed, "hold", 0, 2), "hold is the other wing, outside Len's column")
	check(len_missed.last_progress_gained == 9, "the outside wing still adds 3")
	check(len_missed.last_patience_loss == 1, "hold in another column does not delay Len")

	var nell_open = Rules.scripted_encounter(131, 0, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LEDGER)
	check(String(Rules.traveler(nell_open)["rule"]) == "yield_row_wings", "Nell Voss still pays the wings of one row")
	check(play_named(nell_open, "entry_mark", 0, 0), "Nell's column 1")
	check(play_named(nell_open, "entry_mark", 0, 1), "Nell's filled column 2")
	check(play_named(nell_open, "entry_mark", 0, 2), "Nell's column 3")
	check(nell_open.last_progress_gained == 12, "the ledger bell still pays the wings when the middle of the row is filled (%d)" % nell_open.last_progress_gained)

	var joss = Rules.scripted_encounter(152, 1, ["entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 5, Rules.SHIFT_HEADBAND)
	check(String(Rules.traveler(joss)["name"]) == "Joss Pell", "the headband bell's second form is Joss Pell")
	check(String(Rules.traveler(joss)["form_name"]) == "Five Toll", "Joss brings the Five Toll")
	check(String(Rules.traveler(joss)["rule_text"]) == "Patience drops by 2 when exactly five cells are filled.", "Joss's form states the five toll")
	check(int(Rules.traveler(joss)["lane"]) == 2 and int(Rules.traveler(joss)["exemption_row"]) == 2, "Joss waits in column 3 and exempts the bottom row")
	check(int(Rules.traveler(joss)["goal"]) == 14, "Joss's goal is 14")
	check(Rules.preview_progress(joss, "duty", 2, 2) == 4, "preview leaves a duty at its own number")
	check(play_named(joss, "entry_mark", 0, 0), "the first stamp leaves Joss's turn open")
	check(joss.phase == "play", "Joss's first stamp does not end the turn")
	check(play_named(joss, "entry_mark", 0, 1), "the second stamp")
	check(play_named(joss, "entry_mark", 0, 2), "the third stamp")
	check(play_named(joss, "entry_mark", 1, 0), "the fourth stamp, the correct count")
	check(play_named(joss, "entry_mark", 1, 1), "Joss receives the fifth stamp, the wrong stamp")
	check(joss.last_progress_gained == 10, "exactly five stamps score their own numbers (%d)" % joss.last_progress_gained)
	check(joss.last_patience_loss == 2 and joss.patience == 3, "exactly five cells drop patience by 2")

	var joss_four = Rules.scripted_encounter(152, 1, ["entry_mark", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_HEADBAND)
	check(play_named(joss_four, "entry_mark", 0, 0), "the first of four")
	check(play_named(joss_four, "entry_mark", 0, 1), "the second of four")
	check(play_named(joss_four, "entry_mark", 0, 2), "the third of four")
	check(play_named(joss_four, "entry_mark", 1, 0), "Joss receives the fourth stamp, the correct stamp")
	check(joss_four.last_progress_gained == 8, "exactly four stamps score their own numbers (%d)" % joss_four.last_progress_gained)
	check(joss_four.last_patience_loss == 1 and joss_four.patience == 4, "a form of four keeps the drop at 1")

	var joss_three = Rules.scripted_encounter(152, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_HEADBAND)
	check(play_named(joss_three, "entry_mark", 0, 0), "the first of three")
	check(play_named(joss_three, "entry_mark", 0, 1), "the second of three")
	check(play_named(joss_three, "entry_mark", 0, 2), "Joss receives the third stamp")
	check(joss_three.last_progress_gained == 6, "exactly three stamps score their own numbers (%d)" % joss_three.last_progress_gained)
	check(joss_three.last_patience_loss == 1, "a form of three keeps the drop at 1")

	var joss_one = Rules.scripted_encounter(152, 1, ["duty"], 1, Rules.SHIFT_HEADBAND)
	check(play_named(joss_one, "duty", 2, 1), "Joss receives one bottom-row duty")
	check(joss_one.last_progress_gained == 4, "one stamp scores its own number (%d)" % joss_one.last_progress_gained)
	check(joss_one.last_patience_loss == 1, "one stamp keeps the drop at 1")

	var joss_two = Rules.scripted_encounter(152, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(joss_two, "entry_mark", 0, 0), "the first of two")
	check(play_named(joss_two, "entry_mark", 0, 1), "Joss receives the second stamp")
	check(joss_two.last_progress_gained == 4, "exactly two stamps score their own numbers (%d)" % joss_two.last_progress_gained)
	check(joss_two.last_patience_loss == 1, "a form of two keeps the drop at 1")

	var joss_six = Rules.scripted_encounter(152, 1, ["entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 6, Rules.SHIFT_HEADBAND)
	check(play_named(joss_six, "entry_mark", 0, 0), "the first of six")
	check(play_named(joss_six, "entry_mark", 0, 1), "the second of six")
	check(play_named(joss_six, "entry_mark", 0, 2), "the third of six")
	check(play_named(joss_six, "entry_mark", 1, 0), "the fourth of six")
	check(play_named(joss_six, "entry_mark", 1, 1), "the fifth of six")
	check(play_named(joss_six, "entry_mark", 1, 2), "Joss receives a sixth stamp")
	check(joss_six.last_progress_gained == 12, "six stamps score their own numbers (%d)" % joss_six.last_progress_gained)
	check(joss_six.last_patience_loss == 1, "a form of six keeps the drop at 1")

	var joss_scored = Rules.scripted_encounter(152, 1, ["duty", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 5, Rules.SHIFT_HEADBAND)
	check(play_named(joss_scored, "duty", 2, 0), "a bottom-row duty")
	check(play_named(joss_scored, "entry_mark", 0, 0), "an entry mark")
	check(play_named(joss_scored, "entry_mark", 0, 1), "a second entry mark")
	check(play_named(joss_scored, "entry_mark", 0, 2), "a third entry mark")
	check(play_named(joss_scored, "entry_mark", 1, 0), "a fourth entry mark")
	check(joss_scored.last_progress_gained == 12, "the toll does not change the score (%d)" % joss_scored.last_progress_gained)
	check(joss_scored.last_patience_loss == 2, "five stamps still drop patience by 2")

	var joss_empty = Rules.scripted_encounter(152, 1, ["entry_mark"], 3, Rules.SHIFT_HEADBAND)
	Rules.end_turn(joss_empty)
	check(joss_empty.last_progress_gained == 0, "an empty form scores nothing")
	check(joss_empty.last_patience_loss == 1, "an empty form keeps the drop at 1")

	var joss_held = Rules.scripted_encounter(152, 1, ["hold", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 5, Rules.SHIFT_HEADBAND)
	check(play_named(joss_held, "entry_mark", 0, 0), "a stamp outside the lane")
	check(play_named(joss_held, "entry_mark", 0, 1), "a second stamp")
	check(play_named(joss_held, "entry_mark", 1, 0), "a third stamp")
	check(play_named(joss_held, "entry_mark", 1, 1), "a fourth stamp")
	check(play_named(joss_held, "hold", 1, 2), "hold in Joss's column")
	check(joss_held.last_progress_gained == 9, "the held turn still scores the stamps")
	check(joss_held.last_patience_loss == 0 and joss_held.patience == 5, "hold is applied before the five toll")

	var joss_missed = Rules.scripted_encounter(152, 1, ["hold", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 5, Rules.SHIFT_HEADBAND)
	check(play_named(joss_missed, "hold", 0, 0), "hold outside Joss's column")
	check(play_named(joss_missed, "entry_mark", 0, 1), "a stamp")
	check(play_named(joss_missed, "entry_mark", 0, 2), "a second stamp")
	check(play_named(joss_missed, "entry_mark", 1, 0), "a third stamp")
	check(play_named(joss_missed, "entry_mark", 1, 1), "the fifth stamp")
	check(joss_missed.last_progress_gained == 9, "the outside hold still scores 1")
	check(joss_missed.last_patience_loss == 2, "hold in another column does not stop the five toll")

	var joss_spared = Rules.scripted_encounter(152, 1, ["exemption", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 5, Rules.SHIFT_HEADBAND)
	check(play_named(joss_spared, "entry_mark", 0, 0), "a stamp")
	check(play_named(joss_spared, "entry_mark", 0, 1), "a second stamp")
	check(play_named(joss_spared, "entry_mark", 0, 2), "a third stamp")
	check(play_named(joss_spared, "entry_mark", 1, 0), "a fourth stamp")
	check(play_named(joss_spared, "exemption", 2, 0), "exemption is placed on Joss's bottom row")
	check(joss_spared.last_progress_gained == 9, "the exempted stamps still score")
	check(joss_spared.last_patience_loss == 1, "exemption on the bottom row keeps the drop at 1")

	var joss_open = Rules.scripted_encounter(152, 1, ["exemption", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 5, Rules.SHIFT_HEADBAND)
	check(play_named(joss_open, "exemption", 0, 0), "exemption sits off Joss's bottom row")
	check(play_named(joss_open, "entry_mark", 0, 1), "a stamp beside that exemption")
	check(play_named(joss_open, "entry_mark", 0, 2), "a third stamp")
	check(play_named(joss_open, "entry_mark", 1, 0), "a fourth stamp")
	check(play_named(joss_open, "entry_mark", 1, 1), "the fifth stamp")
	check(joss_open.last_progress_gained == 9, "the off-row exemption still scores")
	check(joss_open.last_patience_loss == 2, "an exemption off the bottom row leaves the drop at 2")

	var ada_four = Rules.scripted_encounter(142, 1, ["entry_mark", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_SPINE)
	check(String(Rules.traveler(ada_four)["rule"]) == "drop_if_exact_four", "Ada Hart still tolls exactly four stamps")
	check(play_named(ada_four, "entry_mark", 0, 0), "Ada's first of four")
	check(play_named(ada_four, "entry_mark", 0, 1), "Ada's second of four")
	check(play_named(ada_four, "entry_mark", 0, 2), "Ada's third of four")
	check(play_named(ada_four, "entry_mark", 1, 0), "Ada's fourth stamp")
	check(ada_four.last_patience_loss == 2, "the spine bell still drops patience by 2 for exactly four cells")

	var ada_five = Rules.scripted_encounter(142, 1, ["entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 5, Rules.SHIFT_SPINE)
	check(play_named(ada_five, "entry_mark", 0, 0), "Ada's first of five")
	check(play_named(ada_five, "entry_mark", 0, 1), "Ada's second of five")
	check(play_named(ada_five, "entry_mark", 0, 2), "Ada's third of five")
	check(play_named(ada_five, "entry_mark", 1, 0), "Ada's fourth of five")
	check(play_named(ada_five, "entry_mark", 1, 1), "Ada's fifth stamp")
	check(ada_five.last_patience_loss == 1, "the spine bell still keeps the drop at 1 for a form of five")

	var pell_three = Rules.scripted_encounter(132, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LEDGER)
	check(String(Rules.traveler(pell_three)["rule"]) == "drop_if_exact_three", "Pell Dane still tolls exactly three stamps")
	check(play_named(pell_three, "entry_mark", 0, 0), "Pell's first stamp")
	check(play_named(pell_three, "entry_mark", 0, 1), "Pell's second stamp")
	check(play_named(pell_three, "entry_mark", 0, 2), "Pell's third stamp")
	check(pell_three.last_patience_loss == 2, "the ledger bell still drops patience by 2 for exactly three cells")

	var pell_five = Rules.scripted_encounter(132, 1, ["entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 5, Rules.SHIFT_LEDGER)
	check(play_named(pell_five, "entry_mark", 0, 0), "Pell's first of five")
	check(play_named(pell_five, "entry_mark", 0, 1), "Pell's second of five")
	check(play_named(pell_five, "entry_mark", 0, 2), "Pell's third of five")
	check(play_named(pell_five, "entry_mark", 1, 0), "Pell's fourth of five")
	check(play_named(pell_five, "entry_mark", 1, 1), "Pell's fifth stamp")
	check(pell_five.last_patience_loss == 1, "the ledger bell still keeps the drop at 1 for a form of five")

	var ida = Rules.scripted_encounter(153, 2, ["entry_mark", "visa_dot"], 2, Rules.SHIFT_HEADBAND)
	check(String(Rules.traveler(ida)["name"]) == "Ida Quill", "the headband bell's third form is Ida Quill")
	check(String(Rules.traveler(ida)["form_name"]) == "Late High", "Ida brings the Late High")
	check(String(Rules.traveler(ida)["rule_text"]) == "When two or more stamps are filled, the latest stamp among those showing the highest number scores twice. A lone stamp scores its own number.", "Ida's form states the late high")
	check(int(Rules.traveler(ida)["lane"]) == 1 and int(Rules.traveler(ida)["exemption_row"]) == 0, "Ida waits in column 2 and exempts the top row")
	check(int(Rules.traveler(ida)["goal"]) == 22, "Ida's goal is 22")
	check(Rules.preview_progress(ida, "entry_mark", 0, 0) == 2, "preview leaves a lone stamp at its own number")
	check(play_named(ida, "entry_mark", 0, 0), "the lower stamp leaves Ida's turn open, the wrong stamp")
	check(ida.phase == "play", "Ida's first stamp does not end the turn")
	check(Rules.preview_progress(ida, "visa_dot", 0, 1) == 6, "preview doubles the later highest number, the correct stamp")
	check(play_named(ida, "visa_dot", 0, 1), "Ida receives the later highest stamp, the correct stamp")
	check(ida.last_progress_gained == 8, "the later highest stamp scores twice and the lower stamp scores its own number (%d)" % ida.last_progress_gained)
	check(ida.last_patience_loss == 1, "the late high does not change patience")

	var ida_early = Rules.scripted_encounter(153, 2, ["visa_dot", "entry_mark"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(ida_early, "visa_dot", 0, 0), "the only stamp showing the highest number, the correct stamp")
	check(Rules.preview_progress(ida_early, "entry_mark", 0, 1) == 2, "preview leaves the later lower stamp at its own number")
	check(play_named(ida_early, "entry_mark", 0, 1), "Ida receives the later lower stamp, the wrong stamp")
	check(ida_early.last_progress_gained == 8, "a unique highest stamp doubles even when a later stamp is lower (%d)" % ida_early.last_progress_gained)

	var ida_lone = Rules.scripted_encounter(153, 2, ["entry_mark"], 1, Rules.SHIFT_HEADBAND)
	check(play_named(ida_lone, "entry_mark", 1, 1), "Ida receives a lone stamp")
	check(ida_lone.last_progress_gained == 2, "a lone stamp scores its own number (%d)" % ida_lone.last_progress_gained)

	var ida_shared = Rules.scripted_encounter(153, 2, ["visa_dot", "visa_dot"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(ida_shared, "visa_dot", 0, 0), "the earlier of two stamps showing the highest number, the wrong stamp")
	check(Rules.preview_progress(ida_shared, "visa_dot", 0, 1) == 6, "preview doubles the later of a shared highest number")
	check(play_named(ida_shared, "visa_dot", 0, 1), "the later stamp showing that same number, the correct stamp")
	check(ida_shared.last_progress_gained == 9, "only the later of a shared highest number doubles (%d)" % ida_shared.last_progress_gained)

	var ida_duties = Rules.scripted_encounter(153, 2, ["duty", "duty"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(ida_duties, "duty", 2, 0), "the earlier bottom-row duty")
	check(Rules.preview_progress(ida_duties, "duty", 2, 2) == 8, "preview doubles the later duty when both show the highest number")
	check(play_named(ida_duties, "duty", 2, 2), "the later bottom-row duty, the correct stamp")
	check(ida_duties.last_progress_gained == 12, "only the later duty doubles when the same card shares a number (%d)" % ida_duties.last_progress_gained)

	var ida_fed = Rules.scripted_encounter(153, 2, ["entry_mark", "surcharge"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(ida_fed, "entry_mark", 0, 0), "the stamp above a surcharge")
	check(Rules.preview_progress(ida_fed, "surcharge", 1, 0) == 10, "preview doubles the surcharge once the cell above makes it the highest number")
	check(play_named(ida_fed, "surcharge", 1, 0), "the fed surcharge, the correct stamp")
	check(ida_fed.last_progress_gained == 12, "a number is the progress the stamp already grants (%d)" % ida_fed.last_progress_gained)

	var ida_only = Rules.scripted_encounter(153, 2, ["wax_seal", "duty"], 3, Rules.SHIFT_HEADBAND)
	check(play_named(ida_only, "wax_seal", 0, 0), "the only stamp showing the highest number")
	check(play_named(ida_only, "duty", 2, 2), "a later stamp with a lower number")
	check(ida_only.last_progress_gained == 16, "the only highest stamp doubles even when it is earlier (%d)" % ida_only.last_progress_gained)

	var ida_pressed = Rules.scripted_encounter(153, 2, ["entry_mark", "visa_dot"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(ida_pressed, "visa_dot", 0, 1), "the later cell is pressed first")
	check(play_named(ida_pressed, "entry_mark", 0, 0), "the earlier cell is pressed last")
	check(ida_pressed.last_progress_gained == 8, "queue order, not press order, finds the latest highest stamp (%d)" % ida_pressed.last_progress_gained)

	var ida_muted = Rules.scripted_encounter(153, 2, ["exemption", "visa_dot"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(ida_muted, "exemption", 0, 0), "exemption is placed on Ida's top row")
	check(play_named(ida_muted, "visa_dot", 0, 1), "a later higher stamp")
	check(ida_muted.last_progress_gained == 4, "exemption on the top row cancels the doubling (%d)" % ida_muted.last_progress_gained)

	var ida_later = Rules.scripted_encounter(153, 2, ["entry_mark", "exemption", "visa_dot"], 3, Rules.SHIFT_HEADBAND)
	check(play_named(ida_later, "entry_mark", 0, 0), "an earlier stamp")
	check(play_named(ida_later, "exemption", 0, 1), "exemption is later on the top row")
	check(play_named(ida_later, "visa_dot", 0, 2), "the later highest stamp")
	check(ida_later.last_progress_gained == 6, "a later exemption on the top row still cancels the doubling (%d)" % ida_later.last_progress_gained)

	var ida_kept = Rules.scripted_encounter(153, 2, ["entry_mark", "visa_dot", "exemption"], 3, Rules.SHIFT_HEADBAND)
	check(play_named(ida_kept, "entry_mark", 0, 0), "a lower stamp")
	check(play_named(ida_kept, "visa_dot", 0, 1), "the later highest stamp")
	check(play_named(ida_kept, "exemption", 2, 0), "exemption sits off Ida's top row")
	check(ida_kept.last_progress_gained == 9, "an exemption off the top row still doubles the latest highest stamp (%d)" % ida_kept.last_progress_gained)

	var ida_same = Rules.scripted_encounter(153, 2, ["hold", "echo"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(ida_same, "hold", 0, 0), "the earlier of two stamps showing 1")
	check(Rules.preview_progress(ida_same, "echo", 0, 1) == 2, "preview doubles the later stamp showing that number")
	check(play_named(ida_same, "echo", 0, 1), "the later stamp showing the same number, the correct stamp")
	check(ida_same.last_progress_gained == 3, "only the later of a shared highest number doubles (%d)" % ida_same.last_progress_gained)
	check(ida_same.last_patience_loss == 1, "hold outside Ida's column does not delay her")

	var ida_reply = Rules.scripted_encounter(153, 2, ["entry_mark", "visa_dot", "reply"], 3, Rules.SHIFT_HEADBAND)
	check(play_named(ida_reply, "entry_mark", 0, 0), "a lower stamp")
	check(play_named(ida_reply, "visa_dot", 0, 1), "the latest highest stamp")
	check(play_named(ida_reply, "reply", 1, 1), "a later reply that retriggers it")
	check(ida_reply.last_chain_count == 1, "the reply still retriggers")
	check(ida_reply.last_progress_gained == 15, "a retrigger of the latest highest stamp scores twice again (%d)" % ida_reply.last_progress_gained)

	var ida_echo = Rules.scripted_encounter(153, 2, ["echo", "entry_mark", "visa_dot"], 3, Rules.SHIFT_HEADBAND)
	check(play_named(ida_echo, "echo", 0, 0), "echo is not the highest stamp")
	check(play_named(ida_echo, "entry_mark", 1, 0), "the stamp under the echo")
	check(play_named(ida_echo, "visa_dot", 0, 2), "the latest highest stamp")
	check(ida_echo.last_chain_count == 1, "the echo still retriggers")
	check(ida_echo.last_progress_gained == 11, "a retrigger of any other stamp does not double (%d)" % ida_echo.last_progress_gained)

	var ida_held = Rules.scripted_encounter(153, 2, ["visa_dot", "hold"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(ida_held, "visa_dot", 0, 2), "the latest highest stamp")
	check(play_named(ida_held, "hold", 1, 1), "hold in Ida's column")
	check(ida_held.last_progress_gained == 7, "the highest stamp still scores twice beside the hold")
	check(ida_held.last_patience_loss == 0 and ida_held.patience == 5, "hold delays Ida")

	var ida_missed = Rules.scripted_encounter(153, 2, ["hold", "visa_dot"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(ida_missed, "hold", 0, 0), "hold outside Ida's column")
	check(play_named(ida_missed, "visa_dot", 0, 2), "a higher later stamp")
	check(ida_missed.last_progress_gained == 7, "the higher stamp still doubles when the hold is earlier")
	check(ida_missed.last_patience_loss == 1, "hold in another column does not delay Ida")

	var wynn_early = Rules.scripted_encounter(141, 0, ["visa_dot", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(String(Rules.traveler(wynn_early)["rule"]) == "double_highest_earliest", "Wynn Quill still doubles the earliest highest number")
	check(play_named(wynn_early, "visa_dot", 0, 0), "Wynn's earlier highest stamp")
	check(play_named(wynn_early, "entry_mark", 0, 1), "Wynn's later lower stamp")
	check(wynn_early.last_progress_gained == 8, "the spine bell still doubles the earlier highest number, not the later one (%d)" % wynn_early.last_progress_gained)

	var wynn_shared = Rules.scripted_encounter(141, 0, ["visa_dot", "visa_dot"], 2, Rules.SHIFT_SPINE)
	check(play_named(wynn_shared, "visa_dot", 0, 0), "Wynn's earlier shared number")
	check(Rules.preview_progress(wynn_shared, "visa_dot", 0, 1) == 3, "preview leaves Wynn's later shared number at its own number")
	check(play_named(wynn_shared, "visa_dot", 0, 1), "Wynn's later shared number")
	check(wynn_shared.last_progress_gained == 9, "the spine bell still doubles the earlier of a shared highest number (%d)" % wynn_shared.last_progress_gained)

	var cal = Rules.scripted_encounter(154, 3, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_HEADBAND)
	check(String(Rules.traveler(cal)["name"]) == "Cal Quern", "the headband bell's fourth form is Cal Quern")
	check(String(Rules.traveler(cal)["form_name"]) == "Diagonal Pair", "Cal brings the Diagonal Pair")
	check(String(Rules.traveler(cal)["rule_text"]) == "When two filled stamps on one three-cell diagonal have exactly one empty cell between them, those two each score +3 once. A filled center means neither pair qualifies.", "Cal's form states the diagonal pair")
	check(int(Rules.traveler(cal)["lane"]) == 1 and int(Rules.traveler(cal)["exemption_row"]) == 1, "Cal waits in column 2 and exempts the middle row")
	check(int(Rules.traveler(cal)["goal"]) == 20, "Cal's goal is 20")
	check(Rules.preview_progress(cal, "entry_mark", 0, 0) == 2, "preview leaves a lone corner at its own number")
	check(play_named(cal, "entry_mark", 0, 0), "the first end of a diagonal leaves Cal's turn open")
	check(cal.phase == "play", "Cal's first stamp does not end the turn")
	check(Rules.preview_progress(cal, "entry_mark", 0, 1) == 2, "preview leaves a side stamp at its own number")
	check(Rules.preview_progress(cal, "entry_mark", 1, 1) == 2, "preview leaves the center at its own number")
	check(Rules.preview_progress(cal, "entry_mark", 2, 2) == 5, "preview adds 3 to the stamp that completes the diagonal")
	check(play_named(cal, "entry_mark", 0, 1), "Cal receives a stamp off the diagonal, the wrong stamp")
	check(play_named(cal, "entry_mark", 2, 2), "Cal receives the other end of the diagonal, the correct stamp")
	check(cal.last_progress_gained == 12, "the two paired stamps score +3 and the side stamp scores its own number (%d)" % cal.last_progress_gained)
	check(cal.last_patience_loss == 1, "a diagonal pair does not change patience")

	var cal_pair = Rules.scripted_encounter(154, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(cal_pair, "entry_mark", 0, 0), "the top-left end")
	check(play_named(cal_pair, "entry_mark", 2, 2), "the bottom-right end, with the center empty")
	check(cal_pair.last_progress_gained == 10, "both ends score +3 when the center is empty (%d)" % cal_pair.last_progress_gained)

	var cal_anti = Rules.scripted_encounter(154, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(cal_anti, "entry_mark", 0, 2), "the top-right end")
	check(play_named(cal_anti, "entry_mark", 2, 0), "the bottom-left end")
	check(cal_anti.last_progress_gained == 10, "the other diagonal scores +3 when the center is empty (%d)" % cal_anti.last_progress_gained)

	var cal_center = Rules.scripted_encounter(154, 3, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_HEADBAND)
	check(play_named(cal_center, "entry_mark", 0, 0), "one end")
	check(play_named(cal_center, "entry_mark", 1, 1), "Cal receives the center, the wrong stamp")
	check(play_named(cal_center, "entry_mark", 2, 2), "the other end beside a filled center")
	check(cal_center.last_progress_gained == 6, "a filled center means neither pair qualifies (%d)" % cal_center.last_progress_gained)

	var cal_touch = Rules.scripted_encounter(154, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(cal_touch, "entry_mark", 0, 0), "one corner")
	check(play_named(cal_touch, "entry_mark", 1, 1), "the center, with no far end")
	check(cal_touch.last_progress_gained == 4, "a corner and the center are not a pair (%d)" % cal_touch.last_progress_gained)

	var cal_lone = Rules.scripted_encounter(154, 3, ["entry_mark"], 1, Rules.SHIFT_HEADBAND)
	check(play_named(cal_lone, "entry_mark", 0, 0), "Cal receives one corner")
	check(cal_lone.last_progress_gained == 2, "a corner with no partner scores its own number (%d)" % cal_lone.last_progress_gained)

	var cal_column = Rules.scripted_encounter(154, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(cal_column, "entry_mark", 0, 0), "the top of column 1")
	check(play_named(cal_column, "entry_mark", 2, 0), "the bottom of column 1")
	check(cal_column.last_progress_gained == 4, "a column pair is not a diagonal pair (%d)" % cal_column.last_progress_gained)

	var cal_wings = Rules.scripted_encounter(154, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(cal_wings, "entry_mark", 0, 0), "column 1 of the top row")
	check(play_named(cal_wings, "entry_mark", 0, 2), "column 3 of the top row")
	check(cal_wings.last_progress_gained == 4, "a row's wings are not a diagonal pair (%d)" % cal_wings.last_progress_gained)

	var cal_both = Rules.scripted_encounter(154, 3, ["entry_mark", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_HEADBAND)
	check(play_named(cal_both, "entry_mark", 0, 0), "the main diagonal's top")
	check(play_named(cal_both, "entry_mark", 2, 2), "the main diagonal's bottom")
	check(play_named(cal_both, "entry_mark", 0, 2), "the other diagonal's top")
	check(play_named(cal_both, "entry_mark", 2, 0), "the other diagonal's bottom")
	check(cal_both.last_progress_gained == 20, "each diagonal pair adds 3 to its own two stamps (%d)" % cal_both.last_progress_gained)
	check(cal_both.last_won and cal_both.phase == "victory", "both diagonal pairs clear Cal")
	check(cal_both.last_patience_loss == 0 and cal_both.patience == 5, "reaching the goal keeps patience")

	var cal_blocked = Rules.scripted_encounter(154, 3, ["entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 5, Rules.SHIFT_HEADBAND)
	check(play_named(cal_blocked, "entry_mark", 0, 0), "one end")
	check(play_named(cal_blocked, "entry_mark", 0, 2), "another end")
	check(play_named(cal_blocked, "entry_mark", 1, 1), "the filled center")
	check(play_named(cal_blocked, "entry_mark", 2, 0), "a third end")
	check(play_named(cal_blocked, "entry_mark", 2, 2), "the fourth end")
	check(cal_blocked.last_progress_gained == 10, "a filled center blocks both diagonals (%d)" % cal_blocked.last_progress_gained)

	var cal_pressed = Rules.scripted_encounter(154, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(cal_pressed, "entry_mark", 2, 2), "the later end is pressed first")
	check(play_named(cal_pressed, "entry_mark", 0, 0), "the earlier end is pressed last")
	check(cal_pressed.last_progress_gained == 10, "both ends still score +3 (%d)" % cal_pressed.last_progress_gained)

	var cal_freed = Rules.scripted_encounter(154, 3, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_HEADBAND)
	check(play_named(cal_freed, "exemption", 1, 0), "exemption is placed on Cal's middle row")
	check(play_named(cal_freed, "entry_mark", 0, 0), "one end of the diagonal")
	check(play_named(cal_freed, "entry_mark", 2, 2), "the other end of the diagonal")
	check(cal_freed.last_progress_gained == 5, "exemption on the middle row cancels the bonus (%d)" % cal_freed.last_progress_gained)

	var cal_center_exempt = Rules.scripted_encounter(154, 3, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_HEADBAND)
	check(play_named(cal_center_exempt, "exemption", 1, 1), "exemption fills the center")
	check(play_named(cal_center_exempt, "entry_mark", 0, 0), "one end")
	check(play_named(cal_center_exempt, "entry_mark", 2, 2), "the other end")
	check(cal_center_exempt.last_progress_gained == 5, "an exemption in the center keeps both ends at their own numbers (%d)" % cal_center_exempt.last_progress_gained)

	var cal_kept = Rules.scripted_encounter(154, 3, ["exemption", "entry_mark"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(cal_kept, "exemption", 0, 0), "exemption is one end of the pair off the middle row")
	check(play_named(cal_kept, "entry_mark", 2, 2), "the other end of that diagonal")
	check(cal_kept.last_progress_gained == 9, "an exemption pair off the middle row still adds 3 (%d)" % cal_kept.last_progress_gained)

	var cal_kept_off = Rules.scripted_encounter(154, 3, ["entry_mark", "entry_mark", "exemption"], 3, Rules.SHIFT_HEADBAND)
	check(play_named(cal_kept_off, "entry_mark", 0, 0), "one end of the diagonal")
	check(play_named(cal_kept_off, "entry_mark", 2, 2), "the other end of the diagonal")
	check(play_named(cal_kept_off, "exemption", 0, 1), "exemption sits off Cal's middle row")
	check(cal_kept_off.last_progress_gained == 11, "an exemption off the middle row leaves the bonus (%d)" % cal_kept_off.last_progress_gained)

	var cal_ripple = Rules.scripted_encounter(154, 3, ["entry_mark", "entry_mark", "ripple"], 4, Rules.SHIFT_HEADBAND)
	check(play_named(cal_ripple, "entry_mark", 0, 0), "one end of the pair")
	check(play_named(cal_ripple, "entry_mark", 2, 2), "the other end of the pair")
	check(play_named(cal_ripple, "ripple", 0, 1), "ripple beside one end of the pair")
	check(cal_ripple.last_chain_count == 1, "the ripple still retriggers")
	check(cal_ripple.last_progress_gained == 17, "a retrigger of a paired stamp adds 3 again (%d)" % cal_ripple.last_progress_gained)

	var cal_reply = Rules.scripted_encounter(154, 3, ["entry_mark", "entry_mark", "entry_mark", "reply"], 4, Rules.SHIFT_HEADBAND)
	check(play_named(cal_reply, "entry_mark", 0, 0), "a stamp that is not in a pair")
	check(play_named(cal_reply, "entry_mark", 0, 2), "one end of the other diagonal")
	check(play_named(cal_reply, "reply", 1, 0), "reply retriggers the stamp that is not in a pair")
	check(play_named(cal_reply, "entry_mark", 2, 0), "the other end of that diagonal")
	check(cal_reply.last_chain_count == 1, "the reply still retriggers")
	check(cal_reply.last_progress_gained == 15, "a retrigger of a stamp that is not in a pair scores its own number (%d)" % cal_reply.last_progress_gained)

	var cal_pair_reply = Rules.scripted_encounter(154, 3, ["entry_mark", "reply", "entry_mark"], 3, Rules.SHIFT_HEADBAND)
	check(play_named(cal_pair_reply, "entry_mark", 0, 0), "one end of the pair")
	check(play_named(cal_pair_reply, "reply", 1, 0), "reply retriggers that end")
	check(play_named(cal_pair_reply, "entry_mark", 2, 2), "the other end of the pair")
	check(cal_pair_reply.last_chain_count == 1, "the reply still retriggers a paired stamp")
	check(cal_pair_reply.last_progress_gained == 16, "a retrigger of a paired stamp adds 3 again (%d)" % cal_pair_reply.last_progress_gained)

	var cal_held = Rules.scripted_encounter(154, 3, ["hold", "entry_mark", "entry_mark"], 3, Rules.SHIFT_HEADBAND)
	check(play_named(cal_held, "entry_mark", 0, 0), "one end of the pair")
	check(play_named(cal_held, "hold", 0, 1), "hold in Cal's column, off the diagonal")
	check(play_named(cal_held, "entry_mark", 2, 2), "the other end of the pair")
	check(cal_held.last_progress_gained == 11, "the pair still adds 3 beside the hold")
	check(cal_held.last_patience_loss == 0 and cal_held.patience == 5, "hold delays Cal")

	var cal_missed = Rules.scripted_encounter(154, 3, ["hold", "entry_mark"], 2, Rules.SHIFT_HEADBAND)
	check(play_named(cal_missed, "hold", 0, 0), "hold is one end of a pair outside Cal's column")
	check(play_named(cal_missed, "entry_mark", 2, 2), "the other end of that diagonal")
	check(cal_missed.last_progress_gained == 9, "the outside pair still adds 3")
	check(cal_missed.last_patience_loss == 1, "hold in another column does not delay Cal")

	var sera_column = Rules.scripted_encounter(144, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(String(Rules.traveler(sera_column)["rule"]) == "yield_column_pair", "Sera Pell still pays a column pair")
	check(play_named(sera_column, "entry_mark", 0, 0), "Sera's top of column 1")
	check(play_named(sera_column, "entry_mark", 2, 0), "Sera's bottom of column 1")
	check(sera_column.last_progress_gained == 10, "the spine bell still adds 3 to a column pair (%d)" % sera_column.last_progress_gained)

	var sera_diagonal = Rules.scripted_encounter(144, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_SPINE)
	check(play_named(sera_diagonal, "entry_mark", 0, 0), "Sera's top-left")
	check(play_named(sera_diagonal, "entry_mark", 2, 2), "Sera's bottom-right")
	check(sera_diagonal.last_progress_gained == 4, "the spine bell still does not bonus a diagonal pair (%d)" % sera_diagonal.last_progress_gained)

	var nell_wings = Rules.scripted_encounter(131, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(play_named(nell_wings, "entry_mark", 0, 0), "Nell's column 1")
	check(play_named(nell_wings, "entry_mark", 0, 2), "Nell's column 3 of the same row")
	check(nell_wings.last_progress_gained == 10, "the ledger bell still adds 3 to the wings of one row (%d)" % nell_wings.last_progress_gained)


func test_headband_bell_opens() -> void:
	check(Rules.HEADBAND_BELL.size() == 4, "the headband bell has four travelers")
	check(String(Rules.HEADBAND_BELL[0]["name"]) == "Len Hart", "the headband bell begins with Len Hart")
	check(String(Rules.HEADBAND_BELL[1]["name"]) == "Joss Pell", "the headband bell's second traveler is Joss Pell")
	check(String(Rules.HEADBAND_BELL[2]["name"]) == "Ida Quill", "the headband bell's third traveler is Ida Quill")
	check(String(Rules.HEADBAND_BELL[3]["name"]) == "Cal Quern", "the headband bell ends with Cal Quern")
	check(Rules.SPINE_BELL.size() == 4 and String(Rules.SPINE_BELL[0]["name"]) == "Wynn Quill", "the spine bell still begins with Wynn Quill")
	check(String(Rules.SPINE_BELL[3]["name"]) == "Sera Pell", "the spine bell still ends with Sera Pell")
	check(Rules.TRAVELERS.size() == 4 and String(Rules.TRAVELERS[0]["name"]) == "Ada Quill", "Act 1 still begins with Ada Quill")
	var headband_run = Rules.new_run(82, Rules.SHIFT_HEADBAND)
	check(headband_run.shift == Rules.SHIFT_HEADBAND, "the headband bell is a separate night")
	check(String(Rules.traveler(headband_run)["name"]) == "Len Hart", "the headband bell begins with Len Hart")
	check(headband_run.hand.size() == Rules.HAND_SIZE, "the headband bell draws 5")
	check(headband_run.ink == Rules.BASE_INK, "the headband bell starts at 3 ink")
	check(headband_run.library.size() == Rules.STARTING_DECK.size(), "the headband bell deals the starting deck")
	check(headband_run.relic_id == "", "an earlier night's relic does not carry")
	check(headband_run.phase == "play", "the headband bell opens in play")
	var dealt: Array = []
	for iid in headband_run.hand:
		dealt.append(Rules.card_id_of(headband_run, int(iid)))
	var before = headband_run.library.size()
	headband_run.progress = 4
	headband_run.patience = 1
	Rules.restart_encounter(headband_run)
	check(headband_run.shift == Rules.SHIFT_HEADBAND and headband_run.traveler_index == 0, "restart encounter stays on the headband bell")
	check(headband_run.progress == 0 and headband_run.patience == int(Rules.HEADBAND_BELL[0]["patience"]), "restart encounter resets Len")
	check(headband_run.library.size() == before and headband_run.hand.size() == 5 and headband_run.phase == "play", "restart keeps the headband-bell deck and deals a hand")
	var redealt: Array = []
	for iid in headband_run.hand:
		redealt.append(Rules.card_id_of(headband_run, int(iid)))
	check(redealt == dealt, "restart deals Len the same hand")

	var packed = load("res://game/main.tscn")
	var desk = packed.instantiate()
	root.add_child(desk)
	if desk.state == null:
		desk._ready()
	check(desk.state.shift == Rules.SHIFT_FIRST, "the desk still opens on Act 1")
	check(desk.headband_button.text == "Headband bell", "the desk offers the headband bell")
	check(desk.spine_button.text == "Spine bell", "the desk still offers the spine bell")
	desk.headband_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_HEADBAND, "the desk can open the headband bell")
	check(String(Rules.traveler(desk.state)["name"]) == "Len Hart", "the open desk shows Len")
	check(String(desk.desk_label.text).begins_with("Headband bell"), "the desk title follows the headband bell")
	check(desk.meta_label.text.contains("Open Wing"), "the desk shows Len's form")
	check(desk.headband_button.text == "First bell", "the headband bell can return to the first bell")
	check(desk.spine_button.text == "Spine bell", "the spine bell stays available from the headband bell")
	check(desk.shift_button.text == "Late shift", "the late shift stays available from the headband bell")
	desk._restart_act()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_HEADBAND and String(Rules.traveler(desk.state)["name"]) == "Len Hart", "restart act replays the headband bell")
	desk.headband_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the headband bell returns to Ada")
	var doors = [
		["_begin_late_shift", "Nell Parr", "the late shift"],
		["_begin_closing_bell", "Moss Quen", "the closing bell"],
		["_begin_ash_watch", "Orla Fen", "the ash watch"],
		["_begin_gutter_lamp", "Ivo Dane", "the gutter lamp"],
		["_begin_vellum_bell", "Edda Voss", "the vellum bell"],
		["_begin_quire_watch", "Tess Quern", "the quire watch"],
		["_begin_salt_watch", "Pell Voss", "the salt watch"],
		["_begin_quay_bell", "Mara Quill", "the quay bell"],
		["_begin_folio_bell", "Ness Hart", "the folio bell"],
		["_begin_wick_bell", "Odell Voss", "the wick bell"],
		["_begin_margin_bell", "Nim Voss", "the margin bell"],
		["_begin_index_bell", "Len Quill", "the index bell"],
		["_begin_ledger_bell", "Nell Voss", "the ledger bell"],
		["_begin_spine_bell", "Wynn Quill", "the spine bell"],
	]
	for door in doors:
		desk.call(String(door[0]))
		desk._refresh_ui()
		check(desk.state.shift != Rules.SHIFT_HEADBAND and String(Rules.traveler(desk.state)["name"]) == String(door[1]), "%s still opens" % String(door[2]))
		check(desk.headband_button.text == "Headband bell", "%s offers the headband bell" % String(door[2]))
		desk._begin_headband_bell()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_HEADBAND and String(Rules.traveler(desk.state)["name"]) == "Len Hart", "%s can open the headband bell" % String(door[2]))
	desk._begin_first_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "first bell still returns to Ada")
	var victories = [
		[Rules.SHIFT_FIRST, "Act 1"],
		[Rules.SHIFT_LATE, "the late shift"],
		[Rules.SHIFT_CLOSING, "the closing bell"],
		[Rules.SHIFT_ASH, "the ash watch"],
		[Rules.SHIFT_GUTTER, "the gutter lamp"],
		[Rules.SHIFT_VELLUM, "the vellum bell"],
		[Rules.SHIFT_QUIRE, "the quire watch"],
		[Rules.SHIFT_SALT, "the salt watch"],
		[Rules.SHIFT_QUAY, "the quay bell"],
		[Rules.SHIFT_FOLIO, "the folio bell"],
		[Rules.SHIFT_WICK, "the wick bell"],
		[Rules.SHIFT_MARGIN, "the margin bell"],
		[Rules.SHIFT_INDEX, "the index bell"],
		[Rules.SHIFT_LEDGER, "the ledger bell"],
		[Rules.SHIFT_SPINE, "the spine bell"],
	]
	for victory in victories:
		desk._open_shift(int(victory[0]), desk.state.seed)
		desk._refresh_ui()
		desk.state.phase = "victory"
		desk._refresh_ui()
		var victory_headband = _button_named(desk, "Open the headband bell")
		check(victory_headband != null, "%s's victory desk offers the headband bell" % String(victory[1]))
		if victory_headband != null:
			victory_headband.pressed.emit()
			desk._refresh_ui()
			check(desk.state.shift == Rules.SHIFT_HEADBAND and String(Rules.traveler(desk.state)["name"]) == "Len Hart", "%s's victory desk opens the headband bell" % String(victory[1]))
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_first = _button_named(desk, "Open the first bell")
	check(victory_first != null, "the headband bell victory desk offers the first bell")
	if victory_first != null:
		victory_first.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the headband bell victory desk opens the first bell")
	desk._begin_headband_bell()
	desk._refresh_ui()
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_spine = _button_named(desk, "Open the spine bell")
	check(victory_spine != null, "the headband bell victory desk offers the spine bell")
	if victory_spine != null:
		victory_spine.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_SPINE and String(Rules.traveler(desk.state)["name"]) == "Wynn Quill", "the headband bell victory desk opens the spine bell")
	root.remove_child(desk)
	desk.free()


func test_policy_clears_headband_bell() -> void:
	var started = Time.get_ticks_msec()
	var state = Rules.new_run(12345, Rules.SHIFT_HEADBAND)
	var steps = 0
	var seen = 0
	while state.phase != "victory":
		steps += 1
		if steps > 500 or state.phase == "defeat":
			check(false, "policy lost or stalled on the headband bell, seed 12345: " + Rules.debug_summary(state))
			return
		var action = Policy.choose(state)
		if not Rules.apply_action(state, action):
			check(false, "headband-bell policy action was rejected: %s / %s" % [str(action), Rules.debug_summary(state)])
			return
		if state.encounters_cleared != seen:
			seen = state.encounters_cleared
			print("cleared headband encounter %d after %d actions" % [seen, steps])
	var elapsed = Time.get_ticks_msec() - started
	check(state.encounters_cleared == 4, "policy cleared all 4 headband-bell encounters on seed 12345")
	check(state.phase == "victory", "headband bell ends in victory")
	check(state.shift == Rules.SHIFT_HEADBAND, "the clear stayed on the headband bell")
	print("headband bell finished in %d actions, %d ms" % [steps, elapsed])


func test_clasp_bell_rules() -> void:
	var noll = Rules.scripted_encounter(161, 0, ["visa_dot", "entry_mark"], 2, Rules.SHIFT_CLASP)
	check(String(Rules.traveler(noll)["name"]) == "Noll Hart", "the clasp bell's first form is Noll Hart")
	check(String(Rules.traveler(noll)["form_name"]) == "Late Low", "Noll brings the Late Low")
	check(String(Rules.traveler(noll)["rule_text"]) == "When two or more stamps are filled, the latest stamp among those showing the lowest number scores twice. A lone stamp scores its own number.", "Noll's form states the late low")
	check(int(Rules.traveler(noll)["lane"]) == 0 and int(Rules.traveler(noll)["exemption_row"]) == 2, "Noll waits in column 1 and exempts the bottom row")
	check(int(Rules.traveler(noll)["goal"]) == 20, "Noll's goal is 20")
	check(Rules.preview_progress(noll, "visa_dot", 0, 0) == 3, "preview leaves a lone stamp at its own number")
	check(play_named(noll, "visa_dot", 0, 0), "the higher stamp leaves Noll's turn open, the wrong stamp")
	check(noll.phase == "play", "Noll's first stamp does not end the turn")
	check(Rules.preview_progress(noll, "entry_mark", 0, 1) == 4, "preview doubles the later lowest number, the correct stamp")
	check(play_named(noll, "entry_mark", 0, 1), "Noll receives the later lowest stamp, the correct stamp")
	check(noll.last_progress_gained == 7, "the later lowest stamp scores twice and the higher stamp scores its own number (%d)" % noll.last_progress_gained)
	check(noll.last_patience_loss == 1, "the late low does not change patience")

	var noll_early = Rules.scripted_encounter(161, 0, ["entry_mark", "visa_dot"], 2, Rules.SHIFT_CLASP)
	check(play_named(noll_early, "entry_mark", 0, 0), "the only stamp showing the lowest number, the correct stamp")
	check(Rules.preview_progress(noll_early, "visa_dot", 0, 1) == 3, "preview leaves the later higher stamp at its own number")
	check(play_named(noll_early, "visa_dot", 0, 1), "Noll receives the later higher stamp, the wrong stamp")
	check(noll_early.last_progress_gained == 7, "a unique lowest stamp doubles even when a later stamp is higher (%d)" % noll_early.last_progress_gained)

	var noll_lone = Rules.scripted_encounter(161, 0, ["entry_mark"], 1, Rules.SHIFT_CLASP)
	check(play_named(noll_lone, "entry_mark", 1, 1), "Noll receives a lone stamp")
	check(noll_lone.last_progress_gained == 2, "a lone stamp scores its own number (%d)" % noll_lone.last_progress_gained)

	var noll_shared = Rules.scripted_encounter(161, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_CLASP)
	check(play_named(noll_shared, "entry_mark", 0, 0), "the earlier of two stamps showing the lowest number, the wrong stamp")
	check(Rules.preview_progress(noll_shared, "entry_mark", 0, 1) == 4, "preview doubles the later of a shared lowest number")
	check(play_named(noll_shared, "entry_mark", 0, 1), "the later stamp showing that same number, the correct stamp")
	check(noll_shared.last_progress_gained == 6, "only the later of a shared lowest number doubles (%d)" % noll_shared.last_progress_gained)

	var noll_duties = Rules.scripted_encounter(161, 0, ["duty", "duty"], 2, Rules.SHIFT_CLASP)
	check(play_named(noll_duties, "duty", 2, 0), "the earlier bottom-row duty")
	check(Rules.preview_progress(noll_duties, "duty", 2, 2) == 8, "preview doubles the later duty when both show the lowest number")
	check(play_named(noll_duties, "duty", 2, 2), "the later bottom-row duty, the correct stamp")
	check(noll_duties.last_progress_gained == 12, "only the later duty doubles when the same card shares a number (%d)" % noll_duties.last_progress_gained)

	var noll_split = Rules.scripted_encounter(161, 0, ["duty", "duty"], 2, Rules.SHIFT_CLASP)
	check(play_named(noll_split, "duty", 0, 0), "a top-row duty")
	check(Rules.preview_progress(noll_split, "duty", 2, 2) == 4, "preview leaves the higher bottom-row duty at its own number")
	check(play_named(noll_split, "duty", 2, 2), "a bottom-row duty with a higher number")
	check(noll_split.last_progress_gained == 8, "the same card can fail to share the lowest number (%d)" % noll_split.last_progress_gained)

	var noll_fed = Rules.scripted_encounter(161, 0, ["entry_mark", "surcharge"], 2, Rules.SHIFT_CLASP)
	check(play_named(noll_fed, "entry_mark", 0, 0), "the stamp above a surcharge")
	check(Rules.preview_progress(noll_fed, "surcharge", 1, 0) == 5, "preview leaves the fed surcharge at the number the cell already grants")
	check(play_named(noll_fed, "surcharge", 1, 0), "the fed surcharge, the wrong stamp")
	check(noll_fed.last_progress_gained == 9, "a number is the progress the stamp already grants (%d)" % noll_fed.last_progress_gained)

	var noll_plain = Rules.scripted_encounter(161, 0, ["surcharge", "entry_mark"], 2, Rules.SHIFT_CLASP)
	check(play_named(noll_plain, "surcharge", 0, 0), "an unfed surcharge showing 2")
	check(play_named(noll_plain, "entry_mark", 0, 1), "a later stamp showing that same number")
	check(noll_plain.last_progress_gained == 6, "an unfed surcharge shares the lowest number with an entry mark (%d)" % noll_plain.last_progress_gained)

	var noll_pressed = Rules.scripted_encounter(161, 0, ["entry_mark", "visa_dot"], 2, Rules.SHIFT_CLASP)
	check(play_named(noll_pressed, "entry_mark", 0, 1), "the later cell is pressed first")
	check(play_named(noll_pressed, "visa_dot", 0, 0), "the earlier cell is pressed last")
	check(noll_pressed.last_progress_gained == 7, "queue order, not press order, finds the latest lowest stamp (%d)" % noll_pressed.last_progress_gained)

	var noll_muted = Rules.scripted_encounter(161, 0, ["exemption", "entry_mark"], 2, Rules.SHIFT_CLASP)
	check(play_named(noll_muted, "exemption", 2, 0), "exemption is placed on Noll's bottom row")
	check(play_named(noll_muted, "entry_mark", 2, 1), "a later stamp beside that exemption")
	check(noll_muted.last_progress_gained == 3, "exemption on the bottom row cancels the doubling (%d)" % noll_muted.last_progress_gained)

	var noll_later = Rules.scripted_encounter(161, 0, ["entry_mark", "exemption"], 2, Rules.SHIFT_CLASP)
	check(play_named(noll_later, "entry_mark", 2, 0), "an earlier stamp")
	check(play_named(noll_later, "exemption", 2, 1), "exemption is later on the bottom row")
	check(noll_later.last_progress_gained == 3, "a later exemption on the bottom row still cancels the doubling (%d)" % noll_later.last_progress_gained)

	var noll_kept = Rules.scripted_encounter(161, 0, ["exemption", "echo", "visa_dot"], 3, Rules.SHIFT_CLASP)
	check(play_named(noll_kept, "exemption", 0, 0), "exemption sits off Noll's bottom row")
	check(play_named(noll_kept, "echo", 0, 1), "the later stamp showing that lowest number, the correct stamp")
	check(play_named(noll_kept, "visa_dot", 0, 2), "a higher stamp, the wrong stamp")
	check(noll_kept.last_progress_gained == 6, "an exemption off the bottom row still doubles the latest lowest stamp (%d)" % noll_kept.last_progress_gained)

	var noll_ripple = Rules.scripted_encounter(161, 0, ["ripple", "hold"], 3, Rules.SHIFT_CLASP)
	check(play_named(noll_ripple, "ripple", 0, 0), "a higher stamp")
	check(play_named(noll_ripple, "hold", 0, 1), "the latest lowest stamp")
	check(noll_ripple.last_chain_count == 1, "the ripple still retriggers")
	check(noll_ripple.last_progress_gained == 6, "a retrigger of the latest lowest stamp scores twice again (%d)" % noll_ripple.last_progress_gained)

	var noll_echo = Rules.scripted_encounter(161, 0, ["echo", "entry_mark", "visa_dot"], 3, Rules.SHIFT_CLASP)
	check(play_named(noll_echo, "echo", 0, 0), "echo is the lowest stamp")
	check(play_named(noll_echo, "entry_mark", 1, 0), "the stamp under the echo")
	check(play_named(noll_echo, "visa_dot", 0, 2), "a higher stamp")
	check(noll_echo.last_chain_count == 1, "the echo still retriggers")
	check(noll_echo.last_progress_gained == 9, "a retrigger of any other stamp does not double (%d)" % noll_echo.last_progress_gained)

	var noll_held = Rules.scripted_encounter(161, 0, ["visa_dot", "hold"], 2, Rules.SHIFT_CLASP)
	check(play_named(noll_held, "visa_dot", 0, 2), "a higher stamp")
	check(play_named(noll_held, "hold", 1, 0), "hold in Noll's column is the latest lowest stamp")
	check(noll_held.last_progress_gained == 5, "the lowest stamp still scores twice beside the hold")
	check(noll_held.last_patience_loss == 0 and noll_held.patience == 5, "hold delays Noll")

	var noll_missed = Rules.scripted_encounter(161, 0, ["hold", "visa_dot"], 2, Rules.SHIFT_CLASP)
	check(play_named(noll_missed, "hold", 0, 1), "hold outside Noll's column")
	check(play_named(noll_missed, "visa_dot", 0, 2), "a higher later stamp")
	check(noll_missed.last_progress_gained == 5, "the earlier lowest stamp still doubles when the hold is outside the lane")
	check(noll_missed.last_patience_loss == 1, "hold in another column does not delay Noll")

	var ida_low = Rules.scripted_encounter(132, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_LEDGER)
	check(String(Rules.traveler(ida_low)["rule"]) == "double_lowest_earliest", "Ida Mire still doubles the earliest lowest number")
	check(play_named(ida_low, "entry_mark", 0, 0), "Ida's earlier shared number")
	check(Rules.preview_progress(ida_low, "entry_mark", 0, 1) == 2, "preview leaves Ida's later shared number at its own number")
	check(play_named(ida_low, "entry_mark", 0, 1), "Ida's later shared number")
	check(ida_low.last_progress_gained == 6, "the ledger bell still doubles the earlier of a shared lowest number (%d)" % ida_low.last_progress_gained)

	var ida_high = Rules.scripted_encounter(153, 2, ["visa_dot", "entry_mark"], 2, Rules.SHIFT_HEADBAND)
	check(String(Rules.traveler(ida_high)["rule"]) == "double_highest_latest", "Ida Quill still doubles the latest highest number")
	check(play_named(ida_high, "visa_dot", 0, 0), "Ida's highest stamp")
	check(play_named(ida_high, "entry_mark", 0, 1), "Ida's later lower stamp")
	check(ida_high.last_progress_gained == 8, "the headband bell still doubles the highest number, not the later lowest (%d)" % ida_high.last_progress_gained)

	var hugh = Rules.scripted_encounter(162, 1, ["entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 6, Rules.SHIFT_CLASP)
	check(String(Rules.traveler(hugh)["name"]) == "Hugh Pell", "the clasp bell's second form is Hugh Pell")
	check(String(Rules.traveler(hugh)["form_name"]) == "Six Toll", "Hugh brings the Six Toll")
	check(String(Rules.traveler(hugh)["rule_text"]) == "Patience drops by 2 when exactly six cells are filled.", "Hugh's form states the six toll")
	check(int(Rules.traveler(hugh)["lane"]) == 1 and int(Rules.traveler(hugh)["exemption_row"]) == 0, "Hugh waits in column 2 and exempts the top row")
	check(int(Rules.traveler(hugh)["goal"]) == 16, "Hugh's goal is 16")
	check(Rules.preview_progress(hugh, "duty", 2, 1) == 4, "preview leaves a duty at its own number")
	check(play_named(hugh, "entry_mark", 0, 0), "the first stamp leaves Hugh's turn open")
	check(hugh.phase == "play", "Hugh's first stamp does not end the turn")
	check(play_named(hugh, "entry_mark", 0, 1), "the second stamp")
	check(play_named(hugh, "entry_mark", 0, 2), "the third stamp")
	check(play_named(hugh, "entry_mark", 1, 0), "the fourth stamp")
	check(play_named(hugh, "entry_mark", 1, 1), "the fifth stamp, the correct count")
	check(play_named(hugh, "entry_mark", 1, 2), "Hugh receives the sixth stamp, the wrong stamp")
	check(hugh.last_progress_gained == 12, "exactly six stamps score their own numbers (%d)" % hugh.last_progress_gained)
	check(hugh.last_patience_loss == 2 and hugh.patience == 3, "exactly six cells drop patience by 2")

	var hugh_five = Rules.scripted_encounter(162, 1, ["entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 5, Rules.SHIFT_CLASP)
	check(play_named(hugh_five, "entry_mark", 0, 0), "the first of five")
	check(play_named(hugh_five, "entry_mark", 0, 1), "the second of five")
	check(play_named(hugh_five, "entry_mark", 0, 2), "the third of five")
	check(play_named(hugh_five, "entry_mark", 1, 0), "the fourth of five")
	check(play_named(hugh_five, "entry_mark", 1, 1), "Hugh receives the fifth stamp, the correct stamp")
	check(hugh_five.last_progress_gained == 10, "exactly five stamps score their own numbers (%d)" % hugh_five.last_progress_gained)
	check(hugh_five.last_patience_loss == 1 and hugh_five.patience == 4, "a form of five keeps the drop at 1")

	var hugh_four = Rules.scripted_encounter(162, 1, ["entry_mark", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_CLASP)
	check(play_named(hugh_four, "entry_mark", 0, 0), "the first of four")
	check(play_named(hugh_four, "entry_mark", 0, 1), "the second of four")
	check(play_named(hugh_four, "entry_mark", 0, 2), "the third of four")
	check(play_named(hugh_four, "entry_mark", 1, 0), "Hugh receives the fourth stamp")
	check(hugh_four.last_patience_loss == 1, "a form of four keeps the drop at 1")

	var hugh_three = Rules.scripted_encounter(162, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_CLASP)
	check(play_named(hugh_three, "entry_mark", 0, 0), "the first of three")
	check(play_named(hugh_three, "entry_mark", 0, 1), "the second of three")
	check(play_named(hugh_three, "entry_mark", 0, 2), "Hugh receives the third stamp")
	check(hugh_three.last_patience_loss == 1, "a form of three keeps the drop at 1")

	var hugh_one = Rules.scripted_encounter(162, 1, ["duty"], 1, Rules.SHIFT_CLASP)
	check(play_named(hugh_one, "duty", 2, 1), "Hugh receives one bottom-row duty")
	check(hugh_one.last_progress_gained == 4, "one stamp scores its own number (%d)" % hugh_one.last_progress_gained)
	check(hugh_one.last_patience_loss == 1, "one stamp keeps the drop at 1")

	var hugh_two = Rules.scripted_encounter(162, 1, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_CLASP)
	check(play_named(hugh_two, "entry_mark", 0, 0), "the first of two")
	check(play_named(hugh_two, "entry_mark", 0, 1), "Hugh receives the second stamp")
	check(hugh_two.last_patience_loss == 1, "a form of two keeps the drop at 1")

	var hugh_seven = Rules.scripted_encounter(162, 1, ["entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 7, Rules.SHIFT_CLASP)
	check(play_named(hugh_seven, "entry_mark", 0, 0), "the first of seven")
	check(play_named(hugh_seven, "entry_mark", 0, 1), "the second of seven")
	check(play_named(hugh_seven, "entry_mark", 0, 2), "the third of seven")
	check(play_named(hugh_seven, "entry_mark", 1, 0), "the fourth of seven")
	check(play_named(hugh_seven, "entry_mark", 1, 1), "the fifth of seven")
	check(play_named(hugh_seven, "entry_mark", 1, 2), "the sixth of seven")
	check(play_named(hugh_seven, "entry_mark", 2, 0), "Hugh receives a seventh stamp")
	check(hugh_seven.last_progress_gained == 14, "seven stamps score their own numbers (%d)" % hugh_seven.last_progress_gained)
	check(hugh_seven.last_patience_loss == 1, "a form of seven keeps the drop at 1")

	var hugh_scored = Rules.scripted_encounter(162, 1, ["duty", "entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 6, Rules.SHIFT_CLASP)
	check(play_named(hugh_scored, "duty", 2, 0), "a bottom-row duty")
	check(play_named(hugh_scored, "entry_mark", 0, 0), "an entry mark")
	check(play_named(hugh_scored, "entry_mark", 0, 1), "a second entry mark")
	check(play_named(hugh_scored, "entry_mark", 0, 2), "a third entry mark")
	check(play_named(hugh_scored, "entry_mark", 1, 0), "a fourth entry mark")
	check(play_named(hugh_scored, "entry_mark", 1, 1), "a fifth entry mark")
	check(hugh_scored.last_progress_gained == 14, "the toll does not change the score (%d)" % hugh_scored.last_progress_gained)
	check(hugh_scored.last_patience_loss == 2, "six stamps still drop patience by 2")

	var hugh_empty = Rules.scripted_encounter(162, 1, ["entry_mark"], 3, Rules.SHIFT_CLASP)
	Rules.end_turn(hugh_empty)
	check(hugh_empty.last_progress_gained == 0, "an empty form scores nothing")
	check(hugh_empty.last_patience_loss == 1, "an empty form keeps the drop at 1")

	var hugh_held = Rules.scripted_encounter(162, 1, ["hold", "entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 6, Rules.SHIFT_CLASP)
	check(play_named(hugh_held, "entry_mark", 0, 0), "a stamp outside the lane")
	check(play_named(hugh_held, "entry_mark", 0, 2), "a second stamp")
	check(play_named(hugh_held, "entry_mark", 1, 0), "a third stamp")
	check(play_named(hugh_held, "entry_mark", 1, 1), "a fourth stamp")
	check(play_named(hugh_held, "entry_mark", 1, 2), "a fifth stamp")
	check(play_named(hugh_held, "hold", 0, 1), "hold in Hugh's column")
	check(hugh_held.last_progress_gained == 11, "the held turn still scores the stamps")
	check(hugh_held.last_patience_loss == 0 and hugh_held.patience == 5, "hold is applied before the six toll")

	var hugh_missed = Rules.scripted_encounter(162, 1, ["hold", "entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 6, Rules.SHIFT_CLASP)
	check(play_named(hugh_missed, "hold", 0, 0), "hold outside Hugh's column")
	check(play_named(hugh_missed, "entry_mark", 0, 1), "a stamp")
	check(play_named(hugh_missed, "entry_mark", 0, 2), "a second stamp")
	check(play_named(hugh_missed, "entry_mark", 1, 0), "a third stamp")
	check(play_named(hugh_missed, "entry_mark", 1, 1), "a fourth stamp")
	check(play_named(hugh_missed, "entry_mark", 1, 2), "the sixth stamp")
	check(hugh_missed.last_progress_gained == 11, "the outside hold still scores 1")
	check(hugh_missed.last_patience_loss == 2, "hold in another column does not stop the six toll")

	var hugh_spared = Rules.scripted_encounter(162, 1, ["exemption", "entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 6, Rules.SHIFT_CLASP)
	check(play_named(hugh_spared, "exemption", 0, 0), "exemption is placed on Hugh's top row")
	check(play_named(hugh_spared, "entry_mark", 0, 1), "a stamp beside that exemption")
	check(play_named(hugh_spared, "entry_mark", 0, 2), "a third stamp")
	check(play_named(hugh_spared, "entry_mark", 1, 0), "a fourth stamp")
	check(play_named(hugh_spared, "entry_mark", 1, 1), "a fifth stamp")
	check(play_named(hugh_spared, "entry_mark", 1, 2), "the sixth stamp")
	check(hugh_spared.last_progress_gained == 11, "the exempted stamps still score")
	check(hugh_spared.last_patience_loss == 1, "exemption on the top row keeps the drop at 1")

	var hugh_open = Rules.scripted_encounter(162, 1, ["exemption", "entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 6, Rules.SHIFT_CLASP)
	check(play_named(hugh_open, "entry_mark", 0, 0), "a stamp")
	check(play_named(hugh_open, "entry_mark", 0, 1), "a second stamp")
	check(play_named(hugh_open, "entry_mark", 0, 2), "a third stamp")
	check(play_named(hugh_open, "entry_mark", 1, 0), "a fourth stamp")
	check(play_named(hugh_open, "entry_mark", 1, 1), "a fifth stamp")
	check(play_named(hugh_open, "exemption", 2, 0), "exemption sits off Hugh's top row")
	check(hugh_open.last_progress_gained == 11, "the off-row exemption still scores")
	check(hugh_open.last_patience_loss == 2, "an exemption off the top row leaves the drop at 2")

	var joss_five = Rules.scripted_encounter(152, 1, ["entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 5, Rules.SHIFT_HEADBAND)
	check(String(Rules.traveler(joss_five)["rule"]) == "drop_if_exact_five", "Joss Pell still tolls exactly five stamps")
	check(play_named(joss_five, "entry_mark", 0, 0), "Joss's first of five")
	check(play_named(joss_five, "entry_mark", 0, 1), "Joss's second of five")
	check(play_named(joss_five, "entry_mark", 0, 2), "Joss's third of five")
	check(play_named(joss_five, "entry_mark", 1, 0), "Joss's fourth of five")
	check(play_named(joss_five, "entry_mark", 1, 1), "Joss's fifth stamp")
	check(joss_five.last_patience_loss == 2, "the headband bell still drops patience by 2 for exactly five cells")

	var joss_six = Rules.scripted_encounter(152, 1, ["entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 6, Rules.SHIFT_HEADBAND)
	check(play_named(joss_six, "entry_mark", 0, 0), "Joss's first of six")
	check(play_named(joss_six, "entry_mark", 0, 1), "Joss's second of six")
	check(play_named(joss_six, "entry_mark", 0, 2), "Joss's third of six")
	check(play_named(joss_six, "entry_mark", 1, 0), "Joss's fourth of six")
	check(play_named(joss_six, "entry_mark", 1, 1), "Joss's fifth of six")
	check(play_named(joss_six, "entry_mark", 1, 2), "Joss's sixth stamp")
	check(joss_six.last_patience_loss == 1, "the headband bell still keeps the drop at 1 for a form of six")

	var ada_four = Rules.scripted_encounter(142, 1, ["entry_mark", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_SPINE)
	check(String(Rules.traveler(ada_four)["rule"]) == "drop_if_exact_four", "Ada Hart still tolls exactly four stamps")
	check(play_named(ada_four, "entry_mark", 0, 0), "Ada's first of four")
	check(play_named(ada_four, "entry_mark", 0, 1), "Ada's second of four")
	check(play_named(ada_four, "entry_mark", 0, 2), "Ada's third of four")
	check(play_named(ada_four, "entry_mark", 1, 0), "Ada's fourth stamp")
	check(ada_four.last_patience_loss == 2, "the spine bell still drops patience by 2 for exactly four cells")

	var pell_three = Rules.scripted_encounter(132, 1, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_LEDGER)
	check(String(Rules.traveler(pell_three)["rule"]) == "drop_if_exact_three", "Pell Dane still tolls exactly three stamps")
	check(play_named(pell_three, "entry_mark", 0, 0), "Pell's first stamp")
	check(play_named(pell_three, "entry_mark", 0, 1), "Pell's second stamp")
	check(play_named(pell_three, "entry_mark", 0, 2), "Pell's third stamp")
	check(pell_three.last_patience_loss == 2, "the ledger bell still drops patience by 2 for exactly three cells")

	var fenn = Rules.scripted_encounter(163, 2, ["entry_mark", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_CLASP)
	check(String(Rules.traveler(fenn)["name"]) == "Fenn Hart", "the clasp bell's third form is Fenn Hart")
	check(String(Rules.traveler(fenn)["form_name"]) == "Full Column", "Fenn brings the Full Column")
	check(String(Rules.traveler(fenn)["rule_text"]) == "A stamp scores twice only when its own column is full. A stamp in a column that is not full scores its own number.", "Fenn's form states the full column")
	check(int(Rules.traveler(fenn)["lane"]) == 2 and int(Rules.traveler(fenn)["exemption_row"]) == 1, "Fenn waits in column 3 and exempts the middle row")
	check(int(Rules.traveler(fenn)["goal"]) == 22, "Fenn's goal is 22")
	check(Rules.preview_progress(fenn, "entry_mark", 0, 0) == 2, "preview leaves a lone stamp at its own number")
	check(play_named(fenn, "entry_mark", 0, 0), "the first stamp leaves Fenn's turn open")
	check(fenn.phase == "play", "Fenn's first stamp does not end the turn")
	check(Rules.preview_progress(fenn, "entry_mark", 0, 1) == 2, "preview leaves another column at its own number")
	check(play_named(fenn, "entry_mark", 0, 1), "Fenn receives a stamp in a column that is not full, the wrong stamp")
	check(play_named(fenn, "entry_mark", 1, 0), "the second stamp of the column")
	check(Rules.preview_progress(fenn, "entry_mark", 2, 0) == 4, "preview doubles the stamp that fills the column")
	check(play_named(fenn, "entry_mark", 2, 0), "Fenn receives a full column, the correct stamp")
	check(fenn.last_progress_gained == 14, "each stamp in a full column scores twice, and the other column scores its own number (%d)" % fenn.last_progress_gained)
	check(fenn.last_patience_loss == 1, "a full column does not change patience")

	var fenn_pair = Rules.scripted_encounter(163, 2, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_CLASP)
	check(play_named(fenn_pair, "entry_mark", 0, 0), "one stamp in the column")
	check(play_named(fenn_pair, "entry_mark", 1, 0), "Fenn receives a column that is not full, the wrong stamp")
	check(fenn_pair.last_progress_gained == 4, "a stamp in a column that is not full scores its own number (%d)" % fenn_pair.last_progress_gained)

	var fenn_lone = Rules.scripted_encounter(163, 2, ["duty"], 1, Rules.SHIFT_CLASP)
	check(play_named(fenn_lone, "duty", 2, 2), "Fenn receives a lone bottom-row duty")
	check(fenn_lone.last_progress_gained == 4, "a lone stamp scores its own number (%d)" % fenn_lone.last_progress_gained)

	var fenn_row = Rules.scripted_encounter(163, 2, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_CLASP)
	check(play_named(fenn_row, "entry_mark", 0, 0), "the first of a full row")
	check(play_named(fenn_row, "entry_mark", 0, 1), "the second of a full row")
	check(play_named(fenn_row, "entry_mark", 0, 2), "the third of a full row")
	check(fenn_row.last_progress_gained == 6, "a full row does not double a column that is not full (%d)" % fenn_row.last_progress_gained)

	var fenn_both = Rules.scripted_encounter(163, 2, ["entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark", "entry_mark"], 6, Rules.SHIFT_CLASP)
	check(play_named(fenn_both, "entry_mark", 0, 0), "the top of column 1")
	check(play_named(fenn_both, "entry_mark", 1, 0), "the middle of column 1")
	check(play_named(fenn_both, "entry_mark", 2, 0), "the bottom of column 1")
	check(play_named(fenn_both, "entry_mark", 0, 2), "the top of column 3")
	check(play_named(fenn_both, "entry_mark", 1, 2), "the middle of column 3")
	check(play_named(fenn_both, "entry_mark", 2, 2), "the bottom of column 3")
	check(fenn_both.last_progress_gained == 24, "each full column doubles its own stamps (%d)" % fenn_both.last_progress_gained)
	check(fenn_both.last_won and fenn_both.phase == "draft", "two full columns clear Fenn")

	var fenn_muted = Rules.scripted_encounter(163, 2, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_CLASP)
	check(play_named(fenn_muted, "exemption", 1, 0), "exemption is placed on Fenn's middle row")
	check(play_named(fenn_muted, "entry_mark", 0, 0), "a stamp above that exemption")
	check(play_named(fenn_muted, "entry_mark", 2, 0), "the column is full")
	check(fenn_muted.last_progress_gained == 5, "exemption on the middle row cancels the doubling (%d)" % fenn_muted.last_progress_gained)

	var fenn_other = Rules.scripted_encounter(163, 2, ["exemption", "entry_mark", "entry_mark", "entry_mark"], 4, Rules.SHIFT_CLASP)
	check(play_named(fenn_other, "exemption", 1, 1), "exemption on the middle row")
	check(play_named(fenn_other, "entry_mark", 0, 0), "a stamp in column 1")
	check(play_named(fenn_other, "entry_mark", 1, 0), "a second stamp in column 1")
	check(play_named(fenn_other, "entry_mark", 2, 0), "column 1 is full")
	check(fenn_other.last_progress_gained == 7, "exemption on the middle row cancels doubling in every column (%d)" % fenn_other.last_progress_gained)

	var fenn_kept = Rules.scripted_encounter(163, 2, ["exemption", "entry_mark", "entry_mark"], 3, Rules.SHIFT_CLASP)
	check(play_named(fenn_kept, "exemption", 0, 2), "exemption is the top of column 3, off the middle row")
	check(play_named(fenn_kept, "entry_mark", 1, 2), "the middle of that column")
	check(play_named(fenn_kept, "entry_mark", 2, 2), "the column is full")
	check(fenn_kept.last_progress_gained == 10, "an exemption off the middle row doubles with its own full column (%d)" % fenn_kept.last_progress_gained)

	var fenn_echo = Rules.scripted_encounter(163, 2, ["echo", "entry_mark", "entry_mark"], 3, Rules.SHIFT_CLASP)
	check(play_named(fenn_echo, "echo", 0, 0), "echo at the top of a full column")
	check(play_named(fenn_echo, "entry_mark", 1, 0), "the stamp under the echo")
	check(play_named(fenn_echo, "entry_mark", 2, 0), "the column is full")
	check(fenn_echo.last_chain_count == 1, "the echo still retriggers")
	check(fenn_echo.last_progress_gained == 14, "a retrigger of a stamp in a full column scores twice again (%d)" % fenn_echo.last_progress_gained)

	var fenn_open = Rules.scripted_encounter(163, 2, ["echo", "entry_mark"], 2, Rules.SHIFT_CLASP)
	check(play_named(fenn_open, "echo", 0, 0), "echo in an open column")
	check(play_named(fenn_open, "entry_mark", 1, 0), "the stamp under the echo")
	check(fenn_open.last_chain_count == 1, "the echo still retriggers an open column")
	check(fenn_open.last_progress_gained == 5, "a retrigger in a column that is not full does not double (%d)" % fenn_open.last_progress_gained)

	var fenn_held = Rules.scripted_encounter(163, 2, ["entry_mark", "hold", "entry_mark"], 3, Rules.SHIFT_CLASP)
	check(play_named(fenn_held, "entry_mark", 0, 2), "one stamp of the column")
	check(play_named(fenn_held, "hold", 1, 2), "hold in Fenn's column")
	check(play_named(fenn_held, "entry_mark", 2, 2), "the column is full")
	check(fenn_held.last_progress_gained == 10, "the held stamp in a full column still scores twice")
	check(fenn_held.last_patience_loss == 0 and fenn_held.patience == 5, "hold delays Fenn")

	var fenn_missed = Rules.scripted_encounter(163, 2, ["hold", "entry_mark", "entry_mark"], 3, Rules.SHIFT_CLASP)
	check(play_named(fenn_missed, "hold", 0, 0), "hold outside Fenn's column")
	check(play_named(fenn_missed, "entry_mark", 1, 0), "a stamp beside the hold")
	check(play_named(fenn_missed, "entry_mark", 2, 0), "the column is full")
	check(fenn_missed.last_progress_gained == 10, "the outside hold still doubles with the column")
	check(fenn_missed.last_patience_loss == 1, "hold in another column does not delay Fenn")

	var wynn_row = Rules.scripted_encounter(123, 2, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_INDEX)
	check(String(Rules.traveler(wynn_row)["rule"]) == "double_full_row", "Wynn Hart still doubles only a full row")
	check(play_named(wynn_row, "entry_mark", 0, 0), "Wynn's first of a full row")
	check(play_named(wynn_row, "entry_mark", 0, 1), "Wynn's second of a full row")
	check(play_named(wynn_row, "entry_mark", 0, 2), "Wynn's full row")
	check(wynn_row.last_progress_gained == 12, "the index bell still doubles a full row (%d)" % wynn_row.last_progress_gained)

	var wynn_column = Rules.scripted_encounter(123, 2, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_INDEX)
	check(play_named(wynn_column, "entry_mark", 0, 0), "Wynn's top of column 1")
	check(play_named(wynn_column, "entry_mark", 1, 0), "Wynn's middle of column 1")
	check(play_named(wynn_column, "entry_mark", 2, 0), "Wynn's bottom of column 1")
	check(wynn_column.last_progress_gained == 6, "the index bell still does not double a full column (%d)" % wynn_column.last_progress_gained)

	var rue = Rules.scripted_encounter(164, 3, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_CLASP)
	check(String(Rules.traveler(rue)["name"]) == "Rue Hart", "the clasp bell's fourth form is Rue Hart")
	check(String(Rules.traveler(rue)["form_name"]) == "Side Slip", "Rue brings the Side Slip")
	check(String(Rules.traveler(rue)["rule_text"]) == "When a stamp shares a side with an earlier stamp, the later stamp scores twice. The earlier stamp scores its own number.", "Rue's form states the side slip")
	check(int(Rules.traveler(rue)["lane"]) == 0 and int(Rules.traveler(rue)["exemption_row"]) == 2, "Rue waits in column 1 and exempts the bottom row")
	check(int(Rules.traveler(rue)["goal"]) == 18, "Rue's goal is 18")
	check(Rules.preview_progress(rue, "entry_mark", 0, 0) == 2, "preview leaves a lone stamp at its own number")
	check(play_named(rue, "entry_mark", 0, 0), "the first stamp leaves Rue's turn open")
	check(rue.phase == "play", "Rue's first stamp does not end the turn")
	check(Rules.preview_progress(rue, "entry_mark", 0, 2) == 2, "preview leaves a stamp with a gap at its own number")
	check(Rules.preview_progress(rue, "entry_mark", 1, 0) == 4, "preview doubles the later stamp that shares a side")
	check(play_named(rue, "entry_mark", 0, 2), "Rue receives a stamp that does not share a side, the wrong stamp")
	check(play_named(rue, "entry_mark", 1, 0), "Rue receives the later stamp that shares a side, the correct stamp")
	check(rue.last_progress_gained == 8, "the later side scores twice and the other stamps score their own number (%d)" % rue.last_progress_gained)
	check(rue.last_patience_loss == 1, "a shared side does not change patience")

	var rue_corner = Rules.scripted_encounter(164, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_CLASP)
	check(play_named(rue_corner, "entry_mark", 0, 0), "one corner")
	check(play_named(rue_corner, "entry_mark", 1, 1), "Rue receives a corner-only touch, the wrong stamp")
	check(rue_corner.last_progress_gained == 4, "a corner-only touch does not double either stamp (%d)" % rue_corner.last_progress_gained)

	var rue_lone = Rules.scripted_encounter(164, 3, ["duty"], 1, Rules.SHIFT_CLASP)
	check(play_named(rue_lone, "duty", 2, 1), "Rue receives a lone bottom-row duty")
	check(rue_lone.last_progress_gained == 4, "a lone stamp scores its own number (%d)" % rue_lone.last_progress_gained)

	var rue_vertical = Rules.scripted_encounter(164, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_CLASP)
	check(play_named(rue_vertical, "entry_mark", 0, 0), "the earlier stamp")
	check(play_named(rue_vertical, "entry_mark", 1, 0), "the later stamp directly below it, the correct stamp")
	check(rue_vertical.last_progress_gained == 6, "a vertical side doubles only the later stamp (%d)" % rue_vertical.last_progress_gained)

	var rue_row = Rules.scripted_encounter(164, 3, ["entry_mark", "entry_mark", "entry_mark"], 3, Rules.SHIFT_CLASP)
	check(play_named(rue_row, "entry_mark", 0, 0), "the first of three")
	check(play_named(rue_row, "entry_mark", 0, 1), "the second of three")
	check(play_named(rue_row, "entry_mark", 0, 2), "the third of three")
	check(rue_row.last_progress_gained == 10, "the second and third stamps in a row score twice (%d)" % rue_row.last_progress_gained)

	var rue_gap = Rules.scripted_encounter(164, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_CLASP)
	check(play_named(rue_gap, "entry_mark", 0, 0), "the first of a gapped row")
	check(play_named(rue_gap, "entry_mark", 0, 2), "the later stamp with a gap")
	check(rue_gap.last_progress_gained == 4, "a gap does not double the later stamp (%d)" % rue_gap.last_progress_gained)

	var rue_long = Rules.scripted_encounter(164, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_CLASP)
	check(play_named(rue_long, "entry_mark", 0, 0), "the first of a longer diagonal")
	check(play_named(rue_long, "entry_mark", 2, 2), "the other end of that diagonal")
	check(rue_long.last_progress_gained == 4, "a longer diagonal does not double either stamp (%d)" % rue_long.last_progress_gained)

	var rue_pressed = Rules.scripted_encounter(164, 3, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_CLASP)
	check(play_named(rue_pressed, "entry_mark", 0, 1), "the later cell is pressed first")
	check(play_named(rue_pressed, "entry_mark", 0, 0), "the earlier cell is pressed last")
	check(rue_pressed.last_progress_gained == 6, "queue order, not press order, doubles Rue's later stamp (%d)" % rue_pressed.last_progress_gained)

	var rue_muted = Rules.scripted_encounter(164, 3, ["exemption", "entry_mark"], 2, Rules.SHIFT_CLASP)
	check(play_named(rue_muted, "exemption", 2, 0), "exemption is placed on Rue's bottom row")
	check(play_named(rue_muted, "entry_mark", 2, 1), "a later side-sharing stamp")
	check(rue_muted.last_progress_gained == 3, "exemption on the bottom row cancels the doubling (%d)" % rue_muted.last_progress_gained)

	var rue_later = Rules.scripted_encounter(164, 3, ["entry_mark", "exemption"], 2, Rules.SHIFT_CLASP)
	check(play_named(rue_later, "entry_mark", 2, 0), "the earlier stamp")
	check(play_named(rue_later, "exemption", 2, 1), "exemption is the later stamp on the bottom row")
	check(rue_later.last_progress_gained == 3, "a later exemption on the bottom row still cancels the doubling (%d)" % rue_later.last_progress_gained)

	var rue_kept = Rules.scripted_encounter(164, 3, ["entry_mark", "entry_mark", "exemption"], 3, Rules.SHIFT_CLASP)
	check(play_named(rue_kept, "entry_mark", 0, 0), "the earlier stamp")
	check(play_named(rue_kept, "entry_mark", 0, 1), "the later stamp that shares a side")
	check(play_named(rue_kept, "exemption", 1, 2), "exemption sits off Rue's bottom row")
	check(rue_kept.last_progress_gained == 7, "an exemption off the bottom row leaves the later stamp doubled (%d)" % rue_kept.last_progress_gained)

	var rue_echo = Rules.scripted_encounter(164, 3, ["echo", "entry_mark"], 2, Rules.SHIFT_CLASP)
	check(play_named(rue_echo, "echo", 0, 0), "echo above a stamp")
	check(play_named(rue_echo, "entry_mark", 1, 0), "the later stamp under the echo")
	check(rue_echo.last_chain_count == 1, "the echo still retriggers")
	check(rue_echo.last_progress_gained == 9, "a retrigger of a later side-sharing stamp scores twice again (%d)" % rue_echo.last_progress_gained)

	var rue_reply = Rules.scripted_encounter(164, 3, ["entry_mark", "reply"], 2, Rules.SHIFT_CLASP)
	check(play_named(rue_reply, "entry_mark", 0, 0), "the earlier stamp")
	check(play_named(rue_reply, "reply", 1, 0), "reply retriggers the earlier stamp")
	check(rue_reply.last_chain_count == 1, "the reply still retriggers the earlier stamp")
	check(rue_reply.last_progress_gained == 6, "a retrigger of the earlier stamp scores its own number (%d)" % rue_reply.last_progress_gained)

	var rue_held = Rules.scripted_encounter(164, 3, ["entry_mark", "hold"], 2, Rules.SHIFT_CLASP)
	check(play_named(rue_held, "entry_mark", 0, 0), "the earlier stamp in Rue's column")
	check(play_named(rue_held, "hold", 1, 0), "hold in Rue's column shares that side")
	check(rue_held.last_progress_gained == 4, "the later side-sharing hold scores twice")
	check(rue_held.last_patience_loss == 0 and rue_held.patience == 5, "hold delays Rue")

	var rue_missed = Rules.scripted_encounter(164, 3, ["entry_mark", "hold"], 2, Rules.SHIFT_CLASP)
	check(play_named(rue_missed, "entry_mark", 0, 0), "an earlier stamp")
	check(play_named(rue_missed, "hold", 0, 1), "hold outside Rue's column")
	check(rue_missed.last_progress_gained == 4, "the outside hold still doubles")
	check(rue_missed.last_patience_loss == 1, "hold in another column does not delay Rue")

	var rue_clear = Rules.scripted_encounter(164, 3, ["visa_dot", "visa_dot", "visa_dot", "visa_dot"], 4, Rules.SHIFT_CLASP)
	check(play_named(rue_clear, "visa_dot", 0, 0), "the first visa")
	check(play_named(rue_clear, "visa_dot", 0, 1), "the second visa")
	check(play_named(rue_clear, "visa_dot", 0, 2), "the third visa")
	check(play_named(rue_clear, "visa_dot", 1, 0), "the fourth visa shares a side")
	check(rue_clear.last_progress_gained == 21, "later side-sharing visas score twice (%d)" % rue_clear.last_progress_gained)
	check(rue_clear.last_won and rue_clear.phase == "victory", "the side slip clears Rue")
	check(rue_clear.last_patience_loss == 0 and rue_clear.patience == 5, "reaching the goal keeps patience")

	var nim_side = Rules.scripted_encounter(111, 0, ["entry_mark", "entry_mark"], 2, Rules.SHIFT_MARGIN)
	check(String(Rules.traveler(nim_side)["rule"]) == "zero_side_later", "Nim Voss still zeros a later side")
	check(play_named(nim_side, "entry_mark", 0, 0), "Nim's earlier stamp")
	check(play_named(nim_side, "entry_mark", 0, 1), "Nim's later side")
	check(nim_side.last_progress_gained == 2, "the margin bell still zeros the later side-sharing stamp (%d)" % nim_side.last_progress_gained)


func test_clasp_bell_opens() -> void:
	check(Rules.CLASP_BELL.size() == 4, "the clasp bell has four travelers")
	check(String(Rules.CLASP_BELL[0]["name"]) == "Noll Hart", "the clasp bell begins with Noll Hart")
	check(String(Rules.CLASP_BELL[1]["name"]) == "Hugh Pell", "the clasp bell's second traveler is Hugh Pell")
	check(String(Rules.CLASP_BELL[2]["name"]) == "Fenn Hart", "the clasp bell's third traveler is Fenn Hart")
	check(String(Rules.CLASP_BELL[3]["name"]) == "Rue Hart", "the clasp bell ends with Rue Hart")
	check(Rules.HEADBAND_BELL.size() == 4 and String(Rules.HEADBAND_BELL[0]["name"]) == "Len Hart", "the headband bell still begins with Len Hart")
	check(String(Rules.HEADBAND_BELL[3]["name"]) == "Cal Quern", "the headband bell still ends with Cal Quern")
	check(Rules.TRAVELERS.size() == 4 and String(Rules.TRAVELERS[0]["name"]) == "Ada Quill", "Act 1 still begins with Ada Quill")
	var clasp_run = Rules.new_run(83, Rules.SHIFT_CLASP)
	check(clasp_run.shift == Rules.SHIFT_CLASP, "the clasp bell is a separate night")
	check(String(Rules.traveler(clasp_run)["name"]) == "Noll Hart", "the clasp bell begins with Noll Hart")
	check(clasp_run.hand.size() == Rules.HAND_SIZE, "the clasp bell draws 5")
	check(clasp_run.ink == Rules.BASE_INK, "the clasp bell starts at 3 ink")
	check(clasp_run.library.size() == Rules.STARTING_DECK.size(), "the clasp bell deals the starting deck")
	check(clasp_run.relic_id == "", "an earlier night's relic does not carry")
	check(clasp_run.phase == "play", "the clasp bell opens in play")
	var dealt: Array = []
	for iid in clasp_run.hand:
		dealt.append(Rules.card_id_of(clasp_run, int(iid)))
	var before = clasp_run.library.size()
	clasp_run.progress = 4
	clasp_run.patience = 1
	Rules.restart_encounter(clasp_run)
	check(clasp_run.shift == Rules.SHIFT_CLASP and clasp_run.traveler_index == 0, "restart encounter stays on the clasp bell")
	check(clasp_run.progress == 0 and clasp_run.patience == int(Rules.CLASP_BELL[0]["patience"]), "restart encounter resets Noll")
	check(clasp_run.library.size() == before and clasp_run.hand.size() == 5 and clasp_run.phase == "play", "restart keeps the clasp-bell deck and deals a hand")
	var redealt: Array = []
	for iid in clasp_run.hand:
		redealt.append(Rules.card_id_of(clasp_run, int(iid)))
	check(redealt == dealt, "restart deals Noll the same hand")

	var packed = load("res://game/main.tscn")
	var desk = packed.instantiate()
	root.add_child(desk)
	if desk.state == null:
		desk._ready()
	check(desk.state.shift == Rules.SHIFT_FIRST, "the desk still opens on Act 1")
	check(desk.clasp_button.text == "Clasp bell", "the desk offers the clasp bell")
	check(desk.headband_button.text == "Headband bell", "the desk still offers the headband bell")
	desk.clasp_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_CLASP, "the desk can open the clasp bell")
	check(String(Rules.traveler(desk.state)["name"]) == "Noll Hart", "the open desk shows Noll")
	check(String(desk.desk_label.text).begins_with("Clasp bell"), "the desk title follows the clasp bell")
	check(desk.meta_label.text.contains("Late Low"), "the desk shows Noll's form")
	check(desk.clasp_button.text == "First bell", "the clasp bell can return to the first bell")
	check(desk.headband_button.text == "Headband bell", "the headband bell stays available from the clasp bell")
	check(desk.shift_button.text == "Late shift", "the late shift stays available from the clasp bell")
	desk._restart_act()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_CLASP and String(Rules.traveler(desk.state)["name"]) == "Noll Hart", "restart act replays the clasp bell")
	desk.clasp_button.pressed.emit()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the clasp bell returns to Ada")
	var doors = [
		["_begin_late_shift", "Nell Parr", "the late shift"],
		["_begin_closing_bell", "Moss Quen", "the closing bell"],
		["_begin_ash_watch", "Orla Fen", "the ash watch"],
		["_begin_gutter_lamp", "Ivo Dane", "the gutter lamp"],
		["_begin_vellum_bell", "Edda Voss", "the vellum bell"],
		["_begin_quire_watch", "Tess Quern", "the quire watch"],
		["_begin_salt_watch", "Pell Voss", "the salt watch"],
		["_begin_quay_bell", "Mara Quill", "the quay bell"],
		["_begin_folio_bell", "Ness Hart", "the folio bell"],
		["_begin_wick_bell", "Odell Voss", "the wick bell"],
		["_begin_margin_bell", "Nim Voss", "the margin bell"],
		["_begin_index_bell", "Len Quill", "the index bell"],
		["_begin_ledger_bell", "Nell Voss", "the ledger bell"],
		["_begin_spine_bell", "Wynn Quill", "the spine bell"],
		["_begin_headband_bell", "Len Hart", "the headband bell"],
	]
	for door in doors:
		desk.call(String(door[0]))
		desk._refresh_ui()
		check(desk.state.shift != Rules.SHIFT_CLASP and String(Rules.traveler(desk.state)["name"]) == String(door[1]), "%s still opens" % String(door[2]))
		check(desk.clasp_button.text == "Clasp bell", "%s offers the clasp bell" % String(door[2]))
		desk._begin_clasp_bell()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_CLASP and String(Rules.traveler(desk.state)["name"]) == "Noll Hart", "%s can open the clasp bell" % String(door[2]))
	desk._begin_first_bell()
	desk._refresh_ui()
	check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "first bell still returns to Ada")
	var victories = [
		[Rules.SHIFT_FIRST, "Act 1"],
		[Rules.SHIFT_LATE, "the late shift"],
		[Rules.SHIFT_CLOSING, "the closing bell"],
		[Rules.SHIFT_ASH, "the ash watch"],
		[Rules.SHIFT_GUTTER, "the gutter lamp"],
		[Rules.SHIFT_VELLUM, "the vellum bell"],
		[Rules.SHIFT_QUIRE, "the quire watch"],
		[Rules.SHIFT_SALT, "the salt watch"],
		[Rules.SHIFT_QUAY, "the quay bell"],
		[Rules.SHIFT_FOLIO, "the folio bell"],
		[Rules.SHIFT_WICK, "the wick bell"],
		[Rules.SHIFT_MARGIN, "the margin bell"],
		[Rules.SHIFT_INDEX, "the index bell"],
		[Rules.SHIFT_LEDGER, "the ledger bell"],
		[Rules.SHIFT_SPINE, "the spine bell"],
		[Rules.SHIFT_HEADBAND, "the headband bell"],
	]
	for victory in victories:
		desk._open_shift(int(victory[0]), desk.state.seed)
		desk._refresh_ui()
		desk.state.phase = "victory"
		desk._refresh_ui()
		var victory_clasp = _button_named(desk, "Open the clasp bell")
		check(victory_clasp != null, "%s's victory desk offers the clasp bell" % String(victory[1]))
		if victory_clasp != null:
			victory_clasp.pressed.emit()
			desk._refresh_ui()
			check(desk.state.shift == Rules.SHIFT_CLASP and String(Rules.traveler(desk.state)["name"]) == "Noll Hart", "%s's victory desk opens the clasp bell" % String(victory[1]))
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_first = _button_named(desk, "Open the first bell")
	check(victory_first != null, "the clasp bell victory desk offers the first bell")
	if victory_first != null:
		victory_first.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_FIRST and String(Rules.traveler(desk.state)["name"]) == "Ada Quill", "the clasp bell victory desk opens the first bell")
	desk._begin_clasp_bell()
	desk._refresh_ui()
	desk.state.phase = "victory"
	desk._refresh_ui()
	var victory_headband = _button_named(desk, "Open the headband bell")
	check(victory_headband != null, "the clasp bell victory desk offers the headband bell")
	if victory_headband != null:
		victory_headband.pressed.emit()
		desk._refresh_ui()
		check(desk.state.shift == Rules.SHIFT_HEADBAND and String(Rules.traveler(desk.state)["name"]) == "Len Hart", "the clasp bell victory desk opens the headband bell")
	root.remove_child(desk)
	desk.free()


func test_policy_clears_clasp_bell() -> void:
	var started = Time.get_ticks_msec()
	var state = Rules.new_run(12345, Rules.SHIFT_CLASP)
	var steps = 0
	var seen = 0
	while state.phase != "victory":
		steps += 1
		if steps > 500 or state.phase == "defeat":
			check(false, "policy lost or stalled on the clasp bell, seed 12345: " + Rules.debug_summary(state))
			return
		var action = Policy.choose(state)
		if not Rules.apply_action(state, action):
			check(false, "clasp-bell policy action was rejected: %s / %s" % [str(action), Rules.debug_summary(state)])
			return
		if state.encounters_cleared != seen:
			seen = state.encounters_cleared
			print("cleared clasp encounter %d after %d actions" % [seen, steps])
	var elapsed = Time.get_ticks_msec() - started
	check(state.encounters_cleared == 4, "policy cleared all 4 clasp-bell encounters on seed 12345")
	check(state.phase == "victory", "clasp bell ends in victory")
	check(state.shift == Rules.SHIFT_CLASP, "the clear stayed on the clasp bell")
	print("clasp bell finished in %d actions, %d ms" % [steps, elapsed])
