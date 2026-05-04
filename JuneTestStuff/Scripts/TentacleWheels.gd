extends Area3D

@onready var bike = $"../../Bike"

var prev_state = null
var current_state = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.name == "Bike":
		print("Entered Area")
		if bike.current_wheel_mode != bike.WheelMode.TENTACLE:
			bike._set_wheel_mode(bike.WheelMode.TENTACLE)
			print("TENTACLE WHEEL ACTIVATED")
		elif bike.current_wheel_mode == bike.WheelMode.TENTACLE:
			bike._set_wheel_mode(bike.WheelMode.NORMAL)
			print("TENTACLE WHEEL DEACTIVATED")

func _on_body_exited(body: Node) -> void:
	if body.name == "Bike":
		print("Exited Area")
