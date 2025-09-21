shader_type spatial;

uniform sampler2D TEXTURE;
uniform sampler2D waves;
uniform float min_depth=0.0;
uniform float max_depth=1.0;
uniform float displace=1.0;
uniform bool use_bicubic = true;

uniform sampler2D depth_texture : hint_depth_texture;

#include "bicubic.gdshaderinc"

vec4 textureGet(sampler2D sampler, vec2 pos){
	if(use_bicubic){
		return textureBicubic(sampler, pos);
	}else{
		return texture(sampler, pos);
	}
}

void vertex() {
	vec4 c = textureGet(TEXTURE, UV);
	float h = c.x+c.y+c.z;
	h = displace * (h-min_depth)/(max_depth-min_depth);
	vec2 TEXTURE_PIXEL_SIZE = 1.0/vec2(textureSize(TEXTURE,0));
	vec4 cl = textureGet(TEXTURE, UV+vec2(-TEXTURE_PIXEL_SIZE.x,0));
	float hl = cl.x+cl.y+cl.z;
	hl = displace * (hl-min_depth)/(max_depth-min_depth);
	vec4 cu = textureGet(TEXTURE, UV+vec2(0,-TEXTURE_PIXEL_SIZE.y));
	float hu = cu.x+cu.y+cu.z;
	hu = displace * (hu-min_depth)/(max_depth-min_depth);
	VERTEX.y += h;
	NORMAL = normalize(vec3((hl-h)/TEXTURE_PIXEL_SIZE.x, 1.0+texture(waves,UV).r/10.0, (hu-h)/TEXTURE_PIXEL_SIZE.y));
	// Called for every vertex the material is visible on.
}


void fragment() {
	
	ALBEDO = vec3(0.1,0.1,0.5);
	float vdepth = -VERTEX.z;
	
	float depth = texture(depth_texture, SCREEN_UV).x;
  	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
  	view.xyz /= view.w;
  	float linear_depth = -view.z;
	ALPHA = 1.0-pow(0.5,(linear_depth-vdepth)*200.0);
	//VERTEX.y += h;
	//NORMAL = normalize(vec3((hl-h)/TEXTURE_PIXEL_SIZE.x, displace, (hu-h)/TEXTURE_PIXEL_SIZE.y));
		
	
	// Called for every pixel the material is visible on.
}

void light() {
    DIFFUSE_LIGHT += clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR / PI/10.0;
	SPECULAR_LIGHT += pow(clamp(dot(reflect(VIEW,NORMAL), LIGHT), 0.0, 1.0),200) * ATTENUATION * LIGHT_COLOR;
}