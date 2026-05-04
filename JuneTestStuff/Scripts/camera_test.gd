extends Node3D

@export var target : Node3D

@export var offset_x := 0.0
@export var offset_y := 0.0
@export var offset_z := 0.0

@export var follow_speed := 1.0

func _process(delta):
	var offset = target.global_transform.basis * Vector3(offset_x, offset_y, offset_z)
	var desired_pos = target.global_transform.origin + offset
	global_position = global_position.lerp(desired_pos, delta * follow_speed)
	
	var lookAt_offset = target.global_basis.y * offset_y - target.global_basis.z * offset_z
	var lookAt_dir = target.global_transform.origin + lookAt_offset #Vector3(0,1/y,-1/z)
	look_at(lookAt_dir, Vector3.UP)
