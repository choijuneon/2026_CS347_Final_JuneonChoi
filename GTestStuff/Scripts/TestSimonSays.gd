extends Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"../SimonSaysCode".wantedChanged.connect(showWanted)
	$"../SimonSaysCode".randomizeWanted()
	pass # Replace with function body.

func showWanted() -> void:
	text = $"../SimonSaysCode".getWanted()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
