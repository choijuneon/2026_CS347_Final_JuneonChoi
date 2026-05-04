extends SpotLight3D
class_name YV_Headlight #NEW

#func _input(event) -> void: #OLD
#	if event.is_action_pressed("flashlight_toggle"):
#		visible = !visible

func _ready() -> void: #NEW
	unequip() #NEW

func equip() -> void: #NEW
	visible = true

func unequip() -> void: #NEW
	visible = false
