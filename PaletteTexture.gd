@tool
class_name PaletteTexture
extends ImageTexture

@export var palette:PackedColorArray:
	set(to):
		palette = to
		_update()

@export var format:Image.Format = Image.FORMAT_RGBA8:
	set(to):
		format = to
		_update()

func _update()->void:
	var img:Image = Image.create(palette.size(),1,false,format)
	for i in palette.size():
		img.set_pixel(i,0,palette[i])
	set_image(img)
	emit_changed()
