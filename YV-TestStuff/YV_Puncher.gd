extends Node3D
class_name YV_Puncher #NEW

@onready var hitbox = $Hitbox

var can_punch = true
var is_equipped = true

func _ready() -> void:
	unequip() #NEW
	hitbox.monitoring = false

#func _process(delta) -> void: #OLD
#	# Toggle item (Z key)
#	if Input.is_action_just_pressed("punchitem_toggle"):
#		print("PunchItem has been toggled")  # debug
#		toggle_item()
#
#	# Punch (X key)
#	if is_equipped and Input.is_action_just_pressed("punch"):
#		attack()

func equip() -> void: #NEW
	is_equipped = true
	visible = true
	can_punch = true
	
	hitbox.monitoring = true   #NEW
	hitbox.active = true       #NEW

func unequip() -> void: #NEW
	is_equipped = false
	visible = false
	
	hitbox.monitoring = false
	hitbox.active = false #NEW

func toggle_item() -> void:
	is_equipped = !is_equipped
	visible = is_equipped
	hitbox.monitoring = false   # safety reset

#func attack() -> void:
#	if not can_punch or not is_equipped:
#		return

#	can_punch = false
	
#	print("Punch ON")  # debug

	# forward motion
	#position.z -= 1.5 #OLD
#	translate_object_local(Vector3(0, 0, -1.5)) #NEW

#	hitbox.active = true
#	hitbox.monitoring = true
#	await get_tree().create_timer(0.1).timeout
#	hitbox.monitoring = false
#	hitbox.active = false

	#position.z += 1.5 #OLD
#	translate_object_local(Vector3(0, 0, 1.5)) #NEW
	
#	print("Punch OFF") # debug

#	await get_tree().create_timer(0.3).timeout
#	can_punch = true
