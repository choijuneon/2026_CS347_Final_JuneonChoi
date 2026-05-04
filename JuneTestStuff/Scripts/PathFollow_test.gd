extends PathFollow3D

@export var speed = 10.0

var is_bike_on_rail = false

func _process(delta: float) -> void:
	if is_bike_on_rail == false:
		pass
	if is_bike_on_rail == true:
		progress += delta * speed
