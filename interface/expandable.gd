@tool
class_name Expandable
extends VBoxContainer

@export var title:String:
	get:
		return button.text
	set(to):
		button.text = to

@export var expanded:bool:
	get:
		return button.button_pressed
	set(to):
		button.button_pressed = to
		queue_sort()

@export var indent:int:
	set(to):
		indent = to
		queue_sort()

@export var reserve_min_size:bool:
	set(to):
		reserve_min_size = to
		queue_sort()

@export var flat:bool:
	set(to):
		button.flat=to
	get:
		return button.flat


const expanded_icon := preload("res://interface/arrow_down.png")
const collapsed_icon := preload("res://interface/arrow_right.png")

var button:Button

func _init() -> void:
	button = Button.new()
	button.icon = collapsed_icon
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.toggle_mode = true
	button.toggled.connect(_on_button_toggled)
	button.theme_type_variation = "expand_button"
	add_child(button,false,Node.INTERNAL_MODE_FRONT)
	
	child_entered_tree.connect(_on_child_entered_tree)

func _on_child_entered_tree(child:Node)->void:
	if(child!=button):
		child.visible = button.button_pressed

func _on_button_toggled(toggled_on: bool) -> void:
	if(toggled_on):
		button.icon = expanded_icon
	else:
		button.icon = collapsed_icon
	for child in get_children():
		if(child!=button):
			child.visible = toggled_on

func _notification(what: int) -> void:
	if(what==NOTIFICATION_SORT_CHILDREN):
		for child:Control in get_children():
			var rect:Rect2 =  child.get_rect()
			rect.position.x += indent
			rect.size.x -= indent
			fit_child_in_rect(child, rect)
		var msize:Vector2 = button.get_minimum_size()
		if(expanded):
			for child:Control in get_children():
				var cs:Vector2 = child.get_combined_minimum_size()
				msize.x = max(msize.x, cs.x+indent)
				msize.y += cs.y + get_theme_constant("separation")
		elif(reserve_min_size):
			for child:Control in get_children():
				var cs:Vector2 = child.get_combined_minimum_size()
				msize.x = max(msize.x, cs.x+indent)
		custom_minimum_size = msize
