extends RigidBody3D

#--BASIC BIKE VARIABLES--
@export var wheels: Array[RaycastWheel]
@export var acceleration := 2400.0
@export var max_speed := 15.0
@export var accel_curve : Curve
@export var tire_turn_speed := 2.0
@export var tire_max_turn_degrees := 20
@export var skid_marks: Array[GPUParticles3D]

#--DEBUG VARIABLE--
@export_category("Debug")
@export var show_debug := false

#--JUMP MODE VARIABLES--
@export_category("Jump")
@export var jump_min_force := 230.0
@export var jump_extra_max_force := 60.0
@export var max_charge_sec := 0.75
@export var press_force := 40.0
var is_jump_charging = false
var charged_time := 0.0

#--GLIDE MODE VARIABLES--
@export_category("Glide")
@export var lift_strength := 1.0
@export var glide_strength := 100.0
@export var roll_strength := 200.0
@export var turn_strength := 150.0
var is_gliding := false
var roll_input := 0
var air_turn_input := 0
#this var is used to activate tracking is bike on the ground to stop gliding,
#if the bike gets on the ground earlier
var frames_passed_gliding := 0 
@onready var wingLAnimator = get_node("Model_grp/Wing_grp/WingL/AnimationPlayer")
@onready var wingRAnimator = get_node("Model_grp/Wing_grp/WingR/AnimationPlayer")

#--ITEM MODE VARIABLES--
enum ItemMode { NORMAL, PUNCH, HEADLIGHT, MAGNET }
var current_item_mode : ItemMode = ItemMode.NORMAL
var is_item_effect_active := false

#--WHEEL MODE VARIABLES--
@export var splash_particles: Array[GPUParticles3D]
enum WheelMode { NORMAL, TENTACLE, OFFROAD, WATER }
var current_wheel_mode : WheelMode = WheelMode.NORMAL
var is_wheel_effect_active := false
var is_splash_particles_on := false

#--BOOST VARIABLE--
@export var boost_particle: Array[GPUParticles3D]
var is_boosting: bool = false   #NEW

#--TERRAIN CHECKER VARIABLE--
@export var terrain_type_checker : RayCast3D
enum TerrainTypes { ROAD, WALL, MUD, WATER }
var current_terrain_type : TerrainTypes = TerrainTypes.ROAD

#--INPUT VARIABLE--
var motor_input := 0.0
var hand_break := false

#--CENTEROFMASS SHIFTING VARIABLE--
#var reverse := false
var flying := false

#--DRIFT VARIABLE--
var is_slipping := false

func _ready() -> void:
	_set_wing_anim_default()
	#CheckPointManager.setLastStableLocationManual(position)
	wingLAnimator.animation_finished.connect(_flap_wing_anim) #open -> flap -> close
	
func _unhandled_input(event: InputEvent) -> void:
	#if event.is_action("decelerate"):
		#reverse = true
		#motor_input = -1
	#elif event.is_action("accelerate"):
		#motor_input = 1
		
#	if event.is_action_pressed("decelerate"):
#		reverse = true
#		motor_input = -1
#	elif event.is_action_pressed("accelerate"):
#		motor_input = 1
		
#	if event.is_action_released("decelerate"):
#		reverse = false
#		motor_input = 0
#	elif event.is_action_released("accelerate"):
#		motor_input = 0
		
	if event.is_action_pressed("handBreak"):
		#var torque_dir = 0
		#if Input.is_action_pressed("turnRight"):
			#torque_dir = -1
		#elif Input.is_action_pressed("turnLeft"):
			#torque_dir = 1
		#apply_torque_impulse(torque_dir * global_basis.y * 50)
		hand_break = true
		is_slipping = true
	elif event.is_action_released("handBreak"):
		hand_break = false
		
	if Input.is_action_pressed("tiltFront"):
		roll_input = 1
	elif Input.is_action_pressed("tiltBack"):
		roll_input = -1
	else:
		roll_input = 0
		
	if Input.is_action_pressed("turnRight"):
		air_turn_input = 1
	elif Input.is_action_pressed("turnLeft"):
		air_turn_input = -1
	else:
		air_turn_input = 0


