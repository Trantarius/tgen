class_name WatershedGL
extends Resource

var heightmap:Texture2DRD
var flowmap:Texture2DRD
var offhand:Texture2DRD
@export var evaporation:float = 0.1

static var shader_file:RDShaderFile = preload("res://watershed.glsl")

func make_flowmaps()->void:
	var device:RenderingDevice = RenderingServer.get_rendering_device()
	var texform:RDTextureFormat = RDTextureFormat.new()
	texform.format = RenderingDevice.DATA_FORMAT_R32_SFLOAT
	texform.width = heightmap.get_width()
	texform.height = heightmap.get_height()
	texform.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | \
		RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT | RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	
	var zeros:PackedByteArray
	zeros.resize(4*texform.width*texform.height)
	for i in (texform.width*texform.height):
		zeros.encode_float(i*4,0.0)
	
	var texrid:RID = device.texture_create(texform, RDTextureView.new(), [zeros])
	flowmap = Texture2DRD.new()
	flowmap.texture_rd_rid = texrid
	
	texrid = device.texture_create(texform, RDTextureView.new(), [zeros])
	offhand = Texture2DRD.new()
	offhand.texture_rd_rid = texrid

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
	
	var flowmap_uniform2 := RDUniform.new()
	flowmap_uniform2.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	flowmap_uniform2.binding = 2  # This matches the binding in the shader.
	flowmap_uniform2.add_id(flowmap.texture_rd_rid)
	
	var offhand_uniform := RDUniform.new()
	offhand_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	offhand_uniform.binding = 2  # This matches the binding in the shader.
	offhand_uniform.add_id(offhand.texture_rd_rid)
	
	var offhand_uniform2 := RDUniform.new()
	offhand_uniform2.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	offhand_uniform2.binding = 1  # This matches the binding in the shader.
	offhand_uniform2.add_id(offhand.texture_rd_rid)
	
	var config_bytes:PackedByteArray = PackedByteArray()
	config_bytes.resize(4)
	config_bytes.encode_float(0, evaporation)
	var config_buf:RID = device.storage_buffer_create(config_bytes.size(), config_bytes)
	
	var config_uniform:RDUniform = RDUniform.new()
	config_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	config_uniform.binding = 3
	config_uniform.add_id(config_buf)
	
	var shader_spirv:RDShaderSPIRV = shader_file.get_spirv()
	var shader_rid = device.shader_create_from_spirv(shader_spirv)
	
	var uniform_set:RID = device.uniform_set_create([heightmap_uniform, flowmap_uniform, offhand_uniform, config_uniform], shader_rid, 0)
	var uniform_set2:RID = device.uniform_set_create([heightmap_uniform, offhand_uniform2, flowmap_uniform2, config_uniform], shader_rid, 0)
	var pipeline:RID = device.compute_pipeline_create(shader_rid)
	
	var compute_list:int = device.compute_list_begin()
	device.compute_list_bind_compute_pipeline(compute_list, pipeline)
	device.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	
	device.compute_list_dispatch(compute_list, heightmap.get_width()/8, heightmap.get_height()/8, 1)
	device.compute_list_add_barrier(compute_list)
	device.compute_list_bind_uniform_set(compute_list, uniform_set2, 0)
	device.compute_list_dispatch(compute_list, heightmap.get_width()/8, heightmap.get_height()/8, 1)
	device.compute_list_end()
	#device.submit()
	#device.sync()
	#RenderingServer.force_draw()
	#RenderingServer.force_sync()
	
	device.free_rid(pipeline)
	device.free_rid(uniform_set)
	device.free_rid(uniform_set2)
	device.free_rid(config_buf)
	device.free_rid(shader_rid)
