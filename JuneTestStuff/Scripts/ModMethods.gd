extends Node

@export var bike : Node3D
#@export var punch : Node3D #OLD
@export var punch : YV_Puncher #NEW
@export var light : YV_Headlight #NEW
@export var magnet : YV_Magnet #NEW
@onready var buttonDisplayUI = get_node("/root/FinalMainScene/ButtonDisplay")

var activePhysicsMode = 10; # 10 - no mode | 1 - jump mode | 2 - glide mode
var activeItemMode = 11; # 11 - no mode | 4 - punch mode | 5 - headlight mode | 6 - magnet mode
var activeWheelMode = 12; # 12 - no mode | 8 - tentacle mode | 9 - water mode

var activePhysicsModeName = "No Mode"
var activeItemModeName = "No Mode"
var activeWheelModeName = "No Mode"


func _input(_event):
	if Input.is_action_pressed("mode1"):
		initiate_jump_charge()
		pass
		
	if Input.is_action_just_released("mode1"):
		initiate_jump_release()
		pass
		
	#if Input.is_action_pressed("mode2"):
		#initiate_glide()
		#pass
		
	if Input.is_action_pressed("mode3"): #YV
		initiate_punch()
		print(activeItemMode)
		pass
		
	#if Input.is_action_pressed("mode4"): #YV NEW
		#initiate_light() #Not Needed
	#	print(activeItemMode)
	#	pass
		
	if Input.is_action_pressed("Debug"):
		if bike.show_debug == true:
			bike.show_debug = false
		else:
			bike.show_debug = true

func _ready() -> void:
	$"../SimonSays".modeSwitch.connect(change_mode)
var is_boosting := false

func change_mode(newMode: int) -> void:
	buttonDisplayUI.hide_jump() #NEW
#	buttonDisplayUI.hide_glide() #NEW
#	buttonDisplayUI.hide_punch() #NEW
	if(newMode < 3):
		activePhysicsMode = newMode
		if(newMode == 1):
			print("new physics mode is jump")
			#buttonDisplayUI.show_jump() #NEW
		elif(newMode == 2):
			print("new physics mode is glide")
			#buttonDisplayUI.show_glide() #NEW
	elif(newMode > 3 && newMode < 7):
		punch.unequip() #NEW
		light.unequip() #NEW
		magnet.unequip() #NEW
		activeItemMode = newMode
		if(newMode == 4):
			print("new item mode is punch")
			punch.equip() #NEW
#			buttonDisplayUI.show_punch() #NEW
		#elif(newMode == 5):
			#print("new item mode is headlight")#removed for scope
			#light.equip() #
		elif(newMode == 6):
			print("new item mode is magnet")
			magnet.equip() #NEW
	elif(newMode > 7 && newMode < 10):
		activeWheelMode = newMode
		if(newMode == 8):
			print("new wheel mode is tentacle")
			bike._set_wheel_mode(bike.WheelMode.TENTACLE)
		elif(newMode == 9):
			print("new wheel mode is water")
			bike._set_wheel_mode(bike.WheelMode.WATER)
	elif(newMode >= 10):
		if(newMode == 10):
			activePhysicsMode = newMode
			print("Bike Mod reseted to default")
		elif(newMode == 11):
			activeItemMode = newMode
			print("Item Mod reseted to default")
			punch.unequip() #NEW
			light.unequip() #NEW
			magnet.unequip() #NEW
		elif(newMode == 12):
			activeWheelMode = newMode
			print("Wheel Mod reseted to default")
			bike._set_wheel_mode(bike.WheelMode.NORMAL)
	AudioManager.play_audio("ModeChange")

func _process(_delta: float) -> void:
	#current mode display. playtesting purpose. temp code
	match activePhysicsMode:
		10:
			activePhysicsModeName = "No Mode"
		1:
			activePhysicsModeName = "Jump"
		2:
			activePhysicsModeName = "Glide"
			
	match activeItemMode:
		11:
			activeItemModeName = "No Mode"
		4:
			activeItemModeName = "Punch"
		5:
			activeItemModeName = "Headlight"
		6:
			activeItemModeName = "Magnet"
			
	match activeWheelMode:
		12:
			activeWheelModeName = "No Mode"
		8:
			activeWheelModeName = "Tentacle"
		9:
			activeWheelModeName = "Water"
		
	$InputLabel2.text = "Current Mode: " + activePhysicsModeName + \
	", Item Mode: " + activeItemModeName + \
	", Wheel Mode: " + activeWheelModeName
	
func _physics_process(_delta: float) -> void:
	if activePhysicsMode == 2:
		if bike.flying:
			initiate_glide()

#PHYSICS MODE
func initiate_jump_charge():
	if activePhysicsMode != 1:
		return
	
	if bike.is_jump_charging == false:
		bike.is_jump_charging = true
		
func initiate_jump_release():
	if activePhysicsMode != 1:
		return
	
	bike.is_jump_charging = false
	bike._do_jump()

func initiate_glide():
	if activePhysicsMode != 2:
		return
		
	if bike.is_gliding == false:
		#bike.apply_impulse(-bike.basis.z * 1000 + bike.basis.y * 100)
		
		bike.is_gliding = true
		bike.gravity_scale = 0.4 #0.1 makes bike fly. good to test glide & tilt
		
		bike._open_wing_anim()
	
##PHYSICS MODE END
	
#ITEM MODE
func initiate_punch():
	if activeItemMode != 4:
		return
	
	#if activeItemMode == 4 and punch != null: #NEW
		#punch.attack()

#func initiate_light(): #Not Needed
#	if activeItemMode != 5:
#		return

#func initiate_magnet(): #Not Needed
#	if activeItemMode != 6:
#		return
##ITEM MODE END

#BOOST
#@export_category("Boost")
#@export var boost_duration := 180
#@export var speed_multiplier := 3.0
#@export var fov_add_amount := 30.0
#@export var fov_curve: Curve

#func initiate_boost() -> void:
	#if is_boosting == false:
		#is_boosting = true
		#
		#var prev_accel = 0.0
		#var prev_fov = 0.0
		#
		#prev_accel = bike.acceleration
		#prev_fov = bike.get_node("Camera3D").fov
		#
		#bike.acceleration = prev_accel * speed_multiplier
		#
		#for time in range(boost_duration):
			#bike.get_node("Camera3D").fov = prev_fov + fov_add_amount * fov_curve.sample_baked(float(time)/boost_duration)
			#await get_tree().create_timer(0.005).timeout
		#
		#bike.acceleration = prev_accel
		#
		#is_boosting = false
