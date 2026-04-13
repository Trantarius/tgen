class_name NoiseStage
extends Node

@export_range(0,(1<<32)-1,1,"hide_slider") var random_seed:int = randi():
	set(to):
		random_seed=to
		config_buf_update=true
		if(auto_generate && is_inside_tree()):
			generate_noise()
@export_range(1,8,1,"or_greater") var detail:int = 5:
	set(to):
		detail = to
		config_buf_update=true
		if(auto_generate && is_inside_tree()):
			generate_noise()
@export_range(0.01,100.0,0.00001,"exp") var noise_scale:float = 1.0:
	set(to):
		noise_scale = to
		config_buf_update=true
		if(auto_generate && is_inside_tree()):
			generate_noise()
#@export var size:int = 512

var auto_generate:bool = false

static var shader_file:RDShaderFile = preload("res://noise.glsl")

var device:RenderingDevice
var main:Main

var config_buf_update:bool=true
var config_buf:RID
var shader_rid:RID
var pipeline:RID

func _enter_tree() -> void:
	device = RenderingServer.get_rendering_device()
	main = get_tree().current_scene as Main
	config_buf = device.storage_buffer_create(16)
	
	var shader_spirv:RDShaderSPIRV = shader_file.get_spirv()
	shader_rid = device.shader_create_from_spirv(shader_spirv)
	
	pipeline = device.compute_pipeline_create(shader_rid)

func _exit_tree() -> void:
	device.free_rid(pipeline)
	pipeline = RID()
	device.free_rid(config_buf)
	config_buf = RID()
	device.free_rid(shader_rid)
	shader_rid = RID()


func generate_noise():
	assert(is_inside_tree())
	
	if(config_buf_update):
		var config_bytes:PackedByteArray = PackedByteArray()
		config_bytes.resize(16)
		config_bytes.encode_u32(0,random_seed)
		config_bytes.encode_s32(4,detail)
		config_bytes.encode_float(8,main.buffers.map_scale)
		config_bytes.encode_float(12, noise_scale)
		device.buffer_update(config_buf, 0, 16, config_bytes)
	
	var texform:RDTextureFormat = device.texture_get_format(main.buffers.terrain.texture_rd_rid)
	
	var heightmap_uniform:RDUniform = RDUniform.new()
	heightmap_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	heightmap_uniform.binding = 0  # This matches the binding in the shader.
	heightmap_uniform.add_id(main.buffers.terrain.texture_rd_rid)
	
	var config_uniform:RDUniform = RDUniform.new()
	config_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	config_uniform.binding = 1
	config_uniform.add_id(config_buf)
	
	var uniform_set:RID = device.uniform_set_create([heightmap_uniform, config_uniform], shader_rid, 0)
	
	var compute_list:int = device.compute_list_begin()
	device.compute_list_bind_compute_pipeline(compute_list, pipeline)
	device.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	
	assert(texform.width%8==0)
	assert(texform.height%8==0)
	device.compute_list_dispatch(compute_list, texform.width/8, texform.height/8, 1)
	device.compute_list_end()
	#device.submit()
	#device.sync()
	#RenderingServer.force_draw()
	#RenderingServer.force_sync()
	
	device.free_rid(uniform_set)
	


func _on_generate_button_pressed() -> void:
	generate_noise()


func _on_auto_button_toggled(toggled_on: bool) -> void:
	auto_generate = toggled_on


func _on_buffers_changed() -> void:
	config_buf_update=true
	if(auto_generate):
		generate_noise()
