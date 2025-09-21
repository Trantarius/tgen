extends Camera3D

var pitch:float = 0
var yaw:float = 0
var distance:float = 2

func _input(event: InputEvent) -> void:
	if(event is InputEventMouseMotion):
		if(Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)):
			pitch += event.relative.y/100.0
			yaw -= event.relative.x/100.0
			var xf:Transform3D = Transform3D.IDENTITY
			xf = xf.translated(Vector3(0,0,distance))
			xf = xf.rotated(Vector3.LEFT,pitch)
			xf = xf.rotated(Vector3.UP,yaw)
			transform = xf
