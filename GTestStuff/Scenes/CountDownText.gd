extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = str($"..".startCount)
	pass # Replace with function body.

func _on_player_start_countdown_changed(new_value: Variant) -> void:
	text = str(new_value)
	pass # Replace with function body.


func _on_player_start_count_down_end() -> void:
	hide()
	pass # Replace with function body.
