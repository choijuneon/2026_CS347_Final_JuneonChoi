extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(_event):
	if Input.is_action_just_released("pauseGame"):
		if (get_tree().paused):
			get_tree().paused = false
			hide()
		else:
			get_tree().paused = true
			show()
