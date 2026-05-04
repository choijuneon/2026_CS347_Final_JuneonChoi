extends Area3D
class_name YV_Magnet #NEW

var magnetActive = true

#func _on_area_entered(area: Area3D) -> void:
#	if magnetActive == true && area.has_method("start_magnet"):
#		area.start_magnet(get_parent())

func _process(_delta: float): #NEW!!! IT WORKS!!!
	var areas = get_overlapping_areas()
	
	for area in areas:
		if magnetActive == true && area.has_method("start_magnet"):
			area.start_magnet(get_parent())

func _ready() -> void: #NEW
	unequip() #NEW

func equip() -> void: #NEW
	magnetActive = true
	#visible = true

func unequip() -> void: #NEW
	magnetActive = false
	#visible = false
