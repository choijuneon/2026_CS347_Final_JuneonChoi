extends Area3D

@export var bike : Node3D
var seconds = 0
var minutes = 0
var time = "0:00"
var isActiveRace = false
var silentTimerUp = false
var startCount = 3
signal countDownEnd
signal countdownChanged(new_value)
signal timeChanged(new_value)
signal gameEnded()

func _ready():
	body_entered.connect(_on_body_entered)
	get_tree().paused = true

func _on_body_entered(body: Node) -> void:
	if body.name == "Bike":
		if (CheckPointManager.checkValidWin()):
			if (isActiveRace):
				isActiveRace = false
				$Timer.stop()
				gameEnded.emit()
				TimeTrials.addTime(minutes, seconds)
				$PFade.FadeOut()
				get_tree().change_scene_to_file("res://GTestStuff/Scenes/S_EndOfGame.tscn")


func _per_second() -> void:
	seconds += 1
	if (seconds == 60):
		minutes += 1
		seconds = 0
	
	if (seconds < 10):
		time = str(minutes) + ":0" + str(seconds)
	else:
		time = str(minutes) + ":" + str(seconds)
	
	timeChanged.emit(time)
	pass # Replace with function body.


func _on_starting_timer_timeout() -> void:
	if (startCount > 0):
		startCount-=1
		countdownChanged.emit(startCount)
	else:
		isActiveRace = true
		countDownEnd.emit()
		$"Starting Timer".stop()
		get_tree().paused = false;
		$Timer.start()
		get_node("/root/FinalMainScene/PauseMenu").can_pause = true
	pass # Replace with function body.


func _on_silent_timer_timeout() -> void:
	silentTimerUp = true
	pass # Replace with function body.
