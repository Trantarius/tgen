@tool
class_name NumberProperty
extends VBoxContainer

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
var spinbox:SpinBox
var slider:HSlider

func _init()->void:
	label = Label.new()
	add_child(label,false,Node.INTERNAL_MODE_BACK)
	spinbox = SpinBox.new()
	add_child(spinbox,false,Node.INTERNAL_MODE_BACK)
	spinbox.value_changed.connect(_on_spin_box_value_changed)
	slider = HSlider.new()
	add_child(slider,false,Node.INTERNAL_MODE_BACK)
	slider.share(spinbox)

func _ready():
	reset()

func _process(_delta: float) -> void:
	if(!Engine.is_editor_hint() && auto_update && is_visible_in_tree() && is_instance_valid(object) && property in object):
		spinbox.value = object.get(property)

func reset()->void:
	
	if(!is_instance_valid(object)):
		return
	if(!(property in object)):
		return
	
	label.text = property.capitalize()
	
	spinbox.editable = true
	spinbox.prefix = ""
	spinbox.suffix = ""
	spinbox.min_value = 0
	spinbox.max_value = 100
	spinbox.step = 1
	spinbox.set_value_no_signal(0)
	spinbox.allow_greater = false
	spinbox.allow_lesser = false
	
	slider.editable = true
	slider.visible = true
	slider.scrollable = false
	
	var prop_dict:Dictionary
	for pdict:Dictionary in object.get_property_list():
		if(pdict.name == property):
			prop_dict = pdict
			break
	
	var hint:PropertyHint = prop_dict.hint
	if(hint==PROPERTY_HINT_RANGE):
		var parts:PackedStringArray = (prop_dict.hint_string as String).split(",",false)
		if(parts.size()>0 && parts[0].is_valid_float()):
			spinbox.min_value = parts[0].to_float()
		if(parts.size()>1 && parts[1].is_valid_float()):
			spinbox.max_value = parts[1].to_float()
		if(parts.size()>2 && parts[2].is_valid_float()):
			spinbox.step = parts[2].to_float()
		
		spinbox.allow_greater = "or_greater" in parts
		spinbox.allow_lesser = "or_less" in parts
		slider.exp_edit = "exp" in parts
		slider.visible = !("hide_slider" in parts)
		
		for part:String in parts:
			if(part.begins_with("prefix:")):
				spinbox.prefix = part.trim_prefix("prefix:")
			elif(part.begins_with("suffix:")):
				spinbox.suffix = part.trim_prefix("suffix:")
	
	var val = object.get(property)
	if(val is float || val is int):
		spinbox.set_value_no_signal(val)
	
	if(prop_dict.usage&PROPERTY_USAGE_READ_ONLY):
		spinbox.editable=false
		slider.editable=false


func _on_spin_box_value_changed(value: float) -> void:
	if(is_instance_valid(object) && property in object):
		object.set(property, value)
