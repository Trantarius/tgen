extends Control

@export var noisegl:NoiseGL
@export var watershedgl:WatershedGL
@export var erosiongl:ErosionGL

var heightmap:Texture2DRD
var flowmap:Texture2DRD
var offhand:Texture2DRD

func _ready() -> void:
	heightmap = noisegl.run()
	$Heightmap.texture = heightmap
	
	watershedgl.heightmap = heightmap
	watershedgl.make_flowmaps()
	flowmap = watershedgl.flowmap
	offhand = watershedgl.offhand
	$Watershed.texture = flowmap
	
	erosiongl.heightmap = heightmap
	erosiongl.flowmap = flowmap
	

func _process(delta: float) -> void:
	watershedgl.run()
	erosiongl.run()
	$Watershed.queue_redraw()
	$Heightmap.queue_redraw()
	
