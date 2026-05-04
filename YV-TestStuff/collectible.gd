extends Area3D
#
##THIS IS THE OIL COLLECTABLE
#
#var magnet_target = null
#var magnet_speed = 20.0
#
@onready var meshes = $Meshes
@onready var effect = $SparkleParticle

func _process(_delta: float):
	rotate_y(0.01)
#
func _on_body_entered(body: Node3D) -> void:
	if body.name == "Bike": #NEW
		#var label = get_node("/root/FinalMainScene/UserInterface/Bolts/BoltsImage/NumberOfBolts")
		#label._on_pickup()
		
		meshes.visible = false
		effect.emitting = true
		await get_tree().create_timer(effect.lifetime).timeout
		
		queue_free()
#
#func start_magnet(target):
	#magnet_target = target
#
#func _physics_process(delta):
#
	#if magnet_target != null:
		#var direction = magnet_target.global_position - global_position
		#global_position += direction.normalized() * magnet_speed * delta
