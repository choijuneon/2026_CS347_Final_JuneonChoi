extends Control

var can_pause = false
var can_toggle = true

func _ready():
	visible = false

func _unhandled_input(event):
	print("INPUT DETECTED")  # debug
	
	if event.is_action_pressed("ui_pause") and can_pause and can_toggle:
		print("PAUSE TRIGGERED")
		toggle_pause()

func toggle_pause():
	can_toggle = false
	
	if visible:
		close_pause()
	else:
		get_tree().paused = true
		visible = true
	
	await get_tree().create_timer(0.2, true).timeout
	can_toggle = true

func _on_resume_pressed():
	print("Resume Pressed.")
	
	can_toggle = false
	close_pause()
	
	await get_tree().create_timer(0.2, true).timeout
	can_toggle = true

func _on_restart_pressed():
	print("Restart Pressed.")
	
	close_pause()
	
	await get_tree().process_frame
	
	get_tree().change_scene_to_file("res://FinalAssets/Scenes/FinalMainScene.tscn")

func _on_options_pressed() -> void:
	print("Options Pressed.")
	$VolumeSliders.visible = !$VolumeSliders.visible

func _on_quit_pressed():
	print("Quit Button Pressed.")
	close_pause()
	get_tree().change_scene_to_file("res://YV-TestStuff/TitleScreen.tscn")

func close_pause():
	get_tree().paused = false
	visible = false
	$VolumeSliders.visible = false
