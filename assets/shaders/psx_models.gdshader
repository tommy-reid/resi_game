shader_type spatial;
render_mode blend_mix,
	cull_back,
	depth_prepass_alpha,
	shadows_disabled,
	specular_disabled,
	vertex_lighting;

uniform sampler2D albedo_textrue: source_color, filter_nearest;
uniform vec2 texture_tile = vec2(1,1);


uniform bool snap_enabled = true;
uniform float snap_resolution : hint_range(60.0, 480.0, 1.0) = 148.0;

void vertex() {
	// Called for every vertex the material is visible on.
	vec4 view_space_pos = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	vec4 clip_space_pos = PROJECTION_MATRIX * view_space_pos;
	
	if(snap_enabled) {
		vec2 ndc = clip_space_pos.xy / clip_space_pos.w;
		ndc = round(ndc * snap_resolution) / snap_resolution;
		clip_space_pos.xy = ndc * clip_space_pos.w;
	}
	
	POSITION = clip_space_pos;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 albedo = texture(albedo_textrue, UV * texture_tile);
	ALBEDO = albedo.rgb;
	ALPHA = albedo.a;
}
