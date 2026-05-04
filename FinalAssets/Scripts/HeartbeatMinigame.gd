extends Node
 
var progressBar
var maxHP = 100.0
var currentHP = 100.0
var drainRate = 2
var pumpRate = 100
var inputName = "pumpHeart"
var pinNum = 1
var ledNum = "11" # TODO: for some reason the coolant LED isn't working
var drainFlag = false # To prevent signal spam when drained
var warningFlag = false # for the led signal
 
signal heartLed(index: String, state: String)
@onready var Arduino = $"../ArduinoInput"
@onready var bolts = get_node("/root/FinalMainScene/UserInterface/Bolts/BoltsImage/NumberOfBolts")
 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#progressBar = $ProgressBar
	#progressBar.max_value = maxHP
	#progressBar.value = currentHP
	##Arduino.maintenancePushed.connect(buttonPushed)
	ArduinoTest.maintenancePushed.connect(buttonPushed)
 
 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:

	if bolts.numBolts>0:
		heartLed.emit(ledNum,"1")
	else:
		heartLed.emit(ledNum,"0")
 
# if player presses designated button to restore some health to the progress bar
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_released(inputName):#pumpheart is temp name
		buttonPushed(1)
 
func buttonPushed(index):
	if(index == pinNum):
		currentHP += pumpRate
		bolts.pumpHeal()
