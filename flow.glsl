#[compute]
#version 450

// Instruct the GPU to use 8x8x1 = 64 local invocations per workgroup.
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

//r=land, g=water, b=sediment
layout(set=0, rgba32f, binding = 0) restrict readonly uniform image2D terrain_old;
layout(set=0, rgba32f, binding = 1) restrict writeonly uniform image2D terrain_new;

// amount of fluid that moved in AND out of each cell;
// x=water, y=sediment
//layout(set=0, rg32f, binding = 2) restrict writeonly uniform image2D flowmap;

layout(set=0, binding = 2, std430) buffer Config{
	// linear add to water per time (before flow)
	float precipitation;
	// linear removal of water per time (after flow)
	float evaporation;
	// minimum water amount for full evaporation (ie, if water_amount < threshold, evaporation is reduced proportionally)
	float evaporation_threshold;
	// parameters determining how much sediment can be held (ie, max_sediment = capacity * water_flow_rate)
	float sediment_capacity;
	// how quickly sediment diffuses through water
	//float sediment_diffusion;
	// how rapidly land is turned into sediment or vice versa (proportion per time)
	float erosion_rate;
	// max slope before gravitational erosion occurs
	float slope_of_repose;
	// multiplier of gravitational erosion
	float gravity_rate;
	// multiplier for all effects
	float sim_rate;
	//size of the map (on x axis)
	float map_scale;
} config;

const ivec2 adjacent[8] = {
	ivec2(0,1),
	ivec2(1,0),
	ivec2(0,-1),
	ivec2(-1,0),
	ivec2(1,1),
	ivec2(1,-1),
	ivec2(-1,1),
	ivec2(-1,-1)
};
const int adjacent_size = 8;

vec4 get_cell(ivec2 coord){
	return imageLoad(terrain_old, coord)+vec4(0,config.precipitation*config.sim_rate,0,0);
}

float flowrate_a_to_b(vec4 cell_a, vec4 cell_b){
	float alt_a = cell_a.x+cell_a.y+cell_a.z;
	float alt_b = cell_b.x+cell_b.y+cell_b.z;
	float top_fluid = max(min(cell_a.y+cell_a.z, (alt_a-alt_b)/2.0), -(cell_b.y+cell_b.z));

	return top_fluid/6.82; //6.82 = 4 + 4/sqrt(2) (ie, sum of length of adjacent vectors)
}

//does NOT consider if the returned amount is actually available to flow
float flowrate_out(ivec2 coord){
	vec4 cell = get_cell(coord);
	ivec2 map_size = imageSize(terrain_old);
	float total_flow_out = 0.0;
	for(int i=0;i<adjacent_size;i++){
		ivec2 adj_coord = coord + adjacent[i];
		if(adj_coord.x<0 || adj_coord.x>=map_size.x || adj_coord.y<0 || adj_coord.y>=map_size.y){
			continue;
		}
		vec4 adj_cell = get_cell(adj_coord);
		total_flow_out += flowrate_a_to_b(cell, adj_cell) / length(vec2(adjacent[i]));
	}
	return total_flow_out;
}


//x=water flow, y=sediment flow
vec2 get_flow(ivec2 coord, ivec2 dir){
	vec4 cell = get_cell(coord);
	ivec2 map_size = imageSize(terrain_old);

	ivec2 dir_coord = coord + dir;
	if(dir_coord.x<0 || dir_coord.x>=map_size.x || dir_coord.y<0 || dir_coord.y>=map_size.y){
		return vec2(0.0,0.0);
	}
	vec4 dir_cell = get_cell(dir_coord);

	float fluid_flow = flowrate_a_to_b(cell, dir_cell) / length(vec2(dir));
	if(fluid_flow<=0.0){
		return vec2(0.0,0.0);
	}
	float total_flow_out = flowrate_out(coord);

	if(total_flow_out > cell.y+cell.z){
		float part = fluid_flow/total_flow_out;
		fluid_flow = part*(cell.y+cell.z);
	}
	return fluid_flow * cell.yz / (cell.y+cell.z);
}

float gravity_erode(ivec2 coord){
	vec4 cell = get_cell(coord);
	ivec2 map_size = imageSize(terrain_old);
	float repose = config.slope_of_repose * (cell.w + 0.5);
	float slope_repose_px = repose * config.map_scale / float(map_size.x);

	float total_delta = 0.0;
	for(int i=0;i<adjacent_size;i++){
		ivec2 adj_coord = coord + adjacent[i];
		if(adj_coord.x<0 || adj_coord.x>=map_size.x || adj_coord.y<0 || adj_coord.y>=map_size.y){
			continue;
		}
		vec4 adj_cell = get_cell(adj_coord);
		float slope_px = (adj_cell.x-cell.x)/length(vec2(adjacent[i]));
		float slope = slope_px * float(map_size.x) / config.map_scale;
		if(abs(slope)>repose){
			total_delta += slope_px - sign(slope_px)*slope_repose_px;
		}
	}
	total_delta *= config.sim_rate*config.gravity_rate;
	return total_delta;
}

void main(){
	ivec2 coord = ivec2(gl_GlobalInvocationID.xy);
	ivec2 map_size = imageSize(terrain_old);
	vec4 cell = get_cell(coord);

	if(false &&(coord.x==0 || coord.y==0 || coord.x>=map_size.x-1 || coord.y>=map_size.y-1)){
		cell.y = 0.0;
		cell.z = 0.0;
	}
	else{

		vec2 flow_in= vec2(0.0);
		vec2 flow_out= vec2(0.0);
		for(int i=0;i<adjacent_size;i++){
			ivec2 adj_coord = coord + adjacent[i];
			if(adj_coord.x<0 || adj_coord.x>=map_size.x || adj_coord.y<0 || adj_coord.y>=map_size.y){
				continue;
			}
			vec4 adj_cell = get_cell(adj_coord);
			float rate = flowrate_a_to_b(adj_cell, cell) / length(vec2(adjacent[i]));
			if(rate<=0.0){
				flow_out += -rate * cell.yz / (cell.y+cell.z);
			}else{
				flow_in += rate * adj_cell.yz / (adj_cell.y+adj_cell.z);
			}
		}

		cell.yz += flow_in - flow_out;
		if(cell.y>0.0){
			float evap = config.evaporation*config.sim_rate;
			if(cell.y<config.evaporation_threshold){
				evap *= cell.y/config.evaporation_threshold;
			}
			cell.y = max(0.0,cell.y-evap);
		}

		//float erode = (flow_in.x + flow_out.x) * config.erosion_rate * config.sim_rate;
		//erode *= cell.w*cell.w*cell.w;
		//cell.x -= erode;
		//cell.z += erode;
		//float current_capacity = cell.y * config.sediment_capacity;
		//float deposit = max(0.0, cell.z - current_capacity) * config.erosion_rate * config.sim_rate;
		//cell.x += deposit;
		//cell.z -= deposit;
		

		float current_capacity = (flow_in.x + flow_out.x) * config.sediment_capacity;
		float sediment_delta = (current_capacity - cell.z) * config.sim_rate * config.erosion_rate;
		//if(sediment_delta>0.0){
			sediment_delta *= cell.w * cell.w * cell.w;
		//}
		
		cell.z += sediment_delta;
		cell.x -= sediment_delta;
		
	}
	
	cell.x += gravity_erode(coord);

	imageStore(terrain_new, coord, cell);
}