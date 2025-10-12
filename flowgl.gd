class_name FlowGL
extends Resource

var terrain:Texture2DRD
var offhand:Texture2DRD
var precipitation:float = 0.000001
var evaporation:float = 0.0000
var static_sediment_capacity:float = 0.01
var kinetic_sediment_capacity:float = 0.5
var erosion_rate:float = 0.1
var deposition_rate:float = 0.1
var slope_of_repose:float = 1.0
var gravity_rate:float = 0.1
var sim_rate:float = 0.1


static var shader_file:RDShaderFile = preload("res://flow.glsl")

func make_terrain(size:Vector2i)->Texture2DRD:
	var device:RenderingDevice = RenderingServer.get_rendering_device()
	var texform:RDTextureFormat = RDTextureFormat.new()
	texform.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	texform.width = size.x
	texform.height = size.y
	texform.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | \
		RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT | RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	
	var zeros:PackedByteArray
	zeros.resize(4*texform.width*texform.height*4)
	for i in (texform.width*texform.height*4):
		zeros.encode_float(i*4,0.0)
	
	var texrid:RID = device.texture_create(texform, RDTextureView.new(), [zeros])
	var tex:Texture2DRD = Texture2DRD.new()
	tex.texture_rd_rid = texrid
	return tex

func run(step_count:int)->void:
	
	var device:RenderingDevice = RenderingServer.get_rendering_device()
	
	# Create uniform for heightmap.
	var terrain_uniform := RDUniform.new()
	terrain_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	terrain_uniform.binding = 0  # This matches the binding in the shader.
	terrain_uniform.add_id(terrain.texture_rd_rid)
	
	var offhand_uniform := RDUniform.new()
	offhand_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	offhand_uniform.binding = 1  # This matches the binding in the shader.
	offhand_uniform.add_id(offhand.texture_rd_rid)
	
	var terrain_uniform2 := RDUniform.new()
	terrain_uniform2.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	terrain_uniform2.binding = 1  # This matches the binding in the shader.
	terrain_uniform2.add_id(terrain.texture_rd_rid)
	
	var offhand_uniform2 := RDUniform.new()
	offhand_uniform2.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	offhand_uniform2.binding = 0  # This matches the binding in the shader.
	offhand_uniform2.add_id(offhand.texture_rd_rid)
	
	var config_bytes:PackedByteArray = PackedByteArray()
	config_bytes.resize(36)
	config_bytes.encode_float(0, precipitation)
	config_bytes.encode_float(4, evaporation)
	config_bytes.encode_float(8, static_sediment_capacity)
	config_bytes.encode_float(12, kinetic_sediment_capacity)
	config_bytes.encode_float(16, erosion_rate)
	config_bytes.encode_float(20, deposition_rate)
	config_bytes.encode_float(24, slope_of_repose)
	config_bytes.encode_float(28, gravity_rate)
	config_bytes.encode_float(32, sim_rate)
	var config_buf:RID = device.storage_buffer_create(config_bytes.size(), config_bytes)
	
	var config_uniform:RDUniform = RDUniform.new()
	config_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	config_uniform.binding = 2
	config_uniform.add_id(config_buf)
	
	var shader_spirv:RDShaderSPIRV = shader_file.get_spirv()
	var shader_rid = device.shader_create_from_spirv(shader_spirv)
	
	var uniform_set:RID = device.uniform_set_create([terrain_uniform, offhand_uniform, config_uniform], shader_rid, 0)
	var uniform_set2:RID = device.uniform_set_create([offhand_uniform2, terrain_uniform2, config_uniform], shader_rid, 0)
	var pipeline:RID = device.compute_pipeline_create(shader_rid)
	
	var compute_list:int = device.compute_list_begin()
	device.compute_list_bind_compute_pipeline(compute_list, pipeline)
	
	for i in step_count:
		device.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
		device.compute_list_dispatch(compute_list, terrain.get_width()/8, terrain.get_height()/8, 1)
		device.compute_list_add_barrier(compute_list)
		device.compute_list_bind_uniform_set(compute_list, uniform_set2, 0)
		device.compute_list_dispatch(compute_list, terrain.get_width()/8, terrain.get_height()/8, 1)
		device.compute_list_add_barrier(compute_list)
	
	device.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	device.compute_list_dispatch(compute_list, terrain.get_width()/8, terrain.get_height()/8, 1)
	device.compute_list_end()
	#device.submit()
	#device.sync()
	#RenderingServer.force_draw()
	#RenderingServer.force_sync()
	
	device.free_rid(pipeline)
	device.free_rid(uniform_set)
	device.free_rid(config_buf)
	device.free_rid(shader_rid)
	
	var tmp:RID = terrain.texture_rd_rid
	terrain.texture_rd_rid = offhand.texture_rd_rid
	offhand.texture_rd_rid = tmp
	