func _basic_steering_rotation(delta: float) -> void:
	var turn_input := Input.get_axis("turnRight","turnLeft") * tire_turn_speed
	
	if turn_input:
		$Model_grp/WheelFL.rotation.y = clampf($Model_grp/WheelFL.rotation.y + turn_input * delta,
			deg_to_rad(-tire_max_turn_degrees), deg_to_rad(tire_max_turn_degrees))
		$Model_grp/WheelFR.rotation.y = clampf($Model_grp/WheelFR.rotation.y + turn_input * delta,
			deg_to_rad(-tire_max_turn_degrees), deg_to_rad(tire_max_turn_degrees))
		$Model_grp/WheelFM.rotation.y = clampf($Model_grp/WheelFM.rotation.y + turn_input * delta,
			deg_to_rad(-tire_max_turn_degrees), deg_to_rad(tire_max_turn_degrees))
	else:
		$Model_grp/WheelFL.rotation.y = move_toward($Model_grp/WheelFL.rotation.y, 0, tire_turn_speed * delta)
		$Model_grp/WheelFR.rotation.y = move_toward($Model_grp/WheelFR.rotation.y, 0, tire_turn_speed * delta)
		$Model_grp/WheelFM.rotation.y = move_toward($Model_grp/WheelFM.rotation.y, 0, tire_turn_speed * delta)


func _physics_process(_delta: float) -> void:
	#physics
	_basic_steering_rotation(_delta)
	var id := 0
	for wheel in wheels:
		wheel.force_raycast_update()
		_do_single_wheel_suspension(wheel)
		if wheel.name == "WheelFM" or wheel.name == "WheelRM": 
			_do_single_wheel_acceleration(wheel)
		_do_single_wheel_traction(wheel, id)
		id += 1
		#glide
		if is_gliding:
			_do_glide()
			frames_passed_gliding += 1
			_stop_glide_on_the_ground(wheel, frames_passed_gliding)
	
	#Check Which Terrain Type Bike is on
	terrain_type_checker.force_raycast_update()
	_check_terrain_type()
	_update_wheel_effects()
	_pause_splash_if_not_water()
	
	##Water Wheel
	#if current_wheel_mode == WheelMode.WATER:
		#_pause_splash_in_the_air()
		
	#defining flying state
	var wheels_in_air = _get_wheels_in_air_arr()
	if wheels_in_air.size() == 6 :
		flying = true
		_do_tilt_in_air()
		#stablizer 2: torque to make bike's up same as world up
		apply_torque(global_basis.y.cross(Vector3.UP) * 170.0)
	else: 
		flying = false
		
	#change center of mass depending on flying state
	if flying:
		center_of_mass = Vector3(0,0,0)
	else:
		center_of_mass = Vector3(0,-0.1,0)
	
	#for tracking charged time for jumping, etc.
	if is_jump_charging:
		charged_time += _delta
		for wheel in wheels:
			var contact = wheel.get_collision_point()
			var force_pos = contact - global_position
			if wheel.is_colliding():
				var press_dir = -wheel.global_transform.basis.y
				var force_vector = press_dir * press_force
				apply_force(force_vector, force_pos)
	
	#debug arrows
	if show_debug: 
		DebugDraw3D.draw_sphere(center_of_mass, 1.0, Color.OLIVE_DRAB, _delta)
		DebugDraw3D.draw_arrow_ray(global_position, linear_velocity, 1.0, Color.YELLOW, _delta)
		$Model_grp/WheelRR.visible = true
		$Model_grp/WheelRL.visible = true
		$Model_grp/WheelFR.visible = true
		$Model_grp/WheelFL.visible = true
	else:
		$Model_grp/WheelRR.visible = false
		$Model_grp/WheelRL.visible = false
		$Model_grp/WheelFR.visible = false
		$Model_grp/WheelFL.visible = false
	
	
	var forward = Input.get_action_strength("accelerate")
	var backward = Input.get_action_strength("decelerate")
	motor_input = forward - backward


