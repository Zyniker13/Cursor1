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
	test_reward_flow_and_restart()
	test_policy_clears_act()
	test_policy_clears_late_shift()
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
