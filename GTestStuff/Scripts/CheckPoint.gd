extends Area3D

@export var bike : Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	CheckPointManager.addPosition(position)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node) -> void:
	if body.name == "Bike":
		CheckPointManager.setLastStableLocation()
		CheckPointManager.removePosition(position)
		pass
