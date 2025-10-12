extends Camera2D

func _input(event: InputEvent) -> void:
	if(event is InputEventMouseMotion):
		if(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
			position -= event.relative/zoom
	if(event.is_action_pressed("zoom_in")):
		if(zoom.x<1_000):
			zoom *= 1.1
	if(event.is_action_pressed("zoom_out")):
		if(zoom.x>1.0/1_000.0):
			zoom /= 1.1
