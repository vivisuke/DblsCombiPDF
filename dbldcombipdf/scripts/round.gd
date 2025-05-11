class_name Round

extends Object

var m_pairs : PackedVector2Array
var m_resting : PackedByteArray

func set_first_round(n_players: int, n_resting: int):
	var n_not_resting = n_players - n_resting	# 非休憩中プレイヤー数
	m_pairs.resize(n_not_resting/2)
	for i in range(n_not_resting/2):
		m_pairs[i].x = i*2
		m_pairs[i].y = i*2 + 1
	m_resting.clear()
	for r in range(n_not_resting, n_players):
		m_resting.push_back(r)
func set_random(plst : PackedByteArray):	# 非休憩中プレイヤーリスト
	pass
