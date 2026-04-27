extends PopupMenu

#@export var dialog:FileDialog
var main:Main

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main = get_tree().current_scene as Main

func _on_id_pressed(id: int) -> void:
	
	match id:
		0:
			save()
	pass # Replace with function body.

func save()->void:
	var dialog:FileDialog = FileDialog.new()
	dialog.filters = [
		"*.exr;EXR;image/x-exr",
		"*.png;PNG;image/png",
		"*.jpeg,*.jpg;JPEG;image/jpeg",
		"*.webp;WEBP;image/webp"
	]
	get_tree().root.add_child(dialog)
	dialog.popup_centered()
	var path:String = await dialog.file_selected
	var img:Image = main.buffers.terrain.get_image()
	match path.get_extension():
		"exr":
			img.save_exr(path)
		"png":
			img.save_png(path)
		"jpeg","jpg":
			img.save_jpg(path)
		"webp":
			img.save_webp(path)
		_:
			var warning:AcceptDialog = AcceptDialog.new()
			warning.dialog_text = "File extension not recognized: "+path.get_extension()
			warning.canceled.connect(warning.queue_free)
			warning.confirmed.connect(warning.queue_free)
			get_tree().root.add_child(warning)
			warning.popup_centered()
