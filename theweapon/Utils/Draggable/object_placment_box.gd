extends StaticBody2D

func _ready() -> void:
	modulate = Color(Color.MEDIUM_PURPLE, 0.7)

func _process(delta):
	if Dragable.is_dragging:
		visible = true
	else:
		visible = false
