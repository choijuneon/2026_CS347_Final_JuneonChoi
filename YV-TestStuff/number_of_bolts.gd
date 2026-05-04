extends Label

@onready var engineSanity = get_node("/root/FinalMainScene/UserInterface/EngineSanity")
@export var numBolts = 0
@export var numPumps = 0
			
func _on_pickup() -> void:
	numBolts += 1
	text = "Oil: %s" % numBolts

	
func pumpHeal() -> void: #WIP
	if numBolts >= 1:
		numPumps += 1
		if numPumps >= 4:
			# spend 1 bolt
			numBolts -= 1
			# reset pump counter
			numPumps = 0
			# heal 20 HP (clamp: prevents overhealing)
			print("Heart pumped, healing 20")
			engineSanity.healDamage(20)
			# update bolt text
			text = "Oil: %s" % numBolts
