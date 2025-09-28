@tool
class_name Expandable
extends VBoxContainer

@export var background:StyleBox:
	set(to):
		if(is_instance_valid(background)):
			background.changed.disconnect(queue_redraw)
		background = to
		if(is_instance_valid(background)):
			background.changed.connect(queue_redraw)
		queue_redraw()

func 


func _draw() -> void:
	if(is_instance_valid(background)):
		background.draw(get_canvas_item(),get_global_rect())
