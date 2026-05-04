extends AudioStreamPlayer
var songs = {
	"MainTrack" : preload("res://GTestStuff/Sounds/AudioFromMT/Songs/AboveDeck V2.mp3")
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playTrack("MainTrack")
	pass # Replace with function body.

func playTrack(songName: String):
	stream = songs[songName]
	play()
