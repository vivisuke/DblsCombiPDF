extends Node2D

#var m_round = []		# 各ラウンド組み合わせ、要素：Array of Vector2, PackedByteArray
var sch
var m_n_corts = 2
var m_n_players = 10
var m_n_rounds = 8
var m_desc = true

const ar_table = [
		[0, 3, 6, 9, 1, 4, 7, 10, 2, 5, 8, 11],
		[1, 11, 4, 7, 2, 10, 5, 6, 0, 9, 3, 8],
		[2, 9, 5, 8, 3, 10, 6, 11, 0, 4, 1, 7],
		[5, 9, 3, 6, 0, 7, 2, 11, 1, 8, 4, 10],
		[1, 3, 5, 7, 0, 2, 8, 10, 4, 6, 9, 11],
		[2, 7, 4, 8, 1, 6, 3, 11, 0, 5, 9, 10],
		[0, 6, 4, 9, 1, 10, 7, 11, 3, 5, 2, 8],
	]
const ar_table_312 = [
		[2, 7, 9, 10, 0, 11, 3, 4, 1, 8, 5, 6],
		[0, 10, 1, 7, 4, 9, 5, 8, 2, 6, 3, 11],
		[1, 10, 3, 5, 0, 9, 4, 6, 2, 8, 7, 11],
		[1, 3, 7, 8, 0, 5, 9, 11, 2, 4, 6, 10],
		[6, 11, 7, 10, 3, 8, 5, 9, 0, 4, 1, 2],
		[3, 11, 4, 6, 1, 9, 7, 10, 0, 2, 5, 8],
		[1, 8, 2, 4, 0, 5, 10, 11, 3, 6, 7, 9],
	]


func _ready() -> void:
	$HBC/CortSpinBox.set_value_no_signal(m_n_corts)
	$HBC/PlayerSpinBox.set_value_no_signal(m_n_players)
	$HBC/RoundsSpinBox.set_value_no_signal(m_n_rounds)
	sch = Schedule.new()
	gen_match12()
func gen_match12():
	if false:
		sch.set_ncnp(m_n_corts, m_n_players, m_desc)		# コート数、全プレイヤー数
	else:
		m_n_corts = 3
		m_n_players = 12
		sch.set_ncnp(m_n_corts, m_n_players, m_desc)		# コート数、全プレイヤー数
		for ar in ar_table_312:
			var round = Round.new()
			round.set_round(ar, 0)
			sch.m_rounds.push_back(round)
			sch.update_pair_counts(round.m_pairs)
			sch.update_oppo_counts(round.m_pairs)
		$HBC/PDFButton.disabled = false
	$Schedule.text = sch.to_str()
	$TabContainer/PairCounts.text = sch.pair_counts_str()
	var ave = sch.calc_oppo_counts_ave()
	var std = sch.calc_oppo_counts_std(ave)
	sch.m_oc_std = std
	$TabContainer/OppoCounts.text = sch.oppo_counts_str() + ("ave = %.3f, std = %.3f"%[ave, std])
func gen_match():
	sch.set_ncnp(m_n_corts, m_n_players, m_desc)		# コート数、全プレイヤー数
	var nr = $HBC/RoundsSpinBox.value					# ラウンド数
	for r in range(1, nr):
		#sch.add_random_round()				# 休憩も含めて完全ランダム
		#sch.add_rotated_rest_round()		# 順番に休憩
		#sch.add_balanced_pairs_round()		# 順番に休憩、同じペアを回避
		#sch.add_balanced_oppo_round()		# 順番に休憩、同じペアを回避、対戦相手も平均的に
		sch.add_most_balanced_oppo_round()		# 順番に休憩、同じペアを回避、対戦相手も平均的に
	$Schedule.text = sch.to_str()
	$TabContainer/PairCounts.text = sch.pair_counts_str()
	var ave = sch.calc_oppo_counts_ave()
	var std = sch.calc_oppo_counts_std(ave)
	sch.m_oc_std = std
	$TabContainer/OppoCounts.text = sch.oppo_counts_str() + ("ave = %.3f, std = %.3f"%[ave, std])
	#print("calc_oppo_counts_ave() = ", sch.calc_oppo_counts_ave())
	#
	#if false:
	for loop in range(7):
		var minstd = 9999
		var minr
		for r in range(1, nr, 1):
			sch.undo_oppo_counts(sch.m_rounds[r].m_pairs)
			ave = sch.calc_oppo_counts_ave()
			std = sch.calc_oppo_counts_std(ave)
			if std < minstd:
				minstd = std
				minr = r
			print("%d: std = %.3f"%[r+1, std])
			sch.update_oppo_counts(sch.m_rounds[r].m_pairs)
			#sch.m_rounds.remove_at(1)
			#print(sch.to_str())
		print("min %d: std = %.3f"%[minr+1, minstd])
		sch.undo_pair_counts(sch.m_rounds[minr].m_pairs)
		sch.undo_oppo_counts(sch.m_rounds[minr].m_pairs)
		var players = []
		for i in range(m_n_corts*2):
			players.push_back(sch.m_rounds[minr].m_pairs[i].x)
			players.push_back(sch.m_rounds[minr].m_pairs[i].y)
		var frpid = -1
		if !sch.m_rounds[minr].m_resting.is_empty():
			frpid = sch.m_rounds[minr].m_resting[0]
		#sch.m_rounds.remove_at(minr)
		sch.add_most_balanced_oppo_round(players, frpid, minr)
		ave = sch.calc_oppo_counts_ave()
		std = sch.calc_oppo_counts_std(ave)
		sch.m_oc_std = std
		print("std = %.3f"%std)
	$Schedule.text = sch.to_str()
	$TabContainer/PairCounts.text = sch.pair_counts_str()
	$TabContainer/OppoCounts.text = sch.oppo_counts_str() + ("ave = %.3f, std = %.3f"%[ave, std])
	#print(sch.to_str())
	#print(sch.oppo_counts_str())
	pass


func _on_order_button_toggled(toggled_on: bool) -> void:
	m_desc = toggled_on
	if m_desc:
		$HBC/OrderButton.text = "Desc"
	else:
		$HBC/OrderButton.text = "Asc"
	$HBC/PDFButton.disabled = true
	pass # Replace with function body.
func _on_cort_spin_box_value_changed(value: float) -> void:
	m_n_corts = int(value)
	$HBC/PlayerSpinBox.set_min(float(m_n_corts * 4))
	$HBC/PDFButton.disabled = true
	pass # Replace with function body.
func _on_player_spin_box_value_changed(value: float) -> void:
	m_n_players = int(value)
	sch.set_ncnp(m_n_corts, m_n_players, m_desc)
	$HBC/PDFButton.disabled = true
	pass # Replace with function body.
func _on_rounds_spin_box_value_changed(value: float) -> void:
	m_n_rounds = value
	$HBC/PDFButton.disabled = true
	pass # Replace with function body.

func _on_make_button_pressed() -> void:
	gen_match()
	$HBC/PDFButton.disabled = false
	pass # Replace with function body.


func _on_pdf_button_pressed() -> void:
	var status : bool = sch.gen_PDF()
	$AcceptDialog.title = "PDF"
	if status:
		$AcceptDialog.dialog_text = "Export successful"
	else:
		$AcceptDialog.dialog_text = "Export failed"
	$AcceptDialog.popup_centered()
	pass # Replace with function body.
