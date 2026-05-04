extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playing = true
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (!$"../EngineLowGearAudio".playing && !$"../EngineHighGearAudio".playing):
		if (!playing):
			play()
		if ($"../TireDrone".playing):
			$"../TireDrone".playing = false
	else:
		if (!$"../TireDrone".playing):
			$"../TireDrone".playing = true
	pass
