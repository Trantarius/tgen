@tool
class_name BoolProperty
extends CheckButton

var object:Object:
	set(to):
		object = to
		reset()
var property:StringName:
	set(to):
		property = to
		reset()

func _ready():
	reset()

func reset()->void:
	
	if(!is_instance_valid(object)):
		return
	if(!(property in object)):
		return
	
	text = property.capitalize()
	button_pressed = object.get(property)
	
	disabled=false
	var prop_dict:Dictionary
	for prop:Dictionary in object.get_property_list():
		if(prop.name==property):
			prop_dict = prop
			break
	
	if(prop_dict.usage&PROPERTY_USAGE_READ_ONLY):
		disabled = true
	
func _toggled(toggled_on: bool) -> void:
	if(is_instance_valid(object) && property in object):
		object.set(property, toggled_on)
