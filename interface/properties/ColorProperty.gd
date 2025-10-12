@tool
class_name ColorProperty
extends HBoxContainer

var object:Object:
	set(to):
		object = to
		reset()

var property:StringName:
	set(to):
		property = to
		reset()

var auto_update:bool = true

var label:Label
var picker:ColorPickerButton



func _init() -> void:
	label = Label.new()
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(label,false,Node.INTERNAL_MODE_BACK)
	picker = ColorPickerButton.new()
	picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(picker,false,Node.INTERNAL_MODE_BACK)
	picker.color_changed.connect(_on_color_picker_button_color_changed)

func _ready():
	reset()

func _process(delta: float) -> void:
	if(!Engine.is_editor_hint() && auto_update && is_visible_in_tree() && is_instance_valid(object) && property in object):
		picker.color = object.get(property)

func reset()->void:
	
	if(!is_instance_valid(object)):
		return
	if(!(property in object)):
		return
	
	label.text = property.capitalize()
	picker.color = object.get(property)


func _on_color_picker_button_color_changed(color: Color) -> void:
	if(is_instance_valid(object) && property in object):
		object.set(property,color)
