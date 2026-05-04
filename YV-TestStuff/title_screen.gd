extends Control

@onready var main_menu = $MainMenu
@onready var credits_panel = $CreditsPanel

func _ready():
	main_menu.visible = true
	credits_panel.visible = false

func _on_start_pressed() -> void:
	print("Start Pressed.")
	get_tree().change_scene_to_file("res://FinalAssets/Scenes/FinalMainScene.tscn") #change the inside quotations to the main game scene.


func _on_options_pressed() -> void:
	print("Options Pressed.")
	if ($MainMenu/VolumeSliders.visible):
		$MainMenu/VolumeSliders.visible = false
	else:
		$MainMenu/VolumeSliders.visible = true


func _on_credits_pressed() -> void:
	print("Credits Pressed.")
	main_menu.visible = false
	credits_panel.visible = true


func _on_exit_pressed() -> void:
	print("Exit Pressed.")
	get_tree().quit()

func _on_back_pressed():
	print("Back Button Pressed.")
	credits_panel.visible = false
	main_menu.visible = true
