extends Area3D

var magnet_target = null
var magnet_speed = 20.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_body_entered(body: Node3D) -> void:
		if body.name == "Bike": #NEW
			var sanity = get_node("/root/FinalMainScene/UserInterface/EngineSanity")
			# heal 20 HP
			sanity.current_hp += 20
			# update the UI bar
			sanity.health_bar.value = sanity.current_hp
			queue_free()

func start_magnet(target):
	magnet_target = target

func _physics_process(delta):

	if magnet_target != null:
		var direction = magnet_target.global_position - global_position
		global_position += direction.normalized() * magnet_speed * delta
