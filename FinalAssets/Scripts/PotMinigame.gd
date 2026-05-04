extends Node
# Pot (1: West 10 2: exhaust 7 3: east 6 4: Bucket top 8)
var desiredValues = [0,0,0,0] # the values required to solve the minigame
var actualValues = [0,0,0,0] # the values received from the alt controller
# 2 is correct
var potLeds = ["10","7","6","8"] # stores the indexs of the poteniometer LEDs
var potRange = 60 # margin of error
var flags = [true,true,true,true] # flags for each of the potentiometers (prevents signal spam)
var potIndex = 0 # currently selected potentiometer for keyboard controllers
var rate = 10 # rate poteniometer values increase
# Timer
var timer1
var minTime = 10
var maxTime = 30
# Delegates
signal potDown(isDown: bool)
signal potLed(index: String, state: String)
@onready var Arduino = $"../ArduinoInput" # not sure if this is still neccesary but I'm keeping this here anyway

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get reference to needed items in scene
	timer1 = $Timer1

	ArduinoTest.potInput.connect(getPotInput)
	startTimers()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	checkMatching()

# Compare values of actual and desired to see if they match
func checkMatching():
	for i in range(4):
		if(actualValues[i]<=(desiredValues[i]+potRange) and actualValues[i]>=(desiredValues[i]-potRange)):
			if(flags[i] == false):
				print("Pot " + str(i) + " is up")
				potDown.emit(false)
				potLed.emit(potLeds[i],"0")#emit 0, off?
				flags[i] = true
		else:
			if(flags[i] == true):
				print("Pot " + str(i) + " is down")
				potDown.emit(true)
				potLed.emit(potLeds[i],"1")#emit 1, on?
				flags[i] = false
			
# assigns the arduino pot inputs to the array 
func getPotInput(index, output):
	actualValues[index-1] = output

#Sets a random value for the desiredValues
func randomizeValue(index):
	desiredValues[index] = randi_range(0, 1023)

# returns an int for how long a timer should run for
func setRandomTime():
	return randi_range(minTime,maxTime)

# Starts all timers with a random duration
func startTimers():
	timer1.start(setRandomTime())

func _on_timer_1_timeout() -> void:
	print("Pot Timer end")
	var randomPot = randi_range(0,3)
	randomizeValue(randomPot)
	timer1.start(setRandomTime())
	
func withinBounds():
	if(actualValues[potIndex]>1023):
		actualValues[potIndex] = 0
	elif(actualValues[potIndex]< 0):
		actualValues[potIndex] = 1023

func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("increasePot"):
		actualValues[potIndex] += rate
		withinBounds()
	elif Input.is_action_pressed("decreasePot"):
		actualValues[potIndex] -= rate
		withinBounds()
	elif Input.is_action_just_released("potIndex1"):
		potIndex = 0;
	elif Input.is_action_just_released("potIndex2"):
		potIndex = 1;
	elif Input.is_action_just_released("potIndex3"):
		potIndex = 2;
	elif Input.is_action_just_released("potIndex4"):
		potIndex = 3;
