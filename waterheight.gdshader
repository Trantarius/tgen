shader_type spatial;
//render_mode unshaded;

uniform sampler2D TEXTURE : repeat_disable;
uniform float min_depth=0.0;
uniform float max_depth=1.0;
uniform float displacement=1.0;
uniform bool use_bicubic = true;
uniform sampler2D gradient : repeat_disable, filter_linear;

uniform sampler2D depth_texture : hint_depth_texture;
uniform sampler2D screen_texture: hint_screen_texture;

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
	h = displacement * (h-min_depth)/(max_depth-min_depth);
	vec2 TEXTURE_PIXEL_SIZE = 1.0/vec2(textureSize(TEXTURE,0));
	vec4 cl = textureGet(TEXTURE, UV+vec2(-TEXTURE_PIXEL_SIZE.x,0));
	float hl = cl.x+cl.y+cl.z;
	hl = displacement * (hl-min_depth)/(max_depth-min_depth);
	vec4 cu = textureGet(TEXTURE, UV+vec2(0,-TEXTURE_PIXEL_SIZE.y));
	float hu = cu.x+cu.y+cu.z;
	hu = displacement * (hu-min_depth)/(max_depth-min_depth);
	VERTEX.y += h;
	NORMAL = normalize(vec3((hl-h)/TEXTURE_PIXEL_SIZE.x, 1.0, (hu-h)/TEXTURE_PIXEL_SIZE.y));
	// Called for every vertex the material is visible on.
}




void fragment() {

	ALBEDO = vec3(0.02,0.05,0.2);
	float vdepth = -VERTEX.z;

	float depth = texture(depth_texture, SCREEN_UV).x;
  	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
  	view.xyz /= view.w;
  	float linear_depth = -view.z;
	float termination = pow(0.5,(linear_depth-vdepth));
	
	//ALBEDO = texture(screen_texture,SCREEN_UV).rgb;
	//ALBEDO = mix(vec3(0.02,0.05,0.2),ALBEDO, clamp(termination,0,1));
	ALBEDO = texture(gradient,vec2(termination,0)).xyz;
	ALPHA = clamp(1.0-pow(0.5,(linear_depth-vdepth)*2000.0),0,1);
}

void light() {
	SPECULAR_LIGHT += pow(clamp(dot(reflect(-VIEW,NORMAL), LIGHT), 0.0, 1.0),64) * ATTENUATION * LIGHT_COLOR*ALBEDO;
}