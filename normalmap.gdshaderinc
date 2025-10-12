

void normal_map(inout vec3 tangent, inout vec3 binormal, inout vec3 normal, in vec3 nmap){
	vec3 tspace = nmap*2.0-1.0;
	normal = normalize(tspace.x*tangent + tspace.y * binormal + tspace.z * normal);
	tangent = normalize(cross(normal,binormal));
	binormal = cross(normal, tangent);
}