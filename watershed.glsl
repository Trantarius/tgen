#[compute]
#version 450

// Instruct the GPU to use 8x8x1 = 64 local invocations per workgroup.
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(set=0, r32f, binding = 0) restrict readonly uniform image2D heightmap;
layout(set=0, r32f, binding = 1) restrict readonly uniform image2D flowmap_old;
layout(set=0, r32f, binding = 2) restrict writeonly uniform image2D flowmap_new;
layout(set=0, binding = 3, std430) buffer Config{
	float evaporation;
} config;

const ivec2 adjacent[4] = {
	ivec2(0,1),
	ivec2(1,0),
	ivec2(0,-1),
	ivec2(-1,0)
};
const int adjacent_size = 4;

float prop_flow(ivec2 coord, ivec2 dir){
	float height = imageLoad(heightmap,coord).r;
	ivec2 hmap_size = imageSize(heightmap);
	float total_down = 0.0;
	for(int i=0;i<adjacent_size;i++){
		ivec2 adj_coord = coord + adjacent[i];
		if(adj_coord.x<0 || adj_coord.x>=hmap_size.x || adj_coord.y<0 || adj_coord.y>=hmap_size.y){
			continue;
		}
		float adj_height = imageLoad(heightmap,adj_coord).r;
		if(adj_height<height){
			total_down += height-adj_height;
		}
	}
	ivec2 dir_coord = coord + dir;
	if(dir_coord.x<0 || dir_coord.x>=hmap_size.x || dir_coord.y<0 || dir_coord.y>=hmap_size.y){
		return 0.0;
	}
	float dir_height = imageLoad(heightmap,dir_coord).r;
	if(dir_height<height){
		return (height-dir_height)/total_down;
	}
	return 0.0;
}

void main(){
	ivec2 coord = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = imageSize(heightmap);
	float total_flow = 0.0;
	for(int i=0;i<adjacent_size;i++){
		ivec2 adj_coord = coord + adjacent[i];
		if(adj_coord.x<0 || adj_coord.x>=size.x || adj_coord.y<0 || adj_coord.y>=size.y){
			continue;
		}
		float adj_flow = imageLoad(flowmap_old,adj_coord).r+1.0;
		adj_flow *= prop_flow(adj_coord, -adjacent[i]);
		total_flow += adj_flow;
	}
	total_flow = max(0.0, total_flow-config.evaporation);
	imageStore(flowmap_new, coord, vec4(total_flow));
}