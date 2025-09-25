shader_type spatial;

uniform sampler2D TEXTURE;
uniform float min_depth=0.0;
uniform float max_depth=1.0;
uniform float displace=1.0;
uniform bool use_bicubic = true;

#include "bicubic.gdshaderinc"

vec4 textureGet(sampler2D sampler, vec2 pos){
	if(use_bicubic){
		return textureBicubic(sampler, pos);
	}else{
		return texture(sampler, pos);
	}
}

void vertex() {
	float h = textureGet(TEXTURE, UV).r;
	h = displace * (h-min_depth)/(max_depth-min_depth);
	vec2 TEXTURE_PIXEL_SIZE = 1.0/vec2(textureSize(TEXTURE,0));
	float hl = textureGet(TEXTURE, UV+vec2(-TEXTURE_PIXEL_SIZE.x,0)).r;
	hl = displace * (hl-min_depth)/(max_depth-min_depth);
	float hu = textureGet(TEXTURE, UV+vec2(0,-TEXTURE_PIXEL_SIZE.y)).r;
	hu = displace * (hu-min_depth)/(max_depth-min_depth);
	VERTEX.y += h;
	NORMAL = normalize(vec3((hl-h)/TEXTURE_PIXEL_SIZE.x, 1, (hu-h)/TEXTURE_PIXEL_SIZE.y));
	// Called for every vertex the material is visible on.
}


void fragment() {
	ALBEDO = vec3(0.1,0.08,0.05);
	//VERTEX.y += h;
	//NORMAL = normalize(vec3((hl-h)/TEXTURE_PIXEL_SIZE.x, displace, (hu-h)/TEXTURE_PIXEL_SIZE.y));


	// Called for every pixel the material is visible on.
}