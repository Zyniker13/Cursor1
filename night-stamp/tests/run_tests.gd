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
	test_reward_flow_and_restart()
	test_policy_clears_act()
	test_policy_clears_late_shift()
	test_policy_clears_closing_bell()
	test_policy_clears_ash_watch()
	test_policy_clears_gutter_lamp()
	test_policy_clears_vellum_bell()
	test_policy_clears_quire_watch()
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
