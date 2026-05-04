extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_down() -> void:
	$SimonSaysCode.addDown()
	$SimonSaysCode.check()
	pass # Replace with function body.

func _on_button_right() -> void:
	$SimonSaysCode.addRight()
	$SimonSaysCode.check()
	pass # Replace with function body.

func _on_button_up() -> void:
	$SimonSaysCode.addUp()
	$SimonSaysCode.check()
	pass # Replace with function body.

func _on_button_left() -> void:
	$SimonSaysCode.addLeft()
	$SimonSaysCode.check()
	pass # Replace with function body.
