extends Label
var numb = 0
var isFinished = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"..".emit_signal("randomizeGoal")
	$"..".connect("fixed", onFixed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func onFixed() -> void:
	text = "SUCCESS!"
	isFinished = true

func _on__button_down() -> void:
	if (!isFinished):
		numb+= 1
		$"..".emit_signal("setFixer", numb)
		text = str(numb)
	pass # Replace with function body.


func _on__button_down_Subtract() -> void:
	if (!isFinished):
		numb-=1
		$"..".emit_signal("setFixer", numb)
		text = str(numb)
	pass # Replace with function body.
