@tool
class_name DynamicStyleBox
extends StyleBox

@export var base:StyleBox:
	set(to):
		base=to
		emit_changed()

@export_group("Offset","offset_")
@export var offset_left:int:
	set(to):
		offset_left=to
		emit_changed()
@export var offset_top:int:
	set(to):
		offset_top=to
		emit_changed()
@export var offset_right:int:
	set(to):
		offset_right=to
		emit_changed()
@export var offset_bottom:int:
	set(to):
		offset_bottom=to
		emit_changed()


func offset_rect(rect: Rect2) -> Rect2:
	return Rect2(rect.position.x+offset_left, rect.position.y+offset_top, rect.size.x-offset_left-offset_right, rect.size.y-offset_bottom-offset_top)

func _get_draw_rect(rect: Rect2) -> Rect2:
	return offset_rect(rect)

func _draw(to_canvas_item: RID, rect: Rect2) -> void:
	#RenderingServer.canvas_item_add_rect(to_canvas_item, pad_rect(rect), color)
	base.draw(to_canvas_item,offset_rect(rect))

func _test_mask(point: Vector2, rect: Rect2) -> bool:
	if(!offset_rect(rect).has_point(point)):
		return false
	return base.test_mask(point,offset_rect(rect))
