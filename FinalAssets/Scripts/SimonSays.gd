extends Node
var inputArray = ["#", "#", "#"];
#var wantedArray = ["right", "right", "right"]
var jumpArray = ["yellow","yellow","black"]
var glideArray = ["yellow","black","red"]
var teethArray = ["green","black","blue"]
#var lightArray = ["yellow","blue","blue","yellow"]
var magnetArray = ["green","blue","yellow"]
var tentacleWheelArray = ["blue","black","yellow"]
var waterWheelArray = ["blue","yellow","red"]
var size = 4
var index = 0
signal modeSwitch(newMode)
@onready var Arduino = $"../ArduinoInput"
@onready var engineSanity = get_node("/root/FinalMainScene/UserInterface/EngineSanity")
@onready var timer = $SSTimer
@onready var panels = $CodeContainer.get_children()
@onready var bodyIcon = $ModIcons/BodyIcon
@onready var frontIcon = $ModIcons/FrontIcon
@onready var wheelsIcon = $ModIcons/WheelsIcon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect Arduino button delegates
	ArduinoTest.buttonPushed.connect(addBlack)#left=black=6
	ArduinoTest.button2Pushed.connect(addRed)#right=red=7
	ArduinoTest.button3Pushed.connect(addYellow)#up=yellow=8
	ArduinoTest.button4Pushed.connect(addBlue)#down=blue=9
	ArduinoTest.button5Pushed.connect(addGreen)#0
	# Set icons to no mod by default
	bodyIcon.play("none")
	frontIcon.play("none")
	wheelsIcon.play("none")
	# Set panels to grey by default
	setPanelColor()

func check():#TODO add sfx when a mod is accepted/activated
	timer.stop()#kill timer, not needed so single flash wont trigger
	if (inputArray == jumpArray&&engineSanity.bodyModuleDisabled==false):
		print("jumpmode active")
		modeSwitch.emit(1)
		bodyIcon.play("jump")
#flash both
		print("flashing body")
		flashLeds("4","5")
		#reset to previous states
		if engineSanity.moduleONStateArray.has(4):#if light 0 is on in array
			ArduinoTest.writeLeds("4","1")
		if engineSanity.moduleONStateArray.has(5):#if light 1 is on in array
			ArduinoTest.writeLeds("5","1")

	elif (inputArray == glideArray&&engineSanity.bodyModuleDisabled==false):
		print("glide mode active")
		modeSwitch.emit(2)
		bodyIcon.play("glide")
		#flash both
		print("flashing body")
		flashLeds("4","5")
		#reset to previous states
		if engineSanity.moduleONStateArray.has(4):#if light 0 is on in array
			ArduinoTest.writeLeds("4","1")
		if engineSanity.moduleONStateArray.has(5):#if light 1 is on in array
			ArduinoTest.writeLeds("5","1")
	elif (inputArray == teethArray&&engineSanity.frontModuleDisabled==false):
		print("teeth mode active")
		modeSwitch.emit(4)
		frontIcon.play("punch")
		#flash both
		print("flashing front")
		flashLeds("2","3")
		#reset to previous states
		if engineSanity.moduleONStateArray.has(2):#if light 0 is on in array
			ArduinoTest.writeLeds("2","1")
		if engineSanity.moduleONStateArray.has(3):#if light 1 is on in array
			ArduinoTest.writeLeds("3","1")
	#elif (inputArray == lightArray): #scope cut for now
		#print("headlight mode active")
		#modeSwitch.emit(5)
	elif (inputArray == magnetArray&&engineSanity.frontModuleDisabled==false): #NEW
		print("magnet mode active")
		modeSwitch.emit(6)
		frontIcon.play("magnet")
				#flash both
		print("flashing front")
		flashLeds("2","3")
		#reset to previous states
		if engineSanity.moduleONStateArray.has(2):#if light 0 is on in array
			ArduinoTest.writeLeds("2","1")
		if engineSanity.moduleONStateArray.has(3):#if light 1 is on in array
			ArduinoTest.writeLeds("3","1")
	elif (inputArray == tentacleWheelArray&&engineSanity.wheelModuleDisabled==false):
		print("tentacle mode active")
		modeSwitch.emit(8)
		wheelsIcon.play("sticky")
		#flash both
		print("flashing wheels")
		flashLeds("0","1")
		#reset to previous states
		if engineSanity.moduleONStateArray.has(0):#if light 0 is on in array
			ArduinoTest.writeLeds("0","1")
		if engineSanity.moduleONStateArray.has(1):#if light 1 is on in array
			ArduinoTest.writeLeds("1","1")
	elif (inputArray == waterWheelArray&&engineSanity.wheelModuleDisabled==false):
		print("water mode active")
		modeSwitch.emit(9)
		wheelsIcon.play("water")
		#flash both
		print("flashing wheels")
		flashLeds("0","1")
		#reset to previous states
		if engineSanity.moduleONStateArray.has(0):#if light 0 is on in array
			ArduinoTest.writeLeds("0","1")
		if engineSanity.moduleONStateArray.has(1):#if light 1 is on in array
			ArduinoTest.writeLeds("1","1")
	index = 0
	inputArray = ["#","#","#"]
	print(str(inputArray))
	resetPanels()#clear ui on 3 inputs full

