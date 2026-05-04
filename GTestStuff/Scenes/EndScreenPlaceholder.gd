extends MeshInstance2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	$"../Label".hide()
	pass # Replace with function body.



func _on_player_start_game_ended() -> void:
	show()
	get_tree().paused = true
	$"../Label".show()
	pass # Replace with function body.
