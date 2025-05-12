class_name Schedule

extends Object

var m_n_corts = 1
var m_n_players = 4
var m_n_resting = 0
var m_rounds = []
var m_pair_counts = []
var m_oppo_counts = []

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
			txt += "%2d"%m_pair_counts[y][x]
		txt += "\n";
	return txt
func oppo_counts_str():
	var txt = ""
	for y in range(m_n_players):
		txt += "%2d: "%(y+1)
		for x in range(m_n_players):
			txt += "%2d"%m_oppo_counts[y][x]
		txt += "\n";
	return txt
func set_ncnp(n_corts, n_players, desc=true):
	m_n_corts = n_corts
	m_n_players = n_players
	m_n_resting = n_players - n_corts * 4
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
func gen_PDF():
	# Create a new PDF document 
	# This just resets the current PDF data
	# This also adds 1 blank page to the PDF
	PDF.newPDF() #PDF.newPDF("New PDF", "Godette")
	PDF.setTitle("New PDF")
	PDF.setCreator("DblsCombiPDF")
	
	# All operations from here on return true or false
	# Use returns to verify functions are running correctly
	
	# Add some text to page 1
	# Format is (page number, position, text, font size, font)
	# Pages are 612x792 units
	# Font size is optional (Default is 12pt)
	# Font is optional (Default is Helvetica)
	# Fonts MUST be added prior to using them
	PDF.newLabel(1, Vector2(250,10), "Hello world")
	
	# Add a new font and a new label using the font
	# Format is (fontName, fontPath)
	# Path MUST be to .ttf file
	#PDF.newFont("Amplify", "res://addons/godotpdf/Amplify.ttf")
	#PDF.newLabel(1, Vector2(250,30), "GodotPDF is awesome!", 20, "Amplify")

	# box(position=Vector2i(0,0), size=Vector2i(0,0), fill=Color(0.0,0.0,0.0,1.0), border=Color(0.0,0.0,0.0,1.0), borderWidth=10) -> void:
	PDF.newBox(1, Vector2(100, 100), Vector2(200, 300), Color(1.0,1.0,1.0,1.0), Color(0.0,1.0,0.0,0.0), 3)

	#
	# Set the path to export the pdf to
	# The target file MUST be of the .pdf type
	var path = getDesktopPath() + "/GodotPDF.pdf"
	
	# Export the pdf data
	# Images will ALWAYS draw behind boxes, which will ALWAYS draw behind text
	var status = PDF.export(path)
	
	# Print export status
	print("Export successful: " + str(status))
	pass

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
