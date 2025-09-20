shader_type canvas_item;

uniform sampler2D screen: hint_screen_texture;
uniform sampler2D watershed;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ivec2 coord = ivec2(FRAGCOORD.xy);
	float ht = texelFetch(screen,coord,0).r;
	float wsh = texelFetch(watershed,coord,0).r;
	float wt = texelFetch(watershed,coord,0).g;
	COLOR.rgb = vec3(ht+(wsh-wt)*0.001);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
