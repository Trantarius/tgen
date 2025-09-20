class_name ErosionGL
extends Resource

var heightmap:Texture2DRD
var flowmap:Texture2DRD
@export var erosion:float = 2.0
@export var rate:float = 0.0000001

static var shader_file:RDShaderFile = preload("res://erosion.glsl")

func run()->void:
	
	var device:RenderingDevice = RenderingServer.get_rendering_device()
	
	# Create uniform for heightmap.
	var heightmap_uniform := RDUniform.new()
	heightmap_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	heightmap_uniform.binding = 0  # This matches the binding in the shader.
	heightmap_uniform.add_id(heightmap.texture_rd_rid)
	
	var flowmap_uniform := RDUniform.new()
	flowmap_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	flowmap_uniform.binding = 1  # This matches the binding in the shader.
	flowmap_uniform.add_id(flowmap.texture_rd_rid)
	
	var config_bytes:PackedByteArray = PackedByteArray()
	config_bytes.resize(8)
	config_bytes.encode_float(0, erosion)
	config_bytes.encode_float(4, rate)
	var config_buf:RID = device.storage_buffer_create(config_bytes.size(), config_bytes)
	
	var config_uniform:RDUniform = RDUniform.new()
	config_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	config_uniform.binding = 2
	config_uniform.add_id(config_buf)
	
	var shader_spirv:RDShaderSPIRV = shader_file.get_spirv()
	var shader_rid = device.shader_create_from_spirv(shader_spirv)
	
	var uniform_set:RID = device.uniform_set_create([heightmap_uniform, flowmap_uniform, config_uniform], shader_rid, 0)
	var pipeline:RID = device.compute_pipeline_create(shader_rid)
	
	var compute_list:int = device.compute_list_begin()
	device.compute_list_bind_compute_pipeline(compute_list, pipeline)
	device.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	
	device.compute_list_dispatch(compute_list, heightmap.get_width()/8, heightmap.get_height()/8, 1)
	device.compute_list_end()
	#device.submit()
	#device.sync()
	#RenderingServer.force_draw()
	#RenderingServer.force_sync()
	
	device.free_rid(pipeline)
	device.free_rid(uniform_set)
	device.free_rid(config_buf)
	device.free_rid(shader_rid)
