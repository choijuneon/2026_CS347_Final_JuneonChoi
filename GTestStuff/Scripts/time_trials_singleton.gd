extends Node
var bestTimeMinutes = 9
var bestTimeSeconds = 59
var timeInString= " "
var lastTimeInString = " "

func _ready() -> void:
	pass

func addTime(minutes: int, seconds: int):
	if (seconds < 10):
		lastTimeInString = str(minutes) + ":0" + str(seconds)
	else:
		lastTimeInString = str(minutes) + ":" + str(seconds)
	
	if minutes < bestTimeMinutes:
		bestTimeMinutes = minutes
		bestTimeSeconds = seconds
	elif (minutes == bestTimeMinutes):
		if (seconds < bestTimeSeconds):
			bestTimeMinutes = minutes
			bestTimeSeconds = seconds
	if bestTimeSeconds < 10:
		timeInString = str(bestTimeMinutes) + ":0" + str(bestTimeSeconds)
	else:
		timeInString = str(bestTimeMinutes) + str(bestTimeSeconds)
	pass
