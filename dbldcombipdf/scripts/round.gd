class_name Round

extends Object

var m_pairs : PackedVector2Array
var m_resting : PackedByteArray

func print():
	print(to_str())
func to_str():
	var txt = ""
	var i = 0
	for p in m_pairs:
		txt += "%2d %2d "%[p.x+1, p.y+1]
		if i%2 == 0: txt += ": "
		else: txt += "| "
		i += 1
	txt += "Rest: "
	for r in m_resting:
		txt += "%2d "%(r+1)
	return txt
func set_first_round(n_players: int, n_resting: int):
	var n_not_resting = n_players - n_resting	# 非休憩中プレイヤー数
	m_pairs.resize(n_not_resting/2)
	for i in range(n_not_resting/2):
		m_pairs[i].x = i*2
		m_pairs[i].y = i*2 + 1
	m_resting.clear()
	for r in range(n_not_resting, n_players):
		m_resting.push_back(r)
func set_round(ar : Array, n_resting: int):
	var n_not_resting = ar.size() - n_resting
	m_pairs.resize(n_not_resting/2)
	for i in range(n_not_resting/2):
		m_pairs[i].x = ar[i*2]
		m_pairs[i].y = ar[i*2 + 1]
	m_resting.clear()
	for r in range(n_not_resting, ar.size()):
		m_resting.push_back(ar[r])
func set_random(plst : PackedByteArray):	# 非休憩中プレイヤーリスト
	pass
