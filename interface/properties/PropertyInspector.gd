@tool
class_name PropertyInspector
extends VBoxContainer

var object:Object:
	set(to):
		object = to
		reset()

@export var whitelist:PackedStringArray:
	set(to):
		whitelist = to
		reset()

@export var blacklist:PackedStringArray:
	set(to):
		blacklist = to
		reset()

@export var category_whitelist:PackedStringArray:
	set(to):
		category_whitelist = to
		reset()

@export var category_blacklist:PackedStringArray:
	set(to):
		category_blacklist = to
		reset()

@export var require_editor_flag:bool = true:
	set(to):
		require_editor_flag = to
		reset()

@export var skip_read_only:bool = false:
	set(to):
		skip_read_only = to
		reset()


func reset()->void:
	
	for child:Node in get_children():
		remove_child(child)
		child.queue_free()
	
	var pass_cat_wl:bool = category_whitelist.is_empty()
	var pass_cat_bl:bool = true
	var group:Expandable
	var group_hint:String
	
	if(!is_instance_valid(object)):
		return
	
	for prop:Dictionary in object.get_property_list():
		if(prop.usage&PROPERTY_USAGE_CATEGORY):
			pass_cat_wl = category_whitelist.is_empty()
			if(!pass_cat_wl):
				for cat:String in category_whitelist:
					if((prop.name as String).matchn(cat)):
						pass_cat_wl = true
						break
			pass_cat_bl = true
			if(!category_blacklist.is_empty()):
				for cat:String in category_blacklist:
					if((prop.name as String).matchn(cat)):
						pass_cat_bl = false
						break
			group = null
			group_hint=""
		elif(prop.usage&PROPERTY_USAGE_GROUP):
			if(prop.name.is_empty()):
				group = null
				group_hint=""
			elif(pass_cat_bl&&pass_cat_wl):
				group = Expandable.new()
				group.title = prop.name
				group.indent = 16
				add_child(group)
				group_hint=prop.hint_string
		elif(prop.usage&PROPERTY_USAGE_SUBGROUP):
			pass #unsupported
		elif(pass_cat_bl&&pass_cat_wl):
			var pass_wl:bool = whitelist.is_empty()
			if(!pass_wl):
				for pn:String in whitelist:
					if((prop.name as String).matchn(pn)):
						pass_wl = true
						break
			var pass_bl:bool = true
			if(!blacklist.is_empty()):
				for pn:String in blacklist:
					if((prop.name as String).matchn(pn)):
						pass_bl = false
						break
			
			var pass_edit_flag:bool = (!require_editor_flag || prop.usage&PROPERTY_USAGE_EDITOR) && (!skip_read_only || !prop.usage&PROPERTY_USAGE_READ_ONLY)
			
			if(is_instance_valid(group)&&!(prop.name as String).begins_with(group_hint)):
				group = null
				group_hint=""
			
			if(pass_wl && pass_bl && pass_edit_flag):
				if((prop.type==TYPE_INT||prop.type==TYPE_FLOAT) && (prop.hint==0 || prop.hint==PROPERTY_HINT_RANGE) ):
					var pnode:NumberProperty = NumberProperty.new()
					pnode.object = object
					pnode.property = prop.name
					if(is_instance_valid(group)):
						group.add_child(pnode)
					else:
						add_child(pnode)
				
				elif(prop.type==TYPE_BOOL):
					var pnode:BoolProperty = BoolProperty.new()
					pnode.object = object
					pnode.property = prop.name
					if(is_instance_valid(group)):
						group.add_child(pnode)
					else:
						add_child(pnode)
				
				elif(prop.type==TYPE_COLOR):
					var pnode:ColorProperty = ColorProperty.new()
					pnode.object = object
					pnode.property = prop.name
					if(is_instance_valid(group)):
						group.add_child(pnode)
					else:
						add_child(pnode)
	
	for child:Node in get_children():
		if(child is Expandable && child.get_child_count()==0):
			remove_child(child)
			child.queue_free()
