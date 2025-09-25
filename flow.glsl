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
	// linear add to water per time
	float precipitation;
	// portional removal of water per time
	float evaporation;
	// parameters determining how much sediment can be held (ie, max_sediment = static * water_amount + kinetic * water_flow_rate)
	float static_sediment_capacity;
	float kinetic_sediment_capacity;
	// how rapidly land is turned into sediment (proportion per time) (when sediment < capacity)
	float erosion_rate;
	// how rapidly sediment is turned into land (proportion per time) (when sediment > capacity)
	float deposition_rate;
	// max slope before gravitational erosion occurs
	float slope_of_repose;
	// multiplier of gravitational erosion
	float gravity_rate;
	// multiplier for all effects
	float sim_rate;
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

float flow_pressure(vec4 cell_a, vec4 cell_b){
	float alt_a = cell_a.x+cell_a.y+cell_a.z;
	float alt_b = cell_b.x+cell_b.y+cell_b.z;
	if(alt_a<alt_b){
		return 0.0;
	}
	float fluid_a = cell_a.y+cell_a.z;
	float fluid_b = cell_b.y+cell_b.z;
	float top_fluid = min(fluid_a, alt_a-alt_b);
	float fluid_interface = max(alt_b-max(cell_a.x,cell_b.x),0);
	return top_fluid/2.0 + top_fluid*fluid_interface;
}

//does NOT consider if the returned amount is actually available to flow
float get_total_flow_out(ivec2 coord){
	vec4 cell = get_cell(coord);
	ivec2 map_size = imageSize(terrain_old);
	float total_flow_out = 0.0;
	for(int i=0;i<adjacent_size;i++){
		ivec2 adj_coord = coord + adjacent[i];
		if(adj_coord.x<0 || adj_coord.x>=map_size.x || adj_coord.y<0 || adj_coord.y>=map_size.y){
			continue;
		}
		vec4 adj_cell = get_cell(adj_coord);
		total_flow_out += flow_pressure(cell, adj_cell) / length(vec2(adjacent[i]));
	}
	total_flow_out *= config.sim_rate;
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

	float total_flow_out = get_total_flow_out(coord);

	float fluid_flow = flow_pressure(cell, dir_cell)*config.sim_rate / length(vec2(dir));
	if(total_flow_out > cell.y+cell.z){
		float part = fluid_flow/total_flow_out;
		fluid_flow = part*(cell.y+cell.z);
	}
	if(fluid_flow<=0.0){
		return vec2(0.0,0.0);
	}
	return fluid_flow * cell.yz / (cell.y+cell.z);
}

float gravity_erode(ivec2 coord){
	vec4 cell = get_cell(coord);
	ivec2 map_size = imageSize(terrain_old);

	float total_delta = 0.0;
	for(int i=0;i<adjacent_size;i++){
		ivec2 adj_coord = coord + adjacent[i];
		if(adj_coord.x<0 || adj_coord.x>=map_size.x || adj_coord.y<0 || adj_coord.y>=map_size.y){
			continue;
		}
		vec4 adj_cell = get_cell(adj_coord);
		float slope = (adj_cell.x-cell.x)/length(vec2(adjacent[i]));
		if(abs(slope)*float(map_size.x)>config.slope_of_repose){
			total_delta += slope;
		}
	}
	total_delta *= config.sim_rate*config.gravity_rate;
	return total_delta;
}

void main(){
	ivec2 coord = ivec2(gl_GlobalInvocationID.xy);
	ivec2 map_size = imageSize(terrain_old);
	vec4 cell = get_cell(coord);
	
	float total_flow_out = get_total_flow_out(coord);
	total_flow_out = min(total_flow_out, cell.y+cell.z);
	vec2 flow_out;
	if(total_flow_out<=0.0){
		flow_out = vec2(0.0);
	}else{
		flow_out = total_flow_out * cell.yz / (cell.y+cell.z);
	}

	vec2 flow_in = vec2(0.0);
	for(int i=0;i<adjacent_size;i++){
		ivec2 adj_coord = coord + adjacent[i];
		if(adj_coord.x<0 || adj_coord.x>=map_size.x || adj_coord.y<0 || adj_coord.y>=map_size.y){
			continue;
		}
		flow_in += get_flow(adj_coord, -adjacent[i]);
	}

	cell.yz += flow_in - flow_out;
	float evap = config.evaporation*config.sim_rate*cell.y;
	cell.y -= evap;

	float current_capacity = cell.y * config.static_sediment_capacity + (flow_in.x + flow_out.x)/2.0 * config.kinetic_sediment_capacity;
	float sediment_delta = current_capacity - cell.z;
	if(sediment_delta>0){
		sediment_delta *= config.erosion_rate * config.sim_rate;
	}else{
		sediment_delta *= config.deposition_rate * config.sim_rate;
	}
	cell.z += sediment_delta;
	cell.x -= sediment_delta;
	
	cell.x += gravity_erode(coord);

	imageStore(terrain_new, coord, cell);
}