func _get_point_velocity(point: Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - global_position)


func _get_wheels_in_air_arr() -> Array:
	var wheels_in_air := []
	for wheel in wheels:
		if not wheel.is_colliding():
			wheels_in_air.append(wheel)
			
	return wheels_in_air


func _check_terrain_type() -> void:
	if not terrain_type_checker.is_colliding():
		current_terrain_type = TerrainTypes.ROAD
		#print("checker not functioning")
		return
	
	var colliding_terrain = terrain_type_checker.get_collider()
	
	if colliding_terrain.is_in_group("Wall"):
		current_terrain_type = TerrainTypes.WALL
	elif colliding_terrain.is_in_group("Mud"):
		current_terrain_type = TerrainTypes.MUD
	elif colliding_terrain.is_in_group("Water"):
		current_terrain_type = TerrainTypes.WATER
	else:
		current_terrain_type = TerrainTypes.ROAD #least priority
	
	#print("name: ", colliding_terrain.name, " group: ", colliding_terrain.get_groups(), " detected: ", current_terrain_type)

#ITEM MODE
func _set_item_mode(new_mode: ItemMode) -> void:
	if current_item_mode == new_mode:
		return
	
	_exit_item_mode(current_item_mode)
	current_item_mode = new_mode
	_enter_item_mode(new_mode)
	
func _enter_item_mode(mode: ItemMode) -> void:
	match mode:
		ItemMode.NORMAL:
			pass
		ItemMode.PUNCH:
			_activate_punch_item_effects()
			is_item_effect_active = true
		ItemMode.HEADLIGHT:
			_activate_headlight_item_effects()
			is_item_effect_active = true
		ItemMode.MAGNET:
			_activate_magnet_item_effects()
			is_item_effect_active = true

func _exit_item_mode(mode: ItemMode) -> void:
	match mode:
		ItemMode.NORMAL:
			pass
		ItemMode.PUNCH:
			_deactivate_punch_item_effects()
			is_item_effect_active = false
		ItemMode.HEADLIGHT:
			_deactivate_headlight_item_effects()
			is_item_effect_active = false
		ItemMode.MAGNET:
			_deactivate_magnet_item_effects()
			is_item_effect_active = false

func _activate_punch_item_effects() -> void:
	pass
func _activate_headlight_item_effects() -> void:
	pass
func _activate_magnet_item_effects() -> void:
	pass
func _deactivate_punch_item_effects() -> void:
	pass
func _deactivate_headlight_item_effects() -> void:
	pass
func _deactivate_magnet_item_effects() -> void:
	pass


##ITEM MODE END

#WHEEL MODE
func _set_wheel_mode(new_mode: WheelMode) -> void:
	if current_wheel_mode == new_mode:
		return
	
	_exit_wheel_mode(current_wheel_mode)
	current_wheel_mode = new_mode
	_enter_wheel_mode(new_mode)
	
func _enter_wheel_mode(mode: WheelMode) -> void:
	match mode:
		WheelMode.NORMAL:
			get_node("Model_grp/WheelFM/Wheel_Front").visible = true
			get_node("Model_grp/WheelRM/Wheel_Rear").visible = true
		WheelMode.TENTACLE:
			get_node("Model_grp/WheelFM/TentacleWheel_Front").visible = true
			get_node("Model_grp/WheelRM/TentacleWheel_Rear").visible = true
			_activate_tentacle_wheel_effects()
			is_wheel_effect_active = true
		WheelMode.OFFROAD:
			_activate_offroad_wheel_effects()
			is_wheel_effect_active = true
		WheelMode.WATER:
			get_node("Model_grp/WheelFM/WaterWheel_Front").visible = true
			get_node("Model_grp/WheelRM/WaterWheel_Rear").visible = true
			_activate_water_wheel_effects()
			is_wheel_effect_active = true

