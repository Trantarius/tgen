#[compute]
#version 450

// Instruct the GPU to use 8x8x1 = 64 local invocations per workgroup.
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(set=0, r32f, binding = 0) restrict uniform image2D heightmap;
layout(set=0, rg32f, binding = 1) restrict uniform image2D flowmap;
layout(set=0, binding = 2, std430) buffer Config{
	float erosion;
	float rate;
} config;



void main(){
	ivec2 coord = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = imageSize(heightmap);
	vec2 flow = imageLoad(flowmap, coord).xy;
	float delta = flow.y/10.0 - flow.x;
	delta *= config.rate;
	float height = imageLoad(heightmap,coord).r;
	height += delta;
	imageStore(heightmap, coord, vec4(height));
	//imageStore(flowmap, coord, vec4(flow.x, flow.y - delta,0,1));
}