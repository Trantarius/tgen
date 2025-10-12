extends SubViewport

@export var show_water:bool = true:
	get:
		return $Water.visible
	set(to):
		$Water.visible = to
@export_range(0,1,0,"or_less","or_greater") var min_value:float = 0.0:
	get:
		return $Land.material_override.get_shader_parameter("min_depth")
	set(to):
		$Land.material_override.set_shader_parameter("min_depth",to)
		$Water.material_override.set_shader_parameter("min_depth",to)
@export_range(0,1,0,"or_less","or_greater") var max_value:float = 1.0:
	get:
		return $Land.material_override.get_shader_parameter("max_depth")
	set(to):
		$Land.material_override.set_shader_parameter("max_depth",to)
		$Water.material_override.set_shader_parameter("max_depth",to)
@export_range(0,1,0,"or_less","or_greater") var displacement:float = 1.0:
	get:
		return $Land.material_override.get_shader_parameter("displacement")
	set(to):
		$Land.material_override.set_shader_parameter("displacement",to)
		$Water.material_override.set_shader_parameter("displacement",to)
@export_range(16,1024,1,"or_greater","exp") var mesh_detail:int = 128:
	get:
		return $Land.mesh.subdivide_width
	set(to):
		if(!has_node("Land")):
			await ready
		$Land.mesh.subdivide_width = to
		$Land.mesh.subdivide_depth = to
@export var use_bicubic:bool = true:
	get:
		return $Land.material_override.get_shader_parameter("use_bicubic")
	set(to):
		$Land.material_override.set_shader_parameter("use_bicubic",to)
		$Water.material_override.set_shader_parameter("use_bicubic",to)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
