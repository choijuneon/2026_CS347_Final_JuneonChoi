extends AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect delegates
	ArduinoTest.probing.connect(probing)
	ArduinoTest.success.connect(connected)
	ArduinoTest.failure.connect(failed)
	
	# If arduinos are already connected, remain green
	if(ConnectionGlobal.isConnected == true):
		call_deferred("play", "success")
	else:
		call_deferred("play", "failed") # Otherwise turn red to indicate no connection

func probing(): # turn yellow when probing
	call_deferred("play", "probing")

func connected(): # once connected, turn green and set variable to true
	call_deferred("play", "success")
	#ConnectionGlobal.isConnected == true
	
func failed(): # turn red if no connection
	call_deferred("play", "failed")
