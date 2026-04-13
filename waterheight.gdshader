shader_type spatial;

float sample_to_height(vec4 sample){
	return sample.r+sample.g+sample.b;
}

#define SAMPLE_TO_HEIGHT(SAMPLE) sample_to_height(SAMPLE)

#include "height_displace.gdshaderinc"

#include "normalmap.gdshaderinc"

uniform sampler2D gradient : repeat_disable, filter_linear;

uniform sampler2D depth_texture : hint_depth_texture;


varying vec3 vert;

void vertex() {
	vert = VERTEX;
	hmap_vertex(VERTEX, UV);
}

void fragment() {
	float zdepth;
	hmap_fragment(UV, vert, TANGENT, BINORMAL, NORMAL, VIEW_MATRIX, MODEL_NORMAL_MATRIX, MODEL_MATRIX, PROJECTION_MATRIX, DEPTH, zdepth);

	float depth = texture(depth_texture, SCREEN_UV).x;
  	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
  	view.xyz /= view.w;
  	float linear_depth = -view.z;
	float termination = pow(0.5,(linear_depth-zdepth));
	
	ALBEDO = texture(gradient,vec2(termination,0)).xyz;
	ALPHA = clamp(1.0-pow(0.5,(linear_depth-zdepth)*2000.0),0,1);

}

void light() {
	SPECULAR_LIGHT += pow(clamp(dot(reflect(-VIEW,NORMAL), LIGHT), 0.0, 1.0),64) * ATTENUATION * LIGHT_COLOR*texture(gradient,vec2(1,0)).rgb;
}