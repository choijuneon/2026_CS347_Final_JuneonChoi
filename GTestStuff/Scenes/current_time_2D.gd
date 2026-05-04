extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_player_start_time_changed(new_value: Variant) -> void:
	text = str(new_value)
	pass # Replace with function body.