func _exit_wheel_mode(mode: WheelMode) -> void:
	match mode:
		WheelMode.NORMAL:
			get_node("Model_grp/WheelFM/Wheel_Front").visible = false
			get_node("Model_grp/WheelRM/Wheel_Rear").visible = false
		WheelMode.TENTACLE:
			get_node("Model_grp/WheelFM/TentacleWheel_Front").visible = false
			get_node("Model_grp/WheelRM/TentacleWheel_Rear").visible = false
			_deactivate_tentacle_wheel_effects()
			is_wheel_effect_active = false
		WheelMode.OFFROAD:
			_deactivate_offroad_wheel_effects()
			is_wheel_effect_active = false
		WheelMode.WATER:
			get_node("Model_grp/WheelFM/WaterWheel_Front").visible = false
			get_node("Model_grp/WheelRM/WaterWheel_Rear").visible = false
			_deactivate_water_wheel_effects()
			is_wheel_effect_active = false
			
func _activate_tentacle_wheel_effects() -> void:
	for wheel in wheels:
		if wheel.name == "WheelFM" or wheel.name == "WheelRM":
			wheel.over_extend = 1.0
		#TODO: fix hardcoded
	acceleration = 3600.0

func _activate_offroad_wheel_effects() -> void:
	pass

func _activate_water_wheel_effects() -> void:
	#collision setting
	for wheel in wheels:
		wheel.set_collision_mask_value(3, true)
	set_collision_mask_value(3, true)

func _pause_splash_if_not_water() -> void:
	#if current_wheel_mode != WheelMode.WATER:
		#return
		
	if flying or current_terrain_type != TerrainTypes.WATER: #not on water
		#print("not on water", current_terrain_type)
		if is_splash_particles_on:
			for particle in splash_particles:
				particle.emitting = false
			is_splash_particles_on = false
			#print("particle off")
	else: #on water
		if not is_splash_particles_on:
			var speed = linear_velocity.length()
			for particle in splash_particles:
				particle.process_material.set("initial_velocity_max", speed)
				particle.emitting = true
			is_splash_particles_on = true
			#print("particle on")

func _deactivate_tentacle_wheel_effects() -> void:
	for wheel in wheels:
		if wheel.name == "WheelFM" or wheel.name == "WheelRM":
			wheel.over_extend = 0.0
		#TODO: fix hardcoded
		acceleration = 2400.0

func _deactivate_offroad_wheel_effects() -> void:
	pass

func _deactivate_water_wheel_effects() -> void:
	#collision setting
	for wheel in wheels:
		wheel.set_collision_mask_value(3, false)
	set_collision_mask_value(3, false)

func _update_wheel_effects() -> void:
	match current_wheel_mode: #check current wheel mode
		WheelMode.NORMAL:
			pass
		WheelMode.TENTACLE: 
			if current_terrain_type == TerrainTypes.WALL: #if bike is on proper terrain for mode
				if not is_wheel_effect_active: #if bike's mode effect isn't applied
					_activate_tentacle_wheel_effects()
					is_wheel_effect_active = true
					print("TENTACLE WHEEL RESUME")
			else: #if bike is not on proper terrain for mode
				if is_wheel_effect_active: #if bike's mode effect have already applied
					_deactivate_tentacle_wheel_effects()
					is_wheel_effect_active = false
					print("TENTACLE WHEEL PAUSED")
		WheelMode.OFFROAD:
			if current_terrain_type == TerrainTypes.MUD:
				if not is_wheel_effect_active:
					_activate_offroad_wheel_effects()
					is_wheel_effect_active = true
					print("OFFROAD WHEEL RESUME")
			else:
				if is_wheel_effect_active:
					_deactivate_offroad_wheel_effects()
					is_wheel_effect_active = false
					print("OFFROAD WHEEL PAUSED")
		WheelMode.WATER:
			#Exception: we don't want to pause water wheel cuz it turns off the barrier which is water terrain.
			#We can change how water script works tho
			pass 

##END WHEEL MODE

