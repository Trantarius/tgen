#[compute]
#version 450

const float PI  = 3.1415926535897932384626433832795028841971;
const float TAU = 6.2831853071795864769252867665590057683943;

uint randui(inout uint s){
    s *= 1337597;
    s ^= s>>13;
    s *= 110331;
    s ^= s>>7;
    s *= 6023025;
    s ^= s>>23;
    return s;
}

float randf(inout uint seed){
    return float(randui(seed)%1000000)/500000.0 - 1.0;
}

float randuf(inout uint seed){
    return float(randui(seed)%1000000)/1000000.0;
}

vec2 randn2(inout uint seed){
    float u = randuf(seed);
    float v = randuf(seed);
    if(u==0.0){
      return vec2(0.0, 0.0);
    }
    return vec2(sqrt(-2.0*log(u))*cos(TAU*v), sqrt(-2.0*log(u))*sin(TAU*v));
}

float randn(inout uint seed){
    return randn2(seed).x;
}

vec3 randn3(inout uint seed){
    return vec3(randn2(seed), randn(seed));
}

vec4 randn4(inout uint seed){
    return vec4(randn2(seed), randn2(seed));
}

vec2 randv2(inout uint seed){
    float theta = randuf(seed)*TAU;
    float len = sqrt(randuf(seed));
    return vec2(cos(theta)*len, sin(theta)*len);
}

vec3 randv3(inout uint seed){
    vec3 p = randn3(seed);
    float olen = length(p);
    float len = pow(randuf(seed),1.0/3.0);
    if(olen==0.0){
      return vec3(0.0, 0.0, 0.0);
    }
    return p * len/olen;
}

vec4 randv4(inout uint seed){
    vec4 p = randn4(seed);
    float olen = length(p);
    float len = sqrt(sqrt(randuf(seed)));
    if(olen==0.0){
      return vec4(0.0, 0.0, 0.0, 0.0);
    }
    return p * len/olen;
}

uint randc(int c, uint seed){
    seed = (c*1313+19)*seed;
    return randui(seed);
}

uint randc2(ivec2 c, uint seed){
    seed = (c.x*1313+19)*(c.y*1919+29)*seed;
    return randui(seed);
}

uint randc3(ivec3 c, uint seed){
    seed = (c.x*1313+19)*(c.y*1919+29)*(c.z*2929+37)*seed;
    return randui(seed);
}

uint randc4(ivec4 c, uint seed){
    seed = (c.x*1313+19)*(c.y*1919+29)*(c.z*2929+37)*(c.w*3737+13)*seed;
    return randui(seed);
}

float perlin1(float pos, uint seed){
    int c0 = int(floor(pos));
    int c1 = c0+1;
    uint s0 = randc(c0, seed);
    uint s1 = randc(c1, seed);
    float w0 = pos-c0;
    float w1 = w0-1.0;
    float g0 = randf(s0);
    float g1 = randf(s1);
    float p0 = g0*w0;
    float p1 = g1*w1;
    return mix(p0, p1, smoothstep(0.0, 1.0, w0));
}

float perlin2(vec2 pos, uint seed){
    ivec2 cp = ivec2(floor(pos));
    vec2 wp = pos-floor(pos);
    float p[4];
    for(int i=0;i<4;i++){
        ivec2 c = ivec2(
            (i>>1)&1,
            i&1
        )+cp;
        uint s = randc2(c, seed);
        vec2 w = pos-vec2(c);
        vec2 g = randv2(s);
        p[i] = dot(g,w);
    }
    for(int i=0;i<2;i++){
        p[i] = mix(p[i], p[i+2], smoothstep(0.0, 1.0, wp.x));
    }
    p[0] = mix(p[0], p[1], smoothstep(0.0, 1.0, wp.y));
    return p[0];
}

