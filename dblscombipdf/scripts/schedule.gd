class_name Schedule

extends Object

var m_n_corts = 1
var m_n_players = 4
var m_n_resting = 0
var m_first_resting_pid = 0
var m_last_resting_pid = 0			# [first, last) 範囲が休憩中
var m_rest_order_desc = true		# 休憩順：降順・昇順
var m_rounds = []
var m_pair_counts = []
var m_oppo_counts = []

const A4_LANDSCAPE = Vector2i(842, 595)

func _init() -> void:
	pass
func to_str():
	var txt = ""
	var r = 0
	for round in m_rounds:
		r += 1
		txt += "R%d: "%r
		txt += round.to_str()
		txt += "\n"
	return txt
func pair_counts_str():
	var txt = ""
	for y in range(m_n_players):
		txt += "%2d: "%(y+1)
		for x in range(m_n_players):
			if x != y:
				txt += "%2d"%m_pair_counts[y][x]
			else:
				txt += " -"
		txt += "\n";
	return txt
func oppo_counts_str():
	var txt = ""
	for y in range(m_n_players):
		txt += "%2d: "%(y+1)
		for x in range(m_n_players):
			if x != y:
				txt += "%2d"%m_oppo_counts[y][x]
			else:
				txt += " -"
		txt += "\n";
	return txt
func set_ncnp(n_corts, n_players, desc=true):
	m_n_corts = n_corts
	m_n_players = n_players
	m_n_resting = n_players - n_corts * 4
	m_first_resting_pid = n_corts * 4
	m_last_resting_pid = m_n_players
	m_rest_order_desc = desc
	var round = Round.new()
	round.set_first_round(m_n_players, m_n_resting)
	m_rounds = [round]
	init_pair_counts()
	init_oppo_counts()
	update_pair_counts(round.m_pairs)
	update_oppo_counts(round.m_pairs)
func add_random_round():	#  休憩も完全ランダム
	var ar = []
	ar.resize(m_n_players)
	for i in range(m_n_players): ar[i] = i
	ar.shuffle()
	#var lst = PackedByteArray()
	#lst.resize(m_n_players)
	#for i in range(m_n_players): lst[i] = ar[i]
	var round = Round.new()
	round.set_round(ar, m_n_resting)
	m_rounds.push_back(round)
	update_pair_counts(round.m_pairs)
	update_oppo_counts(round.m_pairs)
func update_next_resting():
	if m_rest_order_desc:
		m_first_resting_pid -= m_n_resting
		if m_first_resting_pid < 0: m_first_resting_pid += m_n_players
	else:
		m_first_resting_pid += m_n_resting
		if m_first_resting_pid >= m_n_players: m_first_resting_pid -= m_n_players
	m_last_resting_pid = (m_first_resting_pid + m_n_resting) % m_n_players
func get_not_resting_players_array() -> Array:
	var ar = []
	for i in range(m_n_players):
		if m_n_resting == 0:
			ar.push_back(i)
		elif m_first_resting_pid < m_last_resting_pid:
			if i < m_first_resting_pid || i >= m_last_resting_pid:
				ar.push_back(i)
		else:
			if i < m_first_resting_pid && i >= m_last_resting_pid:
				ar.push_back(i)
	return ar
func add_rotated_rest_round():	#  順番に休憩をとる組み合わせ生成
	update_next_resting()
	var ar = get_not_resting_players_array()	# 非休憩プレヤーリスト取得
	ar.shuffle()				# ランダムシャフル
	for i in range(m_n_resting):	# 休憩中プレイヤーid追加
		ar.push_back((m_first_resting_pid + i) % m_n_players)
	var round = Round.new()
	round.set_round(ar, m_n_resting)
	m_rounds.push_back(round)
	update_pair_counts(round.m_pairs)
	update_oppo_counts(round.m_pairs)
func swap(ar: Array, ix1, ix2):
	var t = ar[ix1]
	ar[ix1] = ar[ix2]
	ar[ix2] = t
func make_pair_asc(ar: Array):
	for i in range(0, ar.size(), 2):
		if ar[i] > ar[i+1]: swap(ar, i, i+1)
	for i in range(0, ar.size(), 4):
		if ar[i] > ar[i+2]:
			swap(ar, i, i+2)
			swap(ar, i+1, i+3)
