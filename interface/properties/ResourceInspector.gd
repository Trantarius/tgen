@tool
class_name ResourceInspector
extends PropertyInspector

@export var resource:Resource:
	set(to):
		object = to
	get:
		return object
