class_name NoiseGL
extends Resource

@export var seed:int = randi()
@export var detail:int = 5
@export var scale:float = 4.0
@export var size:int = 512

static var shader_file:RDShaderFile = preload("res://noise.glsl")

func run()->Texture2DRD:
	
	var device:RenderingDevice = RenderingServer.get_rendering_device()
	var texform:RDTextureFormat = RDTextureFormat.new()
	texform.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	texform.width = size
	texform.height = size
	texform.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | \
		RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT | RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	
	var texrid:RID = device.texture_create(texform, RDTextureView.new())
	
	# Create uniform for heightmap.
	var heightmap_uniform := RDUniform.new()
	heightmap_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	heightmap_uniform.binding = 0  # This matches the binding in the shader.
	heightmap_uniform.add_id(texrid)
	
	var config_bytes:PackedByteArray = PackedByteArray()
	config_bytes.resize(12)
	config_bytes.encode_u32(0,seed)
	config_bytes.encode_s32(4,detail)
	config_bytes.encode_float(8,scale)
	var config_buf:RID = device.storage_buffer_create(config_bytes.size(), config_bytes)
	
	var config_uniform:RDUniform = RDUniform.new()
	config_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	config_uniform.binding = 1
	config_uniform.add_id(config_buf)
	
	var shader_spirv:RDShaderSPIRV = shader_file.get_spirv()
	var shader_rid = device.shader_create_from_spirv(shader_spirv)
	
	var uniform_set:RID = device.uniform_set_create([heightmap_uniform, config_uniform], shader_rid, 0)
	var pipeline:RID = device.compute_pipeline_create(shader_rid)
	
	var compute_list:int = device.compute_list_begin()
	device.compute_list_bind_compute_pipeline(compute_list, pipeline)
	device.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	
	device.compute_list_dispatch(compute_list, size/8, size/8, 1)
	device.compute_list_end()
	#device.submit()
	#device.sync()
	#RenderingServer.force_draw()
	#RenderingServer.force_sync()
	
	device.free_rid(pipeline)
	device.free_rid(uniform_set)
	device.free_rid(config_buf)
	device.free_rid(shader_rid)
	
	var tex:Texture2DRD = Texture2DRD.new()
	tex.texture_rd_rid = texrid
	return tex