#JUMPING
func _do_jump() -> void:
	var jump_force = jump_min_force + clamp(charged_time, 0.0, max_charge_sec) / max_charge_sec * jump_extra_max_force
	charged_time = 0.0
	
	var jump_dir := Vector3.UP #  global_basis.y #
	var force_vector = jump_dir * jump_force
	
	for wheel in wheels:
		#var contact = wheel.get_collision_point()
		#var force_pos = contact - global_position
		if wheel.is_colliding():
			apply_impulse(force_vector)
			center_of_mass = Vector3(0,-1,0) * 0.3


#ANIMATING WINGS
func _set_wing_anim_default() -> void:
	wingLAnimator.play("Anim_WingDefault_Test")
	wingRAnimator.play("Anim_WingDefault_Test")


func _open_wing_anim() -> void:
	wingLAnimator.play("Anim_WingOpen_Test")
	wingRAnimator.play("Anim_WingOpen_Test")


func _flap_wing_anim(anim_name: String):
	if anim_name == "Anim_WingOpen_Test":
		wingLAnimator.play("Anim_WingIdle_Test")
		wingRAnimator.play("Anim_WingIdle_Test")


func _close_wing_anim() -> void:
		wingLAnimator.stop()
		wingRAnimator.stop()
		wingLAnimator.play_backwards("Anim_WingClose_Test")
		wingRAnimator.play_backwards("Anim_WingClose_Test")

##END ANIMATING WINGS

#GLIDING
func _do_glide() -> void:
	var forward_dir = -global_basis.z
	var vel = linear_velocity.dot(forward_dir)

	var lift_force = Vector3.UP * vel * lift_strength
	apply_force(lift_force)
	
	var drag_force = -linear_velocity
	apply_force(drag_force)
	
	forward_dir.y = 0
	forward_dir = forward_dir.normalized()
	apply_force(forward_dir * glide_strength)
	if show_debug: DebugDraw3D.draw_arrow_ray(global_transform.origin, forward_dir, glide_strength, Color.REBECCA_PURPLE)
	
	#stablizer 1: anti angular vel for bike
	apply_torque(-angular_velocity * 5.0)
	
	##stablizer 2: torque to make bike's up same as world up
	#apply_torque(global_basis.y.cross(Vector3.UP) * 20.0)

func _stop_glide_on_the_ground(ray: RaycastWheel, framePassed: int) -> void:
	if  framePassed > 1000 and ray.is_colliding():
		is_gliding = false
		gravity_scale = 1.0
		_close_wing_anim()
		frames_passed_gliding = 0

#CONTROL MIDAIR 

#this is designed to affect every frame, even if not gliding.
func _do_tilt_in_air() -> void:
	
	var xaxis_torque := -global_basis.x * roll_input * roll_strength
	
	apply_torque(xaxis_torque)
	
	var yaxis_torque := -global_basis.y * air_turn_input * turn_strength
	
	apply_torque(yaxis_torque)

##END GLIDING

#BASIC BIKE MOVEMENT PHYSICS
func _do_single_wheel_traction(ray: RaycastWheel, idx: int) -> void:
	if not ray.is_colliding(): return
	
	var steer_side_dir := ray.global_basis.x
	var tire_vel := _get_point_velocity(ray.wheel.global_position)
	var steering_x_vel := steer_side_dir.dot(tire_vel)
	
	var grip_factor := absf(steering_x_vel/tire_vel.length())
	var x_traction := ray.grip_curve.sample_baked(grip_factor)
	
	#Skid marks
	skid_marks[idx].global_position = ray.get_collision_point() + Vector3.UP * 0.01
	skid_marks[idx].look_at(skid_marks[idx].global_position + global_basis.z)
	
	#grip_factor < 0.2 : meaning the vel of the wheel kinda aligns with the car speed again
	if not hand_break and grip_factor < 0.2:
		is_slipping = false
		skid_marks[idx].emitting = false
		
	if hand_break and current_wheel_mode != WheelMode.WATER:
		x_traction = 0.01
		if not skid_marks[idx].emitting:
			skid_marks[idx].emitting = true
		elif is_slipping:
			x_traction = 0.1
	
	var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
	#var x_force := -global_basis.x * steering_x_vel * x_traction * ((mass*gravity)/4.0)
	#less reality, but easier control of steering
	var x_force := -steer_side_dir * steering_x_vel * x_traction * ((mass*gravity)/3.0)
	
	#z force traction
	var f_vel := -ray.global_basis.z.dot(tire_vel)
	var z_traction := 0.05
	var z_force := global_basis.z * f_vel * z_traction * ((mass*gravity)/3.0)
	
	var force_pos := ray.wheel.global_position - global_position
	
	apply_force(x_force, force_pos)
	apply_force(z_force, force_pos)
	if show_debug: DebugDraw3D.draw_arrow_ray(ray.wheel.global_position, x_force/mass, 1.0, Color.WEB_GREEN, 0.1)
	if show_debug: DebugDraw3D.draw_arrow_ray(ray.wheel.global_position, z_force/mass, 1.0, Color.MEDIUM_PURPLE, 0.1)

