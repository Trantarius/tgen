shader_type canvas_item;
uniform sampler2D screen: hint_screen_texture;
uniform sampler2D heightmap;
void vertex() {
	// Called for every vertex the material is visible on.
}

const float WEIGHT = 0.01;

const ivec2 adj[4]={ivec2(0,1),ivec2(0,-1),ivec2(1,0),ivec2(-1,0)};
const int adj_c = 4;

float prop_dist(ivec2 coord, ivec2 dir){
	float ht = texelFetch(heightmap,coord,0).r;
	float down_tot = 0.0;
	for(int a=0;a<adj_c;a++){
		float a_ht = texelFetch(heightmap,coord+adj[a],0).r;
		if(a_ht<ht){
			down_tot += ht-a_ht;
		}
	}
	float a_ht = texelFetch(heightmap,coord+dir,0).r;
	if(a_ht<ht){
		return (ht-a_ht)/down_tot;
	}else{
		return 0.0;
	}
}

void move(inout float down, inout float up, float ht, ivec2 dir, ivec2 coord){
	float a_ht = texelFetch(heightmap,coord+dir,0).r;
	if(a_ht>ht){
		float prop = prop_dist(coord+dir,-dir);
		down += texelFetch(screen, coord+dir,0).r*prop/1.0;
	}else{

	}
}

void fragment() {
	ivec2 coord = ivec2(FRAGCOORD.xy);
	float down = WEIGHT;
	float up = WEIGHT;
	float ht = texelFetch(heightmap,coord,0).r;

	move(down,up,ht,ivec2(0,1),coord);
	move(down,up,ht,ivec2(0,-1),coord);
	move(down,up,ht,ivec2(1,0),coord);
	move(down,up,ht,ivec2(-1,0),coord);

	COLOR.r = min(1.0,down);
	COLOR.g = WEIGHT;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
