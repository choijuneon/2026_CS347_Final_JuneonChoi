extends Area3D

@export var is_g_heading_up := false

var prev_over_extend = 0.0

var g_scale := 1.0
var wheel_array := ["WheelRR","WheelRM","WheelRL","WheelFR","WheelFM","WheelFL"]

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node) -> void:
	if is_g_heading_up == false:
		g_scale = 1.0
	else:
		g_scale = -1.0
		
	if body.name == "Bike":
		body.gravity_scale = g_scale
		prev_over_extend = body.get_node(wheel_array[1]).over_extend
		for wheel in wheel_array:
			body.get_node(wheel).over_extend = 0.0
		body.apply_torque_impulse(body.global_basis.z * 200)
		await get_tree().create_timer(0.1).timeout
		for wheel in wheel_array:
			body.get_node(wheel).over_extend = prev_over_extend