func _do_single_wheel_acceleration(ray: RaycastWheel) -> void:
	var forward_dir := -ray.global_basis.z
	var vel := forward_dir.dot(linear_velocity)
	ray.wheel.rotate_x((-vel * get_process_delta_time())/ray.wheel_radius)
	
	if ray.is_colliding():
		var contact := ray.wheel.global_position
		var force_pos := contact - global_position
		
		if ray.is_motor and motor_input:
			var speed_ratio := vel / max_speed
			var ac := accel_curve.sample_baked(speed_ratio)
			var force_vector := forward_dir * acceleration * motor_input * ac
			apply_force(force_vector, force_pos)
			if (speed_ratio == 1):
				if (!$EngineHighGearAudio.playing):
					$EngineHighGearAudio.play()
				$EngineIdleAudio.playing = false
				$EngineLowGearAudio.playing = false
			elif (speed_ratio >= 0.5):
				if (!$EngineLowGearAudio.playing):
					$EngineLowGearAudio.play()
				$EngineIdleAudio.playing = false
				$EngineHighGearAudio.playing = false
			else:
				if (!$EngineIdleAudio.playing):
					$EngineIdleAudio.play()
				$EngineLowGearAudio.playing = false
				$EngineHighGearAudio.playing = false
			if show_debug: DebugDraw3D.draw_arrow_ray(contact, force_vector/mass, 1.0, Color.RED, 0.1)

func _do_single_wheel_suspension(ray: RaycastWheel) -> void:
	if ray.is_colliding():
		ray.target_position.y = -(ray.rest_dist + ray.wheel_radius + ray.over_extend)
		var contact := ray.get_collision_point()
		var spring_up_dir := ray.global_transform.basis.y
		var spring_len := ray.global_position.distance_to(contact) - ray.wheel_radius 
		var offset := ray.rest_dist - spring_len
		
		ray.wheel.position.y = - spring_len
		
		var spring_force := ray.spring_strength * offset
		
		# damping force = damping + relative velocity
		var world_vel := _get_point_velocity(contact)
		var relative_vel := spring_up_dir.dot(world_vel)
		var spring_damp_force := ray.spring_damping * relative_vel
		
		var force_vector := (spring_force - spring_damp_force) * ray.get_collision_normal()
		
		contact = ray.wheel.global_position
		var force_pos_offset := contact - global_position
		apply_force(force_vector, force_pos_offset)
		if show_debug: DebugDraw3D.draw_arrow_ray(contact, force_vector/mass, 1.0, Color.BLUE, 0.1)


func start_boost(duration: float, force: float) -> void: #NEW
	if is_boosting:
		return
	
	for particle in boost_particle:
		particle.emitting = true
	
	is_boosting = true
	
	var time := 0.0
	var forward = -global_transform.basis.z
	
	apply_central_impulse(forward * 2000.0)
	
	while time < duration:
		var delta = get_physics_process_delta_time()
		time += delta
	
		apply_central_force(forward * force)
	
		await get_tree().physics_frame
	
	for particle in boost_particle:
		particle.emitting = false
	
	is_boosting = false
	
## END BASIC BIKE MOVEMENT PHYSICS