float perlin3(vec3 pos, uint seed){
    ivec3 cp = ivec3(floor(pos));
    vec3 wp = pos-floor(pos);
    float p[8];
    for(int i=0;i<8;i++){
        ivec3 c = ivec3(
            (i>>2)&1,
            (i>>1)&1,
            i&1
        )+cp;
        uint s = randc3(c, seed);
        vec3 w = pos-vec3(c);
        vec3 g = randv3(s);
        p[i] = dot(g,w);
    }
    for(int i=0;i<4;i++){
        p[i] = mix(p[i], p[i+4], smoothstep(0.0, 1.0, wp.x));
    }
    for(int i=0;i<2;i++){
        p[i] = mix(p[i], p[i+2], smoothstep(0.0, 1.0, wp.y));
    }
    p[0] = mix(p[0], p[1], smoothstep(0.0, 1.0, wp.z));
    return p[0];
}

float perlin4(vec4 pos, uint seed){
    ivec4 cp = ivec4(floor(pos));
    vec4 wp = pos-floor(pos);
    float p[16];
    for(int i=0;i<16;i++){
        ivec4 c = ivec4(
            (i>>3)&1,
            (i>>2)&1,
            (i>>1)&1,
            i&1
        )+cp;
        uint s = randc4(c, seed);
        vec4 w = pos-vec4(c);
        vec4 g = randv4(s);
        p[i] = dot(g,w);
    }
    for(int i=0;i<8;i++){
        p[i] = mix(p[i], p[i+8], smoothstep(0.0, 1.0, wp.x));
    }
    for(int i=0;i<4;i++){
        p[i] = mix(p[i], p[i+4], smoothstep(0.0, 1.0, wp.y));
    }
    for(int i=0;i<2;i++){
        p[i] = mix(p[i], p[i+2], smoothstep(0.0, 1.0, wp.z));
    }
    p[0] = mix(p[0], p[1], smoothstep(0.0, 1.0, wp.w));
    return p[0];
}

float perlin2_imp(vec2 pos, uint seed){
    vec3 pos3 = vec3(pos.x, pos.y, sqrt(3.0)/2.0);
    const vec3 z = normalize(vec3(1.0,1.0,1.0));
    const vec3 y = normalize(cross(vec3(1.0,0.5f,0.25f),z));
    const vec3 x = normalize(cross(z,y));
    pos3 = x*pos3.x + y*pos3.y + z*pos3.z;

    float p = perlin3(pos3, seed);
    return p;
}

const ivec2 adjacent[4] = {
    ivec2(0,1),
    ivec2(1,0),
    ivec2(0,-1),
    ivec2(-1,0)
};
const int adjacent_size = 4;


// Instruct the GPU to use 8x8x1 = 64 local invocations per workgroup.
layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;



// Prepare memory for the image, which will be both read and written to
// `restrict` is used to tell the compiler that the memory will only be accessed
// by the `heightmap` variable.
layout(set=0, rgba32f, binding = 0) restrict writeonly uniform image2D heightmap;

layout(set=0, binding = 1, std430) buffer Config{
	uint seed;
	int detail;
	float scale;
} config;

// This function is the GPU counterpart of `compute_island_cpu()` in `main.gd`.
void main() {
	// Grab the current pixel's position from the ID of this specific invocation ("thread").
	ivec2 coord = ivec2(gl_GlobalInvocationID.xy);
	ivec2 size = imageSize(heightmap);
	vec2 uv = vec2(coord)/vec2(size);
	uv *= config.scale;
	float att = 1.0;
	float nse = 0.0;
	float tot = 0.0;
	uint sd = config.seed;

	for(int oct=0;oct<config.detail;oct++){
		nse += perlin2_imp(uv,randui(sd))/att;
		tot += 1.0/att;
		uv*=2.0;
		att*=2.0;
	}
	//nse /= tot;
	nse = (nse+1.0)/2.0;
	imageStore(heightmap, coord, vec4(nse,0,0,1));
}