//shader_type spatial;

#ifndef SAMPLE_TO_HEIGHT
#define SAMPLE_TO_HEIGHT(SAMPLE) (SAMPLE).r
#endif

uniform sampler2D height_texture: repeat_disable;
uniform float min_depth=0.0;
uniform float max_depth=1.0;
uniform float displacement=1.0;
uniform bool use_bicubic = true;

#include "bicubic.gdshaderinc"

vec4 textureGet(sampler2D sampler, vec2 pos){
	if(use_bicubic){
		return textureBicubic(sampler, pos);
	}else{
		return texture(sampler, pos);
	}
}

void hmap_vertex(inout vec3 _vertex, in vec2 _uv) {
	float h = SAMPLE_TO_HEIGHT(textureGet(height_texture, _uv));
	h = displacement * (h-min_depth)/(max_depth-min_depth);
	_vertex.y += h;
}


void hmap_fragment(in vec2 _uv, in vec3 _vary_vert, 
inout vec3 _tangent, inout vec3 _binormal, inout vec3 _normal,
in mat4 _view_matrix, in mat3 _model_normal_matrix, in mat4 _model_matrix,
in mat4 _projection_matrix, out float _depth, out float zdepth) {

	float h = SAMPLE_TO_HEIGHT(textureGet(height_texture, _uv));
	h = displacement * (h-min_depth)/(max_depth-min_depth);
	vec2 texture_pixel_size = 1.0/vec2(textureSize(height_texture,0));
	float hl = SAMPLE_TO_HEIGHT(textureGet(height_texture, _uv+vec2(-texture_pixel_size.x,0)));
	hl = displacement * (hl-min_depth)/(max_depth-min_depth);
	float hu = SAMPLE_TO_HEIGHT(textureGet(height_texture, _uv+vec2(0,-texture_pixel_size.y)));
	hu = displacement * (hu-min_depth)/(max_depth-min_depth);

	vec3 vertex = _vary_vert;

	vec3 vert_l = _vary_vert + vec3(-texture_pixel_size.x,hl,0);
	vec3 vert_u = _vary_vert + vec3(0,hu,-texture_pixel_size.y);
	vertex.y += h;
	_tangent = normalize(vert_l - vertex);
	_binormal = normalize(vert_u - vertex);
	_normal = -cross(_tangent,_binormal);
	_tangent = mat3(_view_matrix)*_model_normal_matrix*_tangent;
	_binormal = mat3(_view_matrix)*_model_normal_matrix*_binormal;
	_normal = mat3(_view_matrix)*_model_normal_matrix*_normal;

	vertex = (_view_matrix*_model_matrix*vec4(vertex,1)).xyz;

	vec4 ndc = _projection_matrix * vec4(vertex,1);
	ndc.xyz /= ndc.w;
	
	_depth = ndc.z;
	zdepth = -vertex.z;
}