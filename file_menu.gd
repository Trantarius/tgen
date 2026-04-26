extends PopupMenu

@export var dialog:FileDialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_id_pressed(id: int) -> void:
	dialog.popup_centered()
	pass # Replace with function body.
