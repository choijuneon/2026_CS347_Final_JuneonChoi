extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer.play()
	$PFade.FadeOut()
	await $PFade.FadeIn().finished
	$PFade/Button.visible = true
	pass # Replace with function body.


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://FinalAssets/Scenes/FinalMainScene.tscn")
	pass # Replace with function body.
