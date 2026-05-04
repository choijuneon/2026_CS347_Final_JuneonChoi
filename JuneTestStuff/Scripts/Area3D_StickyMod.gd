extends Area3D

var prev_over_extend = 0.0

var g_scale := 0.0
var wheel_array := ["WheelRR","WheelRM","WheelRL","WheelFR","WheelFM","WheelFL"]

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node) -> void:
	if body.name == "Bike":
		body.gravity_scale = g_scale
