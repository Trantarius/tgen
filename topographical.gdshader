shader_type canvas_item;

uniform float min_depth=0.0;
uniform float max_depth=1.0;
uniform float line_step=0.25;
uniform float line_offset=0.0;
uniform int minor_steps = 4;
uniform float minor_opacity = 0.25;
uniform vec4 line_color: source_color = vec4(0,0,0,1);
uniform bool continuous_shade = false;
uniform vec3 shade_low: source_color = vec3(0.25,0.25,0.25);
uniform vec3 shade_high: source_color = vec3(0.75,0.75,0.75);
uniform float normal_depth = 64.0;
uniform bool use_bicubic = true;

varying vec2 zoom;

#include "bicubic.gdshaderinc"

vec4 textureGet(sampler2D sampler, vec2 pos){
	if(use_bicubic){
		return textureBicubic(sampler, pos);
	}else{
		return texture(sampler, pos);
	}
}

void vertex() {
	mat4 m = CANVAS_MATRIX*MODEL_MATRIX;
	zoom = vec2(length(m[0]),length(m[1]));
	// Called for every vertex the material is visible on.
}


void fragment() {
	float h = textureGet(TEXTURE, UV).r;
	float p = mod(h+line_offset,line_step);
	
	float h_up = textureGet(TEXTURE,UV+TEXTURE_PIXEL_SIZE*vec2(0,-1)/zoom).r;
	float h_left = textureGet(TEXTURE,UV+TEXTURE_PIXEL_SIZE*vec2(-1,0)/zoom).r;
	float h_ul = textureGet(TEXTURE, UV+TEXTURE_PIXEL_SIZE*vec2(-1,-1)/zoom).r;
	float p_up = mod(h_up+line_offset,line_step);
	bool isline = abs(p-p_up)>line_step/2.0;
	if(!isline){
		float p_left = mod(h_left+line_offset,line_step);
		isline = abs(p-p_left)>line_step/2.0;
	}
	if(!isline){
		float p_ul = mod(h_ul+line_offset,line_step);
		isline = abs(p-p_ul)>line_step/2.0;
	}
	
	bool is_minor_line=false;
	if(!isline && minor_steps>1){
		float minor_steps_f = float(minor_steps);
		p = mod(h+line_offset,line_step/minor_steps_f);
		p_up = mod(h_up+line_offset,line_step/minor_steps_f);
		is_minor_line = abs(p-p_up)>line_step/minor_steps_f/2.0;
		if(!is_minor_line){
			float p_left = mod(h_left+line_offset,line_step/minor_steps_f);
			is_minor_line = abs(p-p_left)>line_step/minor_steps_f/2.0;
		}
		if(!is_minor_line){
			float p_ul = mod(h_ul+line_offset,line_step/minor_steps_f);
			is_minor_line = abs(p-p_ul)>line_step/minor_steps_f/2.0;
		}
	}
	
	
	float s;
	if(continuous_shade){
		s = h;
	}else{
		s = (floor((h+line_offset)/line_step)*line_step-line_offset);
	}
	s = (s-min_depth)/(max_depth-min_depth);
	
	COLOR.rgb = vec3(s);//mix(shade_low,shade_high,s);

	if(isline){
		COLOR.rgb = mix(COLOR.rgb,line_color.rgb,line_color.a);
	}else if(is_minor_line){
		COLOR.rgb = mix(COLOR.rgb,line_color.rgb,line_color.a*minor_opacity);
		
	}
	
	
	if(normal_depth>0.0){
		NORMAL = normalize(vec3((h_left-h)*zoom.x, (h_up-h)*zoom.y,1.0/normal_depth));
	}
	
		
	
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
