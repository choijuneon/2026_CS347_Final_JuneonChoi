extends Control

@onready var jump_label = $JumpMod
#@onready var jump_UI = $"../JumpChargeBar"

#@onready var glide_label = $GlideMod
#@onready var punch_label = $PunchMod

func _ready():
	#hide_all()
	pass

func hide_all():
	#jump_UI.visible = false
	#jump_label.visible = false
#	glide_label.visible = false
#	punch_label.visible = false
	pass

func show_jump():
	#jump_UI.visible = true
	#jump_label.visible = true
	pass

func hide_jump():
	#jump_UI.visible = false
	#jump_label.visible = false
	pass

#func show_glide():
#	glide_label.visible = true

#func hide_glide():
#	glide_label.visible = false

#func show_punch():
#	punch_label.visible = true

#func hide_punch():
#	punch_label.visible = false
