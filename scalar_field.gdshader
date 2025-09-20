shader_type canvas_item;

uniform int use_channel : hint_enum("Red","Green","Blue","Alpha") = 0;
uniform float min_value = 0.0;
uniform float max_value = 1.0;
uniform int out_of_range_mode : hint_enum("Clamp","Repeat","Cull") = 0;
uniform sampler2D gradient: source_color, hint_default_white, repeat_disable;

void fragment() {
	float value = texture(TEXTURE,UV)[use_channel];
	value = (value-min_value)/(max_value-min_value);
	if(out_of_range_mode==0){
		value = clamp(value,0.0,1.0);
	}else if(out_of_range_mode==1){
		value = mod(value,1.0);
	}else if(out_of_range_mode==2){
		if(value<0.0||value>1.0){
			discard;
		}
	}
	if(textureSize(gradient,0).x<=4){
		COLOR.rgb = vec3(value);
	}else{
		COLOR = texture(gradient,vec2(clamp(value,0,1),0));
	}
}