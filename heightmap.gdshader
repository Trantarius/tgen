shader_type spatial;

#include "height_displace.gdshaderinc"


uniform sampler2D depth_texture : hint_depth_texture;

varying vec3 vert;

void vertex() {
	vert = VERTEX;
	hmap_vertex(VERTEX, UV);
}


void fragment() {
	float zdepth;
	hmap_fragment(UV, vert, TANGENT, BINORMAL, NORMAL, VIEW_MATRIX, MODEL_NORMAL_MATRIX, MODEL_MATRIX,
	PROJECTION_MATRIX, DEPTH, zdepth);

	ALBEDO = vec3(0.1,0.08,0.05);
}