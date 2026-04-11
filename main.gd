class_name Main
extends Node

var noisegl:NoiseGL = NoiseGL.new()
var flowgl:FlowGL = FlowGL.new()

var terrain:Texture2DRD
var offhand:Texture2DRD

var is_paused:bool = true

@export_range(0.0,1,0.001,"or_greater") var precipitation:float:
	get:
		return flowgl.precipitation*100000
	set(to):
		flowgl.precipitation = to/100000
@export_range(0.0,1,0.001,"or_greater") var evaporation:float:
	get:
		return flowgl.evaporation*100000
	set(to):
		flowgl.evaporation = to/100000
@export_range(0.0,1,0.001,"or_greater") var static_sediment_capacity:float:
	get:
		return flowgl.static_sediment_capacity
	set(to):
		flowgl.static_sediment_capacity = to
@export_range(0.0,1,0.001,"or_greater") var kinetic_sediment_capacity:float:
	get:
		return flowgl.kinetic_sediment_capacity
	set(to):
		flowgl.kinetic_sediment_capacity = to
@export_range(0.0,1,0.001,"or_greater") var erosion_rate:float:
	get:
		return flowgl.erosion_rate
	set(to):
		flowgl.erosion_rate = to
@export_range(0.0,1,0.001,"or_greater") var deposition_rate:float:
	get:
		return flowgl.deposition_rate
	set(to):
		flowgl.deposition_rate = to
@export_range(0,4,0.001,"or_greater") var slope_of_repose:float:
	get:
		return flowgl.slope_of_repose
	set(to):
		flowgl.slope_of_repose = to
@export_range(0.0,1,0.001,"or_greater") var gravity_rate:float:
	get:
		return flowgl.gravity_rate
	set(to):
		flowgl.gravity_rate = to
@export_range(0,1,0.001) var sim_rate:float:
	get:
		return flowgl.sim_rate
	set(to):
		flowgl.sim_rate = to

@export var status_label:Label
@export var topo_land:TextureRect
@export var topo_water:TextureRect
@export var topo_sediment:TextureRect
@export var mesh_land:MeshInstance3D
@export var mesh_water:MeshInstance3D

@export var buffers:Buffers
@export var noise_node:NoiseStage
@export var hydro_node:Node

func _ready() -> void:
	
	noise_node.generate_noise()
	
	topo_land.texture = buffers.terrain
	topo_water.texture = buffers.terrain
	topo_sediment.texture = buffers.terrain
	mesh_land.material_override.set_shader_parameter("height_texture",buffers.terrain)
	mesh_water.material_override.set_shader_parameter("height_texture",buffers.terrain)
	

var step_count = 10

func _process(delta: float) -> void:
	if(!is_paused):
		if(1.0/delta>120):
			step_count+=1
		elif(1.0/delta<100):
			step_count-=1
			if(step_count<1):
				step_count=1
		flowgl.run(step_count)
		topo_land.queue_redraw()
		topo_water.queue_redraw()
		topo_sediment.queue_redraw()
		status_label.text = "Running    "
		var rate = int(step_count/delta)
		status_label.text += str(rate)+" steps/s"
	else:
		status_label.text = "Paused"
	
func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("save")):
		var img:Image = terrain.get_image()
		img.save_exr("res://terrain.exr")
	if(event.is_action_pressed("toggle_sim")):
		is_paused = !is_paused
		
