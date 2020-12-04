shader_type canvas_item;

uniform float width : hint_range(0.0, 0.5); 
uniform float movement : hint_range(0.0, 1.0);
uniform float extra : hint_range(0.0, 1.0);



void fragment(){
	float eps = 0.04;
	
	vec2 mid_uv = UV - vec2(0.5, 0.5);
	float len = length(mid_uv);
	float alpha = smoothstep(0.5, 0.5 - eps, len) - smoothstep(width, width-eps, len);
	
	float ang1 = atan(-mid_uv.x, mid_uv.y) + 3.141592653589793;
	float movement_l = movement * 3.141592653589793*2.;
	alpha *= 0.1 + extra + smoothstep(movement_l, movement_l + eps, ang1);
	
	COLOR.a = alpha;
}