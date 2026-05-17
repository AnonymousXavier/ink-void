shader_type canvas_item;

// Match this EXACTLY to Constants.TILE_SIZE
uniform float cell_width = 64.0; 

// The ECS Data
uniform float camera_zoom = 1.0;
uniform vec2 camera_position = vec2(0.0, 0.0);
uniform vec2 screen_center = vec2(576.0, 324.0); 

uniform float border_size = 1.0;
uniform bool draw_border = true;

uniform vec4 background_color : source_color;
uniform vec4 border_color: source_color;
uniform float bloom_intensity = 1.0;

void fragment() {
    // Reverse-engineer the RenderingSystem math to find the true World Vector
    vec2 world_pos = ((FRAGCOORD.xy - screen_center) / camera_zoom) + camera_position;
    
    // Calculate the grid lines using the pure world vector
    float x_mod = mod(world_pos.x, cell_width);
    float y_mod = mod(world_pos.y, cell_width);
    
    // Keep the border thickness sharp regardless of zoom level
    float scaled_inc = (border_size / camera_zoom) / 2.0;
    
    if (x_mod < scaled_inc || x_mod > cell_width - scaled_inc || y_mod < scaled_inc || y_mod > cell_width - scaled_inc) {
        if (draw_border) {
            COLOR = border_color * bloom_intensity;
        } else {
            COLOR = background_color;
        }
    } else {
        COLOR = background_color;
    }
}