extends SubViewport

@export_group("Land","land_")
@export_range(0,1,0.001,"or_less","or_greater") var land_min_value:float = 0.0:
	get:
		return $Land.material.get_shader_parameter("min_depth")
	set(to):
		if(!has_node("Land")):
			await ready
		$Land.material.set_shader_parameter("min_depth",to)
@export_range(0,1,0.001,"or_less","or_greater") var land_max_value:float = 1.0:
	get:
		return $Land.material.get_shader_parameter("max_depth")
	set(to):
		if(!has_node("Land")):
			await ready
		$Land.material.set_shader_parameter("max_depth",to)
@export_range(0,1,0.001,"or_less","or_greater") var land_line_step:float = 0.2:
	get:
		return $Land.material.get_shader_parameter("line_step")
	set(to):
		if(!has_node("Land")):
			await ready
		$Land.material.set_shader_parameter("line_step",to)
@export_range(0,1,0.001,"or_less","or_greater") var land_line_offset:float = 0:
	get:
		return $Land.material.get_shader_parameter("line_offset")
	set(to):
		if(!has_node("Land")):
			await ready
		$Land.material.set_shader_parameter("line_offset",to)
@export_range(0,10,1,"or_greater") var land_minor_steps:int = 3:
	get:
		return $Land.material.get_shader_parameter("minor_steps")
	set(to):
		if(!has_node("Land")):
			await ready
		$Land.material.set_shader_parameter("minor_steps",to)
@export_range(0,1,0.001) var land_minor_opacity:float = 0.25:
	get:
		return $Land.material.get_shader_parameter("minor_opacity")
	set(to):
		if(!has_node("Land")):
			await ready
		$Land.material.set_shader_parameter("minor_opacity",to)
@export var land_line_color:Color = Color.BLACK:
	get:
		return $Land.material.get_shader_parameter("line_color")
	set(to):
		if(!has_node("Land")):
			await ready
		$Land.material.set_shader_parameter("line_color",to)
@export var land_continuous_shade:bool = false:
	get:
		return $Land.material.get_shader_parameter("continuous_shade")
	set(to):
		if(!has_node("Land")):
			await ready
		$Land.material.set_shader_parameter("continuous_shade",to)
@export var land_shade_low:Color = Color.BLACK:
	get:
		return $Land.material.get_shader_parameter("shade_low")
	set(to):
		if(!has_node("Land")):
			await ready
		$Land.material.set_shader_parameter("shade_low",to)
@export var land_shade_high:Color = Color.WHITE:
	get:
		return $Land.material.get_shader_parameter("shade_high")
	set(to):
		if(!has_node("Land")):
			await ready
		$Land.material.set_shader_parameter("shade_high",to)
@export var land_use_bicubic:bool = true:
	get:
		return $Land.material.get_shader_parameter("use_bicubic")
	set(to):
		if(!has_node("Land")):
			await ready
		$Land.material.set_shader_parameter("use_bicubic",to)

@export_group("Water","water_")
@export var water_show:bool = true:
	get:
		return $Water.visible
	set(to):
		if(!has_node("Water")):
			await ready
		$Water.visible=to
@export_range(0,1,0.001,"or_less","or_greater") var water_min_value:float = 0.0:
	get:
		return $Water.material.get_shader_parameter("min_value")
	set(to):
		if(!has_node("Water")):
			await ready
		$Water.material.set_shader_parameter("min_value",to)
@export_range(0,1,0.001,"or_less","or_greater") var water_max_value:float = 1.0:
	get:
		return $Water.material.get_shader_parameter("max_value")
	set(to):
		if(!has_node("Water")):
			await ready
		$Water.material.set_shader_parameter("max_value",to)
@export var water_color:Color = Color.BLUE:
	get:
		return $Water.material.get_shader_parameter("color")
	set(to):
		if(!has_node("Water")):
			await ready
		$Water.material.set_shader_parameter("color",to)
@export var water_use_bicubic:bool = true:
	get:
		return $Water.material.get_shader_parameter("use_bicubic")
	set(to):
		if(!has_node("Water")):
			await ready
		$Water.material.set_shader_parameter("use_bicubic",to)

@export_group("Sediment","sediment_")
@export var sediment_show:bool = true:
	get:
		return $Sediment.visible
	set(to):
		if(!has_node("Sediment")):
			await ready
		$Sediment.visible=to
@export_range(0,1,0.001,"or_less","or_greater") var sediment_min_value:float = 0.0:
	get:
		return $Sediment.material.get_shader_parameter("min_value")
	set(to):
		if(!has_node("Sediment")):
			await ready
		$Sediment.material.set_shader_parameter("min_value",to)
@export_range(0,1,0.001,"or_less","or_greater") var sediment_max_value:float = 1.0:
	get:
		return $Sediment.material.get_shader_parameter("max_value")
	set(to):
		if(!has_node("Sediment")):
			await ready
		$Sediment.material.set_shader_parameter("max_value",to)
@export var sediment_color:Color = Color.BLUE:
	get:
		return $Sediment.material.get_shader_parameter("color")
	set(to):
		if(!has_node("Sediment")):
			await ready
		$Sediment.material.set_shader_parameter("color",to)
@export var sediment_use_bicubic:bool = true:
	get:
		return $Sediment.material.get_shader_parameter("use_bicubic")
	set(to):
		if(!has_node("Sediment")):
			await ready
		$Sediment.material.set_shader_parameter("use_bicubic",to)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
