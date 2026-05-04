extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ColorRect.color.a = 0.0

func FadeOut():
	var tween = create_tween()
	tween.tween_property($ColorRect, "color:a", 255, 5.0)
	return tween

func FadeIn():
	var tween = create_tween()
	tween.tween_property($ColorRect, "color:a", 0, 5.0)
	return tween