func make_balanced_pairs(ar: Array, ix) -> bool:
	if ix == ar.size(): return true
	var p1 = ar[ix]
	for k in range(1, ar.size()-ix, 1):
		if m_pair_counts[p1][ar[ix+k]] == 0:
			swap(ar, ix+1, ix+k)
			if make_balanced_pairs(ar, ix+2): return true
			swap(ar, ix+1, ix+k)
	return false
func add_balanced_pairs_round():	# 同じペアと組まない組み合わせ生成
	update_next_resting()
	var ar = get_not_resting_players_array()	# 非休憩プレヤーリスト取得
	ar.shuffle()				# ランダムシャフル
	make_balanced_pairs(ar, 0)
	make_pair_asc(ar)
	for i in range(m_n_resting):	# 休憩中プレイヤーid追加
		ar.push_back((m_first_resting_pid + i) % m_n_players)
	var round = Round.new()
	round.set_round(ar, m_n_resting)	# ar のペアリストを round に反映
	m_rounds.push_back(round)
	update_pair_counts(round.m_pairs)
	update_oppo_counts(round.m_pairs)
	pass
func eval_oppo(plist):		# plist: array of Vector2i
	var ev = 0
	update_oppo_counts(plist)
	undo_oppo_counts(plist)
	return ev
	
func add_balanced_oppo_round():	# 対戦相手がバランスする組み合わせ生成
	update_next_resting()
	var ar = get_not_resting_players_array()	# 非休憩プレヤーリスト取得
	ar.shuffle()				# ランダムシャフル
	make_balanced_pairs(ar, 0)
	#
	var plist = PackedVector2Array()		# ペアリスト
	for i in range(0, ar.size(), 2):
		plist.push_back(Vector2i(ar[i], ar[i+1]))
	var minev = 1000*1000
	var plist2 = []
	for i in range(1000):
		plist.shuffle()
		var ev = eval_oppo(plist)
		if ev < minev:
			minev = ev
			plist2 = plist.duplicate()
	ar = []
	for v in plist2:
		ar.push_back(v.x)
		ar.push_back(v.y)
	#
	make_pair_asc(ar)
	for i in range(m_n_resting):	# 休憩中プレイヤーid追加
		ar.push_back((m_first_resting_pid + i) % m_n_players)
	var round = Round.new()
	round.set_round(ar, m_n_resting)
	m_rounds.push_back(round)
	update_pair_counts(round.m_pairs)
	update_oppo_counts(round.m_pairs)
	pass
func calc_oppo_counts_ave() -> float:
	var sum = 0
	for p1 in range(m_n_players):
		for p2 in range(m_n_players):
			if p1 != p2:
				sum += m_oppo_counts[p1][p2]
	return float(sum) / (m_n_players * (m_n_players-1))
func calc_oppo_counts_std(ave) -> float:
	var sum2 = 0.0
	for p1 in range(m_n_players):
		for p2 in range(m_n_players):
			if p1 != p2:
				var d = m_oppo_counts[p1][p2] - ave
				sum2 += d * d
	return sqrt(sum2/(m_n_players * (m_n_players-1)))
func init_pair_counts():
	m_pair_counts.resize(m_n_players)
	for i in range(m_n_players):
		m_pair_counts[i] = PackedByteArray()
		m_pair_counts[i].resize(m_n_players)
		m_pair_counts[i].fill(0)
		pass
func update_pair_counts(pairs : PackedVector2Array):
	for p in pairs:
		m_pair_counts[p.x][p.y] += 1
		m_pair_counts[p.y][p.x] += 1
func init_oppo_counts():
	m_oppo_counts.resize(m_n_players)
	for i in range(m_n_players):
		m_oppo_counts[i] = PackedByteArray()
		m_oppo_counts[i].resize(m_n_players)
		m_oppo_counts[i].fill(0)
		pass
func update_oppo_counts(pairs : PackedVector2Array):
	for i in range(0, pairs.size(), 2):
		m_oppo_counts[pairs[i].x][pairs[i+1].x] += 1
		m_oppo_counts[pairs[i].x][pairs[i+1].y] += 1
		m_oppo_counts[pairs[i+1].x][pairs[i].x] += 1
		m_oppo_counts[pairs[i+1].x][pairs[i].y] += 1
		m_oppo_counts[pairs[i].y][pairs[i+1].x] += 1
		m_oppo_counts[pairs[i].y][pairs[i+1].y] += 1
		m_oppo_counts[pairs[i+1].y][pairs[i].x] += 1
		m_oppo_counts[pairs[i+1].y][pairs[i].y] += 1
