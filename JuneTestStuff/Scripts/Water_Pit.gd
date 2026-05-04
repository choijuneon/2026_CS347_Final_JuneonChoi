extends Node3D

@export var modeMethods : Node
@export var initial_speed := 2400.0
@export var slower_speed := 1200.0

var bike : Node3D
var is_bike_in_area := false

func _ready() -> void:
	if modeMethods == null:
		modeMethods = get_node_or_null("../../../ModMethods")

func _process(delta: float) -> void:
	if is_bike_in_area:
		if modeMethods.activeWheelMode != 9:
			_slow_bike_speed(bike)
		else:
			_reset_bike_speed(bike)
	
func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Bike":
		bike = body
		if modeMethods.activeWheelMode != 9:
			_slow_bike_speed(body)
		is_bike_in_area = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Bike":
		_reset_bike_speed(body)
		is_bike_in_area = false
	
func _slow_bike_speed(bike: Node3D) -> void:
		bike.acceleration = slower_speed
	
func _reset_bike_speed(bike: Node3D) -> void:
	bike.acceleration = initial_speed
