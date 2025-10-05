@tool
class_name NodeInspector
extends PropertyInspector

@export var node:Node:
	set(to):
		object = to
	get:
		return object