func undo_oppo_counts(pairs : PackedVector2Array):
	pass
func gen_PDF() -> bool:
	# Create a new PDF document 
	# This just resets the current PDF data
	# This also adds 1 blank page to the PDF
	PDF.newPDF() #PDF.newPDF("New PDF", "Godette")
	PDF.setTitle("New PDF")
	PDF.setCreator("DblsCombiPDF")
	PDF.setPageSize(A4_LANDSCAPE)
	
	# All operations from here on return true or false
	# Use returns to verify functions are running correctly
	
	# Add some text to page 1
	# Format is (page number, position, text, font size, font)
	# Pages are 612x792 units
	# Font size is optional (Default is 12pt)
	# Font is optional (Default is Helvetica)
	# Fonts MUST be added prior to using them
	#PDF.newLabel(1, Vector2(250,10), "Hello world")
	#PDF.newLabel(1, Vector2(250,10), "%d面 %d人"%[m_n_corts, m_n_players])
	
	# Add a new font and a new label using the font
	# Format is (fontName, fontPath)
	# Path MUST be to .ttf file
	#PDF.newFont("Amplify", "res://addons/godotpdf/Amplify.ttf")
	#PDF.newLabel(1, Vector2(250,30), "GodotPDF is awesome!", 20, "Amplify")
	PDF.newFont("ZenKakuGothicNew", "res://addons/godotpdf/ZenKakuGothicNew-Medium.ttf")
	var txt = "%d Corts, %d Players"%[m_n_corts, m_n_players]
	#var txt = "Num-Corts: %d, Num-Players: %d"%[m_n_corts, m_n_players]
	#var txt = "%d面 %d人"%[m_n_corts, m_n_players]
	PDF.newLabel(1, Vector2(300,10), txt, 20, "ZenKakuGothicNew")

	# box(position=Vector2i(0,0), size=Vector2i(0,0), fill=Color(0.0,0.0,0.0,1.0), border=Color(0.0,0.0,0.0,1.0), borderWidth=10) -> void:
	#PDF.newBox(1, Vector2(100, 100), Vector2(200, 300), Color(1.0,1.0,1.0,1.0), Color(0.0,1.0,0.0,0.0), 3)
	var x0 = 10
	var y0 = 40
	var wd = A4_LANDSCAPE.x - 20
	var ht = A4_LANDSCAPE.y - 50
	PDF.newBox(1, Vector2(x0, y0), Vector2(wd, ht), Color.WHITE, Color.BLACK, 1)
	var dy = ht / 10.0
	var y = y0
	for i in range(9):
		y += dy
		PDF.newBox(1, Vector2(x0, y), Vector2(wd, 0), Color.WHITE, Color.BLACK, 0)
	var dx = wd / 3.0
	var x = x0
	var pid = 0
	for i in range(3):
		#txt = "%d %d - %d %d" % [pid+1, pid+2, pid+3, pid+4]
		#PDF.newLabel(1, Vector2(x+60, y0+5), txt, 40, "ZenKakuGothicNew")
		#pid += 4
		if i == 2: break;
		x += dx
		PDF.newBox(1, Vector2(x, y0), Vector2(0, ht), Color.WHITE, Color.BLACK, 0)
	y = y0
	for v in range(m_rounds.size()):
		var r = m_rounds[v]
		#print(r.m_pairs)
		x = x0
		for h in range(3):
			txt = "%2d %2d - %2d %2d" % [r.m_pairs[h*2].x+1, r.m_pairs[h*2].y+1, r.m_pairs[h*2+1].x+1, r.m_pairs[h*2+1].y+1]
			PDF.newLabel(1, Vector2(x+40, y+5), txt, 40, "ZenKakuGothicNew")
			x += dx
		y += dy
	#
	# Set the path to export the pdf to
	# The target file MUST be of the .pdf type
	var path = getDesktopPath() + "/GodotPDF.pdf"
	
	# Export the pdf data
	# Images will ALWAYS draw behind boxes, which will ALWAYS draw behind text
	var status : bool = PDF.export(path)
	
	# Print export status
	print("Export successful: " + str(status))

	return status

func getDesktopPath():	# gets path to user desktop
	var ret = ""
	var slashes = 0
	for i in OS.get_user_data_dir():
		if i == "/":
			slashes += 1
		if slashes == 3:
			return ret + "/Desktop"
		else:
			ret += i
