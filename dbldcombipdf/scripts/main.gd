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
	for r in range(1, 10):
		sch.add_random_round()
	$Schedule.text = sch.to_str()
	$TabContainer/PairCounts.text = sch.pair_counts_str()
	$TabContainer/OppoCounts.text = sch.oppo_counts_str()
	pass


func _on_order_button_toggled(toggled_on: bool) -> void:
	m_desc = toggled_on
	if m_desc:
		$HBC/OrderButton.text = "Desc"
	else:
		$HBC/OrderButton.text = "Asc"
	pass # Replace with function body.


func _on_cort_spin_box_value_changed(value: float) -> void:
	m_n_corts = int(value)
	$HBC/PlayerSpinBox.set_min(float(m_n_corts * 4))
	pass # Replace with function body.
func _on_player_spin_box_value_changed(value: float) -> void:
	m_n_players = int(value)
	pass # Replace with function body.

func _on_make_button_pressed() -> void:
	gen_match()
	pass # Replace with function body.
