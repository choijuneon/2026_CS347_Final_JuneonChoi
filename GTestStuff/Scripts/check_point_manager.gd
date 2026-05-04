extends Node
var checkpoints = PackedVector3Array()
var lastStablePosition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func addPosition(newPosition: Vector3):
	checkpoints.append(newPosition)
	

func setLastStableLocation():
	lastStablePosition = checkpoints.get(0)

func setLastStableLocationManual(newPos: Vector3):
	lastStablePosition = newPos

func getLastStableLocation() -> Vector3:
	return lastStablePosition

func removePosition(oldPosition: Vector3) -> bool:
	return checkpoints.erase(oldPosition)

func checkValidWin() -> bool:
	if (checkpoints.size() == 0):
		return true
	else:
		return false
