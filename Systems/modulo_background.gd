extends ColorRect

var shader_material: ShaderMaterial

func _ready() -> void:
	shader_material = material
	shader_material.set_shader_parameter("screen_center", get_viewport_rect().get_center())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	shader_material.set_shader_parameter("camera_position", SceneInstances.camera.position)
	shader_material.set_shader_parameter("zoom", SceneInstances.camera.zoom)
	
