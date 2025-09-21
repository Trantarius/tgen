extends Node

@export var noisegl:NoiseGL
@export var flowgl:FlowGL

var terrain:Texture2DRD
var offhand:Texture2DRD

func _ready() -> void:
	terrain = noisegl.run()
	
	offhand = flowgl.make_terrain(terrain.get_size())
	flowgl.offhand = offhand
	flowgl.terrain = terrain
	flowgl.run()
	
	offhand = flowgl.make_terrain(terrain.get_size())
	flowgl.offhand = offhand
	
	$Land.texture = terrain
	$Water.texture = terrain
	$Sediment.texture = terrain
	$MeshInstance3D.material_override.set_shader_parameter("TEXTURE",terrain)
	$MeshInstance3D2.material_override.set_shader_parameter("TEXTURE",terrain)
	

func _process(delta: float) -> void:
	for i in 1:
		flowgl.run()
	$Land.queue_redraw()
	$Water.queue_redraw()
	$Sediment.queue_redraw()
	
