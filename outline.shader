shader_type canvas_item;

uniform sampler2D plane_texture;
uniform vec2 plane_position = vec2(0.0, 0.0);
uniform float plane_rotation = 0.0;
uniform bool outline = false;
uniform vec4 outline_color : hint_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec2 cloud_scale = vec2(1.0, 1.0);
uniform vec2 plane_scale = vec2(1.0, 1.0);

// Code adapted from:
// https://www.reddit.com/r/godot/comments/8orw5a/q_how_to_draw_a_sprite_on_another_sprite_in_2d/e068tc7/
// https://godotengine.org/qa/15209/add-glow-to-sprite-that-is-behind-another-sprite?show=15260#a15260
// https://gamedev.stackexchange.com/questions/98723/texture-rotation-inside-a-quad/98726#98726
void fragment() {
    vec2 scaling_ratio = vec2(textureSize(TEXTURE, 0)) / vec2(textureSize(plane_texture, 0));
    mat2 plane_rotationation_matrix = mat2(vec2(cos(plane_rotation), sin(plane_rotation)), vec2(-sin(plane_rotation), cos(plane_rotation)));
    vec2 plane_uv = UV * scaling_ratio * cloud_scale - plane_position/vec2(textureSize(plane_texture, 0));
    
    // Rotate plane_uv
    plane_uv /= plane_scale;
    plane_uv = plane_uv - vec2(0.5, 0.5);
    plane_uv = plane_uv * plane_rotationation_matrix;
    plane_uv = plane_uv + vec2(0.5, 0.5);
    
    // Get a texture for the plane and set it to color
    vec4 plane_color = texture(plane_texture, plane_uv);
    plane_color.rgb = outline_color.rgb;
    
    // Subtract alpha from interior of texture to make an outline
    if (outline) {
        float outline_thickness = 1.0;
        float x_thickness = TEXTURE_PIXEL_SIZE.x * outline_thickness * scaling_ratio.x / plane_scale.x;
        float y_thickness = TEXTURE_PIXEL_SIZE.y * outline_thickness * scaling_ratio.y / plane_scale.y;
        plane_color.a = 4.0 * plane_color.a;
        plane_color.a -= texture(plane_texture, plane_uv + vec2(x_thickness, 0.0)).a;
        plane_color.a -= texture(plane_texture, plane_uv + vec2(-x_thickness, 0.0)).a;
        plane_color.a -= texture(plane_texture, plane_uv + vec2(0.0, y_thickness)).a;
        plane_color.a -= texture(plane_texture, plane_uv + vec2(0.0, -y_thickness)).a;
    }
    
    // Get the cloud color
    vec4 color = texture(TEXTURE, UV);
    
    // Mix the cloud and plane textures
    if (plane_uv.x >= 0.0 && plane_uv.x <= 1.0 && plane_uv.y >= 0.0 && plane_uv.y <= 1.0) {
        COLOR = vec4(mix(color.rgb, plane_color.rgb, plane_color.a), color.a);
    } else {
        COLOR = color;
    }
}