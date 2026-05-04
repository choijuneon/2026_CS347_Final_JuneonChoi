extends Node
class_name EngineSanity

var max_hp: float= 120
var current_hp: float = 120
var sanityLightsON: int = 17# pin number, get decreased to 12 but not lower ideally
var wheelModuleDisabled=false
var bodyModuleDisabled=false
var frontModuleDisabled=false
var drain_rate: float = 0.0   # sanity lost per second
var drain_inc: float = 0.4# how much the rate increases per potentiometer on fire ie lit up

# minigame hookup
var hbMinigame
var potMinigame

var moduleONStateArray = [0,1,2,3,4,5]
@export var moduleOFFSanityStack = Stack.new()
@onready var health_bar = $HealthBar #HealthBar node will be ready upon game startt
@onready var modMethods = $"../../ModMethods"

func _ready() -> void:
	health_bar.max_value = max_hp
	health_bar.value = current_hp

	# reference to potentiometer minigame
	potMinigame = $"../../MaintenanceMinigame"
	potMinigame.potDown.connect(incDrain)

func _process(delta: float) -> void:
	if drain_rate>0.0:
		takeDamage((drain_rate * delta))#take drain damage every frame, can be 0
		#print("taking drain damage:")
		#print((drain_rate*delta ))
		current_hp = clampf(current_hp, 0.0, max_hp)
	
	#updates health bar visual, so dont need to do it in method calls
	health_bar.value = current_hp
	
	#healDamage(1) #testing
	#print("HP"+ str(current_hp))



func incDrain(inc: bool) -> void:
	if(inc):
		drain_rate += drain_inc
	elif(!inc):
		drain_rate -= drain_inc

func loseHealthSegment() -> void:
	if sanityLightsON>11:
		print("Turning Off sanity light Port: " +str(sanityLightsON))
		ArduinoTest.writeLeds(str(sanityLightsON), "0") #Turn off Sanity light
		sanityLightsON-=1
	else:
		print("ERROR: attempting lose segment with no SANITY left")
	
	if !moduleONStateArray.is_empty():
		var value = moduleONStateArray[randi() % moduleONStateArray.size()]#select random module light
		print("Turning Off module light Port: " + str(value))
		ArduinoTest.writeLeds(str(value), "0") #Turn off module light
		moduleOFFSanityStack.push(value) #add to OFF stack
		moduleONStateArray.erase(value) #Remove from ON array
		
		if ((!moduleONStateArray.has(0)&&!moduleONStateArray.has(1))&&!wheelModuleDisabled):#check if both wheel lights off 01
			wheelModuleDisabled=true
			print("disabling wheel module")#add ui prompt to tell user to heal to unlock mods
			modMethods.change_mode(10)
		if ((!moduleONStateArray.has(2)&&!moduleONStateArray.has(3))&&!frontModuleDisabled):#check if both front lights off 233
			frontModuleDisabled=true
			print("disabling front module")
			modMethods.change_mode(11)
		if ((!moduleONStateArray.has(4)&&!moduleONStateArray.has(5))&&!bodyModuleDisabled):#check if both body lights off 45
			bodyModuleDisabled=true
			print("disabling body module")
			modMethods.change_mode(12)
	else:
		print("ERROR: attempting lose segment with no MODULES left")
	
	AudioManager.play_audio("Major Hurt")

func gainHealthSegment() -> void:
	var tempLED
	if sanityLightsON<17:
		if !moduleOFFSanityStack.is_empty():
			print("Turning On sanity light Port: " + str(sanityLightsON))
			ArduinoTest.writeLeds(str(sanityLightsON), "1") #Turn on Sanity light
			sanityLightsON+=1
			
			tempLED = moduleOFFSanityStack.pop() #remove last from OFF stack and retrieve value
			print("Turning ON module light Port: " + str(tempLED))
			ArduinoTest.writeLeds(str(tempLED), "1") #Turn on light
			moduleONStateArray.append(tempLED) #Add to ON array
			if ((moduleONStateArray.has(0)||moduleONStateArray.has(1))&&wheelModuleDisabled):#check if both wheel lights off 01
				wheelModuleDisabled=false
				print("reEnabling wheel module")
			if ((moduleONStateArray.has(2)||moduleONStateArray.has(3))&&frontModuleDisabled):#check if both front lights off 233
				frontModuleDisabled=false
				print("reEnabling front module")
			if ((moduleONStateArray.has(4)||moduleONStateArray.has(5))&&bodyModuleDisabled):#check if both body lights off 45
				bodyModuleDisabled=false
				print("reEnabling body module")
		else:
			print("ERROR: attempting Gain segment no moduleLights off")
	else:
		print("ERROR: attempting Gain segment full sanity")

func takeDamage(damage: float) -> void:
	#print("takeDamage() " + str(damage))
	
	var old_hp = current_hp
	current_hp = clampf(current_hp - damage, 0.0, max_hp)
	
	var old_segments = int(old_hp / 20.0)
	var new_segments = int(current_hp / 20.0)
	
	if current_hp > 0.0:
		new_segments = maxi(new_segments, 1)#allows floor(maxi) while keeping 1 led lit until hp=0
		
	var segments_lost = old_segments - new_segments
	
	for i in range(segments_lost):
		loseHealthSegment()
		
	if current_hp == 0.0:
		loseHealthSegment()
		print("game over")
		AudioManager.play_audio("Player Sanity Death")
		# Change Scene to gameover
		get_tree().change_scene_to_file("res://FinalAssets/Scenes/GameOverScene.tscn")
func healDamage(healAmount: float) -> void:
	print("healDamage() " + str(healAmount))
	
	var old_hp = current_hp
	current_hp = clampf(current_hp + healAmount, 0.0, max_hp)
	
	var old_segments = int(old_hp / 20.0)
	var new_segments = int(current_hp / 20.0)
	var segments_gained = new_segments - old_segments
	
	for i in range(segments_gained):
		gainHealthSegment()

func check_death() -> bool:
	if (current_hp > 0):
		return true
	else:
		return false
