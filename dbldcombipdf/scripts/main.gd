extends Node2D

#var m_round = []		# 各ラウンド組み合わせ、要素：Array of Vector2, PackedByteArray
var sch
var m_desc = true

func _ready() -> void:
	sch = Schedule.new()
	sch.set_ncnp(3, 14)		# コート数、全プレイヤー数
	for r in range(1, 10):
		sch.add_random_round()
	$Schedule.text = sch.to_str()
	$TabContainer/PairCounts.text = sch.pair_counts_str()
	$TabContainer/OppoCounts.text = sch.oppo_counts_str()
	pass
	
	


func _on_make_button_pressed() -> void:
	pass # Replace with function body.


func _on_order_button_toggled(toggled_on: bool) -> void:
	m_desc = toggled_on
	if m_desc:
		$HBC/OrderButton.text = "Desc"
	else:
		$HBC/OrderButton.text = "Asc"
	pass # Replace with function body.
