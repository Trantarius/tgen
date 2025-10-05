@tool
class_name DynamicStyleBox
extends StyleBox

@export var base:StyleBox:
	set(to):
		base=to
		emit_changed()
@export_group("Padding","pad_")
@export var pad_left:int:
	set(to):
		pad_left=to
		content_margin_left = pad_left + margin_left
		emit_changed()
@export var pad_top:int:
	set(to):
		pad_top=to
		content_margin_top = pad_top + margin_top
		emit_changed()
@export var pad_right:int:
	set(to):
		pad_right=to
		content_margin_right = pad_right + margin_right
		emit_changed()
@export var pad_bottom:int:
	set(to):
		pad_bottom=to
		content_margin_bottom = pad_bottom + margin_bottom
		emit_changed()

@export_group("Margin","margin_")
@export var margin_left:int:
	set(to):
		margin_left=to
		content_margin_left = pad_left + margin_left
		emit_changed()
@export var margin_top:int:
	set(to):
		margin_top=to
		content_margin_top = pad_top + margin_top
		emit_changed()
@export var margin_right:int:
	set(to):
		margin_right=to
		content_margin_right = pad_right + margin_right
		emit_changed()
@export var margin_bottom:int:
	set(to):
		margin_bottom=to
		content_margin_bottom = pad_bottom + margin_bottom
		emit_changed()


func _validate_property(property: Dictionary) -> void:
	if(property.name.begins_with("content_margin_")):
		property.usage|=PROPERTY_USAGE_READ_ONLY

func pad_rect(rect: Rect2) -> Rect2:
	return Rect2(rect.position.x+pad_left, rect.position.y+pad_top, rect.size.x-pad_left-pad_right, rect.size.y-pad_bottom-pad_top)

func margin_rect(rect: Rect2) -> Rect2:
	return Rect2(rect.position.x+margin_left, rect.position.y+margin_top, rect.size.x-margin_left-margin_right, rect.size.y-margin_bottom-margin_top)

func _get_draw_rect(rect: Rect2) -> Rect2:
	return margin_rect(pad_rect(rect))

func _draw(to_canvas_item: RID, rect: Rect2) -> void:
	#RenderingServer.canvas_item_add_rect(to_canvas_item, pad_rect(rect), color)
	base.draw(to_canvas_item,pad_rect(rect))

func _test_mask(point: Vector2, rect: Rect2) -> bool:
	if(!pad_rect(rect).has_point(point)):
		return false
	return base.test_mask(point,pad_rect(rect))
