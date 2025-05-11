class_name Schedule

extends Object

var m_rounds = []

func _init() -> void:
	var round = Round.new()
	round.set_fist_round(10, 2)		# 全プレイヤー数、休憩中プレイヤー数
	m_rounds = [round]
	pass
