extends ProgressBar

@export var bike : Node3D

func _ready() -> void:
	value = 0.0
	max_value = bike.max_charge_sec
func _process(_delta: float) -> void:
	value = bike.charged_time
