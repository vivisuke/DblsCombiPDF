extends Node2D

#var m_round = []		# 各ラウンド組み合わせ、要素：Array of Vector2, PackedByteArray
var sch

func _ready() -> void:
	sch = Schedule.new()
	sch.set_ncnp(3, 12)		# コート数、全プレイヤー数
	pass
	
	


func _on_make_button_pressed() -> void:
	pass # Replace with function body.
