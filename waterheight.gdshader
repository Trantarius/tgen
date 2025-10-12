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

float shore_dist_dir(vec2 uv, vec2 dir, float q_dist){
	const float lq_off = 0.001;
	float ldir = length(dir);
	float step_size = 100.0;
	vec4 t = texture(height_texture,uv);
	float lq = t.y+t.z-lq_off;
	if(lq<0.0)
		return 0.0;
	float lq_n = lq;
	vec2 uv_n = uv;
	float dist = 0.0;
	float dist_n = dist;
	
	for(int j=0;j<100;j++){
		float jmp = step_size * lq;
		if(uv.x<0.0 || uv.y<0.0 || uv.x>1.0 || uv.y>1.0)
			break;
		uv_n = uv+dir*jmp;
		t = texture(height_texture, uv_n);
		lq_n = t.y+t.z-lq_off;
		dist_n = dist + jmp;
		if(lq_n<0.0){
			break;
		}else{
			lq = lq_n;
			uv = uv_n;
			dist = dist_n;
			if(dist>q_dist)
				return q_dist;
		}
	}
	
	for(int i=0;i<20;i++){
		step_size/=2.0;
		float jmp = step_size * lq;
		if(uv.x<0.0 || uv.y<0.0 || uv.x>1.0 || uv.y>1.0)
			continue;
		uv_n = uv+dir*jmp;
		t = texture(height_texture, uv_n);
		lq_n = t.y+t.z-lq_off;
		dist_n = dist + jmp;
		if(lq_n<0.0){
			continue;
		}else{
			lq = lq_n;
			uv = uv_n;
			dist = dist_n;
			if(dist>q_dist)
				return q_dist;
		}
	}
	return dist;
}

float get_shore_dist(vec2 uv, int dirc){
	vec2 texture_pixel_size = 1.0/vec2(textureSize(height_texture,0));
	float dist = 100.0;
	for(int d=0;d<dirc;d++){
		float theta = float(d)*TAU/float(dirc);
		vec2 dir = vec2(sin(theta),cos(theta))*texture_pixel_size;
		float dd = shore_dist_dir(uv,dir,dist);
		dist = min(dist,dd);
	}
	return dist;
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