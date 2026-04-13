class_name Buffers
extends Node

@export_range(8,16384,8,"hide_slider") var buffer_size:int = 512:
	set(to):
		if(buffer_size!=to):
			buffer_size = to
			if(is_inside_tree()):
				
				var old_terrain_rid:RID = terrain.texture_rd_rid
				var old_offhand_rid:RID = offhand.texture_rd_rid
				
				var texform:RDTextureFormat = RDTextureFormat.new()
				texform.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
				texform.width = buffer_size
				texform.height = buffer_size
				texform.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | \
					RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT | RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
				
				terrain.texture_rd_rid = device.texture_create(texform, RDTextureView.new())
				offhand.texture_rd_rid = device.texture_create(texform, RDTextureView.new())
				
				device.free_rid(old_terrain_rid)
				device.free_rid(old_offhand_rid)
			changed.emit()

@export var map_scale:float = 10.0:
	set(to):
		map_scale = to
		changed.emit()

var device:RenderingDevice

var terrain:Texture2DRD
var offhand:Texture2DRD

signal changed

func _enter_tree() -> void:
	device = RenderingServer.get_rendering_device()
	
	var texform:RDTextureFormat = RDTextureFormat.new()
	texform.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	texform.width = buffer_size
	texform.height = buffer_size
	texform.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | \
		RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT | RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	
	terrain = Texture2DRD.new()
	offhand = Texture2DRD.new()
	terrain.texture_rd_rid = device.texture_create(texform, RDTextureView.new())
	offhand.texture_rd_rid = device.texture_create(texform, RDTextureView.new())

func _exit_tree() -> void:
	device.free_rid(terrain.texture_rd_rid)
	terrain.texture_rd_rid = RID()
	terrain = null
	device.free_rid(offhand.texture_rd_rid)
	offhand.texture_rd_rid = RID()
	offhand = null
