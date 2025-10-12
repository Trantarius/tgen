shader_type canvas_item;

uniform int use_channel : hint_enum("Red","Green","Blue","Alpha") = 0;
uniform float min_value = 0.0;
uniform float max_value = 1.0;
uniform vec4 color: source_color = vec4(1);
uniform bool use_bicubic = true;

#include "bicubic.gdshaderinc"

vec4 textureGet(sampler2D sampler, vec2 pos){
	if(use_bicubic){
		return textureBicubic(sampler, pos);
	}else{
		return texture(sampler, pos);
	}
}

void fragment() {
	float value = textureGet(TEXTURE,UV)[use_channel];
	value = (value-min_value)/(max_value-min_value);
	
	COLOR = color;
	COLOR.a *= clamp(value,0,1);
}