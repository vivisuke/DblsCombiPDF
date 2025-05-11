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
func set_ncnp(n_corts, n_players):
	m_n_corts = n_corts
	m_n_players = n_players
	m_n_resting = n_players - n_corts * 4
	var round = Round.new()
	round.set_first_round(m_n_players, m_n_resting)
	round.print()
	m_rounds = [round]
	init_pair_counts()
	init_oppo_counts()
func init_pair_counts():
	m_pair_counts.resize(m_n_players)
	for i in range(m_n_players):
		m_pair_counts[i] = PackedByteArray()
		m_pair_counts[i].resize(m_n_players)
		m_pair_counts[i].fill(0)
		pass
func init_oppo_counts():
	m_oppo_counts.resize(m_n_players)
	for i in range(m_n_players):
		m_oppo_counts[i] = PackedByteArray()
		m_oppo_counts[i].resize(m_n_players)
		m_oppo_counts[i].fill(0)
		pass
