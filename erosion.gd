class_name Erosion
extends Node

@export_range(0.0,1,0.001,"or_greater") var precipitation:float = 0.1:
	set(to):
		precipitation = to
		config_buf_update=true
@export_range(0.0,1,0.001,"or_greater") var evaporation:float = 0.0:
	set(to):
		evaporation = to
		config_buf_update=true
@export_range(0.0,1,0.001,"or_greater") var static_sediment_capacity:float = 0.01:
	set(to):
		static_sediment_capacity = to
		config_buf_update=true
@export_range(0.0,1,0.001,"or_greater") var kinetic_sediment_capacity:float = 0.5:
	set(to):
		kinetic_sediment_capacity = to
		config_buf_update=true
@export_range(0.0,1,0.001,"or_greater") var erosion_rate:float = 0.1:
	set(to):
		erosion_rate = to
		config_buf_update=true
@export_range(0.0,1,0.001,"or_greater") var deposition_rate:float = 0.1:
	set(to):
		deposition_rate = to
		config_buf_update=true
@export_range(0,4,0.001,"or_greater") var slope_of_repose:float = 1.0:
	set(to):
		slope_of_repose = to
		config_buf_update=true
@export_range(0.0,1,0.001,"or_greater") var gravity_rate:float = 0.01:
	set(to):
		gravity_rate = to
		config_buf_update=true
@export_range(0,1,0.001) var sim_rate:float = 0.1:
	set(to):
		sim_rate = to
		config_buf_update=true


static var shader_file:RDShaderFile = preload("res://flow.glsl")

var device:RenderingDevice
var main:Main

var config_buf_update:bool = true
var shader_rid:RID
var config_buf:RID
var pipeline:RID

func _enter_tree() -> void:
	device = RenderingServer.get_rendering_device()
	
	config_buf = device.storage_buffer_create(36)
	
	var shader_spirv:RDShaderSPIRV = shader_file.get_spirv()
	shader_rid = device.shader_create_from_spirv(shader_spirv)
	
	pipeline = device.compute_pipeline_create(shader_rid)
	main = get_tree().current_scene as Main

func _exit_tree() -> void:
	device.free_rid(pipeline)
	pipeline=RID()
	device.free_rid(config_buf)
	config_buf=RID()
	device.free_rid(shader_rid)
	shader_rid=RID()


func run(step_count:int)->void:
	
	# Create uniform for heightmap.
	var terrain_uniform := RDUniform.new()
	terrain_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	terrain_uniform.binding = 0  # This matches the binding in the shader.
	terrain_uniform.add_id(main.buffers.terrain.texture_rd_rid)
	
	var offhand_uniform := RDUniform.new()
	offhand_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	offhand_uniform.binding = 1  # This matches the binding in the shader.
	offhand_uniform.add_id(main.buffers.offhand.texture_rd_rid)
	
	var terrain_uniform2 := RDUniform.new()
	terrain_uniform2.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	terrain_uniform2.binding = 1  # This matches the binding in the shader.
	terrain_uniform2.add_id(main.buffers.terrain.texture_rd_rid)
	
	var offhand_uniform2 := RDUniform.new()
	offhand_uniform2.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	offhand_uniform2.binding = 0  # This matches the binding in the shader.
	offhand_uniform2.add_id(main.buffers.offhand.texture_rd_rid)
	
	if(config_buf_update):
		var config_bytes:PackedByteArray = PackedByteArray()
		config_bytes.resize(36)
		config_bytes.encode_float(0, precipitation/100000)
		config_bytes.encode_float(4, evaporation/100000)
		config_bytes.encode_float(8, static_sediment_capacity)
		config_bytes.encode_float(12, kinetic_sediment_capacity)
		config_bytes.encode_float(16, erosion_rate)
		config_bytes.encode_float(20, deposition_rate)
		config_bytes.encode_float(24, slope_of_repose)
		config_bytes.encode_float(28, gravity_rate)
		config_bytes.encode_float(32, sim_rate)
		device.buffer_update(config_buf, 0, 36, config_bytes)
		config_buf_update = false
	
	var config_uniform:RDUniform = RDUniform.new()
	config_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	config_uniform.binding = 2
	config_uniform.add_id(config_buf)
	
	var uniform_set:RID = device.uniform_set_create([terrain_uniform, offhand_uniform, config_uniform], shader_rid, 0)
	var uniform_set2:RID = device.uniform_set_create([offhand_uniform2, terrain_uniform2, config_uniform], shader_rid, 0)
	
	var compute_list:int = device.compute_list_begin()
	device.compute_list_bind_compute_pipeline(compute_list, pipeline)
	
	var t_width:int = main.buffers.terrain.get_width()/8
	var t_height:int = main.buffers.terrain.get_height()/8
	
	for i in step_count:
		device.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
		device.compute_list_dispatch(compute_list, t_width, t_height, 1)
		device.compute_list_add_barrier(compute_list)
		device.compute_list_bind_uniform_set(compute_list, uniform_set2, 0)
		device.compute_list_dispatch(compute_list, t_width, t_height, 1)
		device.compute_list_add_barrier(compute_list)
	
	device.compute_list_end()
	#device.submit()
	#device.sync()
	#RenderingServer.force_draw()
	#RenderingServer.force_sync()
	
	device.free_rid(uniform_set)
	device.free_rid(uniform_set2)

var is_paused:bool = true
var current_step_count = 10

func _process(delta: float) -> void:
	if(!is_paused):
		if(1.0/delta>120):
			current_step_count+=1
		elif(1.0/delta<100):
			current_step_count-=1
			if(current_step_count<1):
				current_step_count=1
		run(current_step_count)
		main.topo_land.queue_redraw()
		main.topo_water.queue_redraw()
		main.topo_sediment.queue_redraw()
		main.status_label.text = "Running    "
		var rate = int(current_step_count/delta)
		main.status_label.text += str(rate)+" steps/s"
	else:
		main.status_label.text = "Paused"


func _on_run_button_toggled(toggled_on: bool) -> void:
	is_paused = !toggled_on
