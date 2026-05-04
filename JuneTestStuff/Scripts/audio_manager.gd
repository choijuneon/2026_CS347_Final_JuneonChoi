extends Node

var audios = {
	"Jump" : preload("res://GTestStuff/Sounds/AudioFromMT/Finished SFX/Pup Spring.wav"),
	"Repair" : preload("res://GTestStuff/Sounds/AudioFromMT/UnfinishedSFX/DTM_REPAIR_REV2_415.wav"),
	"ModeChange" : preload("res://GTestStuff/Sounds/AudioFromMT/UnfinishedSFX/DTM_MODCH_VB_REV2_414.wav"),
	"Glide" : preload("res://GTestStuff/Sounds/AudioFromMT/Finished SFX/Pup Wings Loop.wav"),
	"Hurt" : preload("res://GTestStuff/Sounds/AudioFromMT/Finished SFX/Minor Chassis Impact.wav"),
	"Major Hurt" : preload("res://GTestStuff/Sounds/AudioFromMT/Finished SFX/Major Chassis Impact.wav"),
	"Breaking Barrier" : preload("res://GTestStuff/Sounds/AudioFromMT/Finished SFX/Chassis Impact Barricade.wav"),
	"Player Sanity Death" : preload("res://GTestStuff/Sounds/AudioFromMT/Finished SFX/Player Sanity Death.wav")
}

var audio_player


func play_audio(audioName: String):
	audio_player = AudioStreamPlayer.new()
	audio_player.bus = "SFX"
	audio_player.stream = audios[audioName]
	add_child(audio_player)
	audio_player.play()
	
	audio_player.finished.connect(audio_player.queue_free)
