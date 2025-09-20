extends Camera2D

func _input(event: InputEvent) -> void:
	if(event is InputEventMouseMotion):
		if(Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
			position -= event.relative/zoom
	if(event.is_action_pressed("zoom_in")):
		zoom *= 1.1
	if(event.is_action_pressed("zoom_out")):
		zoom /= 1.1
