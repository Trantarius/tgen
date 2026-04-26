class_name Main
extends Node


var terrain:Texture2DRD
var offhand:Texture2DRD

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
	
	#noise_node.generate_noise()
	
	topo_land.texture = buffers.terrain
	topo_water.texture = buffers.terrain
	topo_sediment.texture = buffers.terrain
	mesh_land.material_override.set_shader_parameter("height_texture",buffers.terrain)
	mesh_water.material_override.set_shader_parameter("height_texture",buffers.terrain)
