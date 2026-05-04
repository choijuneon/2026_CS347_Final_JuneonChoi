extends Area3D

@export var pathFollow : PathFollow3D
@export var statusIndicator : Node3D
@export var bike : Node3D

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node) -> void:
	if body == bike:
		bike.global_position = statusIndicator.global_position
		bike.rotation.y = deg_to_rad(-60)
		
		bike.apply_force(Vector3(1,1,-1) * 30000)
		
		bike.reparent(pathFollow)
		
		pathFollow.is_bike_on_rail = true

func _process(delta: float) -> void:
	#print(pathFollow.progress_ratio)
	if pathFollow.progress_ratio > 0.98:
			bike.reparent(get_tree().root)
			
			pathFollow.is_bike_on_rail = false
			
			pathFollow.progress = 0