func flashLeds(led1:String,led2:String):
	ArduinoTest.writeLeds(led1,"1")
	ArduinoTest.writeLeds(led2,"1")#flash both leds on
	await get_tree().create_timer(0.1).timeout # Pauses for .1 seconds
	ArduinoTest.writeLeds(led1,"0")
	ArduinoTest.writeLeds(led2,"0")#flash both leds off
	await get_tree().create_timer(0.1).timeout # Pauses for .1 seconds
	ArduinoTest.writeLeds(led1,"1")
	ArduinoTest.writeLeds(led2,"1")#flash both leds on
	await get_tree().create_timer(0.1).timeout # Pauses for .1 seconds
	ArduinoTest.writeLeds(led1,"0")
	ArduinoTest.writeLeds(led2,"0")#flash both leds off
	await get_tree().create_timer(0.1).timeout # Pauses for .1 seconds

func setSize(newSize: int) -> void:
	size = newSize

func getSize() -> int:
	return size
	
func startTimer():
	timer.stop()  #ends current timer
	print("queue timer start")
	timer.wait_time = 4
	timer.start() # starts
	
func setPanelColor():	
	for i in range(0,3):
		var panel = panels[i]
		var input = inputArray[i]
		if(input == "black"):
			panel.modulate = Color.BLACK
		elif(input == "red"):
			panel.modulate = Color.RED
		elif(input == "yellow"):
			panel.modulate = Color.YELLOW
		elif(input == "blue"):
			panel.modulate = Color.BLUE
		elif(input == "green"):
			panel.modulate = Color.GREEN
		else:
			panel.modulate = Color.GRAY

# Wait a second before calling setPanel Color
func resetPanels(calledFromTimeout:=false):
	await get_tree().create_timer(1.0).timeout 
	setPanelColor()
		
	if calledFromTimeout==true:
		#flash all module lights once(off on prev) for queue reset
		print("flashing all once for queue reset")
		for j in range(6):
			ArduinoTest.writeLeds(str(j),"0")
		await get_tree().create_timer(0.1).timeout # Pauses for .1 seconds
		for j in range(6):
			ArduinoTest.writeLeds(str(j),"1")
		await get_tree().create_timer(0.1).timeout # Pauses for .1 seconds
		#for j in range(6):
			#ArduinoTest.writeLeds(str(j),"0")
		#await get_tree().create_timer(0.1).timeout # Pauses for .1 seconds
		for j in engineSanity.moduleONStateArray:
			ArduinoTest.writeLeds(str(j),"1")
			
		#TODO play queue clear sfx

func addBlack() -> void:
	if(index<3):
		startTimer()
		inputArray[index] = "black"
		setPanelColor()
		print("input black")
		checkIndex()

func addRed() -> void:
	if(index<3):
		startTimer()
		inputArray[index] = "red"
		setPanelColor()
		print("input red")
		checkIndex()

func addYellow() -> void:
	if(index<3):
		startTimer()
		inputArray[index] = "yellow"
		setPanelColor()
		print("input yellow")
		checkIndex()

func addBlue() -> void:
	if(index<3):
		startTimer()
		inputArray[index] = "blue"
		setPanelColor()
		print("input blue")
		checkIndex()
	
func addGreen() -> void:
	if(index<3):
		startTimer()
		inputArray[index] = "green"
		setPanelColor()
		print("input green")
		checkIndex()

func checkIndex()-> void:
	index+=1
	if(index>2):
		check()

#func randomizeWanted() -> void:
	#var allInputs = ["left", "right", "up", "down","green"]
	#for i in size: 
		#var randomNumb = randi_range(0, size-1)
		#wantedArray[i] = allInputs[randomNumb]
	#wantedChanged.emit() 
#
#func getWanted() -> String:
	#var wanted = ""
	#for i in wantedArray:
		#wanted = wanted + ", " + i
	#return wanted

func getInputArrayToString() -> String:
	var lastInput = ""
	for i in inputArray:
		lastInput = lastInput + ", " + i
	return lastInput

func _input(_event):
	if Input.is_action_just_released("simonYellow"):
		addYellow()
	elif Input.is_action_just_released("simonBlue"):
		addBlue()
	elif Input.is_action_just_released("simonBlack"):
		addBlack()
	elif Input.is_action_just_released("simonRed"):
		addRed()
	elif Input.is_action_just_released("simonGreen"):
		addGreen()


func _on_ss_timer_timeout() -> void:#timer for queue clear??
	print("queue Timer off")
	check()
