extends SubViewport

@export var show_water:bool = true:
	get:
		return $Water.visible
	set(to):
		if(!has_node("Water")):
			await ready
		$Water.visible = to
@export_range(-1,1,0.001,"or_less","or_greater") var height_offset:float = 0.0:
	get:
		return $Land.material_override.get_shader_parameter("height_offset")
	set(to):
		if(!has_node("Land")||!has_node("Water")):
			await ready
		$Land.material_override.set_shader_parameter("height_offset",to)
		$Water.material_override.set_shader_parameter("height_offset",to)
@export_range(16,1024,1,"or_greater","exp") var mesh_detail:int = 128:
	get:
		return $Land.mesh.subdivide_width
	set(to):
		if(!has_node("Land")||!has_node("Water")):
			await ready
		if(!has_node("Land")):
			await ready
		$Land.mesh.subdivide_width = to
		$Land.mesh.subdivide_depth = to
@export var use_bicubic:bool = true:
	get:
		return $Land.material_override.get_shader_parameter("use_bicubic")
	set(to):
		if(!has_node("Land")||!has_node("Water")):
			await ready
		$Land.material_override.set_shader_parameter("use_bicubic",to)
		$Water.material_override.set_shader_parameter("use_bicubic",to)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var disp:float = 2.0/(get_tree().current_scene as Main).buffers.map_scale
	$Land.material_override.set_shader_parameter("displacement", disp)
	$Water.material_override.set_shader_parameter("displacement", disp)


func _on_buffers_changed() -> void:
	var disp:float = 2.0/(get_tree().current_scene as Main).buffers.map_scale
	$Land.material_override.set_shader_parameter("displacement", disp)
	$Water.material_override.set_shader_parameter("displacement", disp)
