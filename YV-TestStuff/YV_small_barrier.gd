extends Node3D

@onready var debris = $GPUParticles3D  # if using particles

var current_hitboxes := []
var destroyed := false

func _on_area_entered(area) -> void:
	print("entered:", area.name)

	if area.is_in_group("punch_hitbox"):
		current_hitboxes.append(area)

		# Check immediately (works if punch is already active)
		if "active" in area and area.active:
			print("VALID PUNCH (enter)")
			destroy()

func _process(_delta: float) -> void:
	if destroyed:
		return
	
	for area in current_hitboxes:
		if area == null or not is_instance_valid(area):
			continue

		if not $Area3D.get_overlapping_areas().has(area):
			continue

		if "active" in area and area.active:
			print("VALID PUNCH (inside)")
			destroy()
			return
			

func destroy() -> void:
	if destroyed:
		return
	destroyed = true
	
	$GPUParticles3D.emitting = true
	$MeshInstance3D.visible = false
	$StaticBody3D/CollisionShape3D.disabled = true
	$Area3D/CollisionShape3D.disabled = true
	$SM_BreakableBarrier_3M.visible = false
#	$BreakableBarrier2.visible = false
	$SM_BreakableBarrier_3M/MeshInstance3D2.visible = false
	$SM_BreakableBarrier_3M/MeshInstance3D3.visible = false

	# Wait before deleting
	await get_tree().create_timer(1.0).timeout
	queue_free()


func _on_area_exited(area) -> void:
	if area in current_hitboxes:
		current_hitboxes.erase(area)
		
