extends Area3D

@export var locator : Node3D
@onready var engineSanity = get_node("/root/FinalMainScene/UserInterface/EngineSanity")

var crashDamage: float = 20.0 #NEW
var can_hit := true #NEW

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
func _on_body_entered(body: Node) -> void:
	if body.name == "Bike":
		#locator.global_position = CheckPointManager.lastStablePosition
		body.global_position = CheckPointManager.lastStablePosition
		body.global_rotation =  Vector3.ZERO #CheckPointManager.lastStablePosition
		body.angular_velocity = Vector3.ZERO
		body.linear_velocity = Vector3.ZERO
		if engineSanity and can_hit: #NEW
			can_hit = false #NEW
			engineSanity.takeDamage(crashDamage) #NEW
				# reset after short delay
		if get_node("/root/FinalMainScene/Bike") != null:
			await get_tree().create_timer(0.5).timeout #NEW
		can_hit = true #NEW

func _on_body_exited(body: Node) -> void:
	if body.name == "Bike":	
		for i in 3:	
			if get_node("/root/FinalMainScene/Bike") != null:
				body.visible = false
				await get_tree().create_timer(0.25).timeout
				body.visible = true
				await get_tree().create_timer(0.25).timeout
