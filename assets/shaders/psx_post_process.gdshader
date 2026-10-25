shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_nearest;

const float psx_dither[16] = float[16](
	-4.0, 0.0, -3.0, 1.0,
	2.0, -2.0, 3.0, -1.0,
	-3.0, 1.0, -4.0, 0.0,
	3.0, -1.0, 2.0, -2.0
);

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 screen_colour = texture(screen_texture, UV).rgb;
	
	int x = int(FRAGCOORD.x) % 4;
	int y = int(FRAGCOORD.y) % 4;
	int index = y * 4 * x;
	
	float dither_offest = (psx_dither[index] / 8.0);
	
	vec3 quantized_colour = floor((screen_colour * 255.0) / 8.0 + dither_offest) / 31.0;
	
	COLOR = vec4(quantized_colour, 1);
}