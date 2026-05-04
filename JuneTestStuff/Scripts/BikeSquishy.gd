extends Node3D

@onready var bike : RigidBody3D = $".."
@onready var model: Node3D = $"../Model_grp"
@onready var ray: RayCast3D = $"../TerrainTypeChecker"

var base_scale: Vector3
var target_scale: Vector3

var was_grounded := false

func _ready() -> void:
	base_scale = model.scale
	target_scale = base_scale

func _process(delta: float) -> void:
	var grounded = ray.is_colliding()
	
	#landing moment
	if grounded and not was_grounded:
		_on_land()
	#takeoff moment
	elif not grounded and was_grounded:
		_on_takeoff()
	
	if bike.is_jump_charging:
		_on_land()
	
	model.scale = model.scale.lerp(target_scale, 5.0 * delta)
	
	was_grounded = grounded
	
func _on_land():
	#squash
	target_scale = Vector3(1.6, 0.3, 1.6)
	#particle and audio here
	_delayed_reset()

func _on_takeoff():
	#stretch
	target_scale = Vector3(0.8, 1.8, 0.8)
	pass
	#particle and audio here

func _delayed_reset():
	await get_tree().create_timer(0.15).timeout
	target_scale = base_scale
