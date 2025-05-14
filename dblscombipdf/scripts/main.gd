extends Node2D

#var m_round = []		# 各ラウンド組み合わせ、要素：Array of Vector2, PackedByteArray
var sch
var m_n_corts = 2
var m_n_players = 10
var m_desc = true

func _ready() -> void:
	$HBC/CortSpinBox.set_value_no_signal(m_n_corts)
	$HBC/PlayerSpinBox.set_value_no_signal(m_n_players)
	sch = Schedule.new()
	gen_match()
func gen_match():
	sch.set_ncnp(m_n_corts, m_n_players)		# コート数、全プレイヤー数
	for r in range(1, 9):
		#sch.add_random_round()				# 休憩も含めて完全ランダム
		#sch.add_rotated_rest_round()		# 順番に休憩
		sch.add_balanced_pairs_round()		# 順番に休憩、同じペアを回避
	$Schedule.text = sch.to_str()
	$TabContainer/PairCounts.text = sch.pair_counts_str()
	var ave = sch.calc_oppo_counts_ave()
	var std = sch.calc_oppo_counts_std(ave)
	$TabContainer/OppoCounts.text = sch.oppo_counts_str() + ("ave = %.2f, std = %.2f"%[ave, std])
	#print("calc_oppo_counts_ave() = ", sch.calc_oppo_counts_ave())
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
