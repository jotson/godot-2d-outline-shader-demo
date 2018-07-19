extends Sprite

onready var plane = $"../plane"

func _ready():
    # Make each cloud shader a unique instance
    material = material.duplicate()


func _process(delta):
    # Get plane texture
    var plane_tex = plane.texture
    
    # Get plane position relative to cloud
    var plane_position = plane.position - position
    # ...and adjust it based on cloud rotation
    plane_position = plane_position.rotated(-rotation)
    # ...then adjust it based on the texture centers and scaling
    plane_position += texture.get_size()/2 * scale - plane_tex.get_size()/2 * plane.scale
    
    # Get plane rotation relative to cloud
    var plane_rotation = plane.rotation - rotation
    
    # Get scale
    var cloud_scale = scale
    var plane_scale = plane.scale
    
    # Set shader parameters
    material.set_shader_param('plane_position', plane_position)
    material.set_shader_param('plane_rotation', plane_rotation)
    material.set_shader_param('plane_texture', plane_tex)
    material.set_shader_param('cloud_scale', cloud_scale)
    material.set_shader_param('plane_scale', plane_scale)
    material.set_shader_param('outline_color', Color(1,0,0,0)) # red (alpha is ignored)
    material.set_shader_param('outline', true) # outline only; set to false to fill
    
    