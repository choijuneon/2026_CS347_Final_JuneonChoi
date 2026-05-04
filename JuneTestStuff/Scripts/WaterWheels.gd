extends Area3D


@onready var bike = $"../../Bike"
@onready var splash_particles_grp := $"../../Bike/WaterEffect"

var splash_particles

var prev_state = null
var current_state = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#splash_particles = splash_particles_grp.get_children()
	#print(splash_particles)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#if bike.waterWheel == true and current_state != "waterWheel":
		#_activate_water_wheel()
		#current_state = "waterWheel"
	#
	#prev_state = current_state #i want to make a state machine for a wheel mods
	#
	#if bike.waterWheel:
		#if bike.flying:
			#for particle in splash_particles:
				#particle.emitting = false
		#else: 
			#for particle in splash_particles:
				#particle.emitting = true
	
func _on_body_entered(body: Node) -> void:
	if body.name == "Bike":
		print("Entered Area")
		if bike.current_wheel_mode != bike.WheelMode.WATER:
			bike._set_wheel_mode(bike.WheelMode.WATER)
			print("WATER WHEEL ACTIVATED")
		elif bike.current_wheel_mode == bike.WheelMode.WATER:
			bike._set_wheel_mode(bike.WheelMode.NORMAL)
			print("WATER WHEEL DEACTIVATED")
				
func _on_body_exited(body: Node) -> void:
	if body.name == "Bike":
		print("Exited Area")
	
#func _activate_water_wheel() -> void:
	##collision setting
	#for wheel in bike.wheels:
		#wheel.set_collision_mask_value(3, true)
	#bike.set_collision_mask_value(3, true)
	##particle
	#var speed = bike.linear_velocity.length()
	#for particle in splash_particles:
		#particle.emitting = true
		#particle.process_material.set("initial_velocity_max", speed)
		#
#func _deactivate_water_wheel() -> void:
	#pass
