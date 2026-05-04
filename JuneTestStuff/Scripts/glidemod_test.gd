extends Area3D

@export var bike : Node3D

@onready var control := bike.get_node("Control/GlideTimer")
@onready var label := bike.get_node("Control/GlideTimer/Label")
@onready var timer := bike.get_node("Control/GlideTimer/Timer")

func _ready():
	control.visible = false
	body_entered.connect(_on_body_entered)

func time_left_to_live():
	var time_left = timer.time_left
	var min = floor(time_left / 60)
	var sec = int(time_left) % 60
	return [min, sec]

func _process(delta: float) -> void:
	label.text = "%02d:%02d" % time_left_to_live()
	#
func _on_body_entered(body: Node) -> void:
	if body.name == "Bike":
		body.apply_impulse(-body.basis.z * 1000 + body.basis.y * 100)
		
		body.is_gliding = true
		body.gravity_scale = 0.1
		
		
		body.get_node("Wing_grp/WingL/AnimationPlayer").speed_scale = 1.0
		body.get_node("Wing_grp/WingL/AnimationPlayer").play("Anim_Wing_Test")
		
		body.get_node("Wing_grp/WingR/AnimationPlayer").speed_scale = 1.0
		body.get_node("Wing_grp/WingR/AnimationPlayer").play("Anim_Wing_Test")
		
		control.visible = true
		timer.start()
		await get_tree().create_timer(30.0).timeout
		
		#this can cause a problem if player glides more than 2 times in 30sec timer
		if control.visible == true:
			control.visible = false
		if body.is_gliding == true:
			body.is_gliding = false
		if body.gravity_scale != 1.0:
			body.gravity_scale = 1.0
