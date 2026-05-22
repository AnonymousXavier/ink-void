extends Node
class_name Camera

var offset: Vector2 = Vector2.ZERO # For Screen Shake

var _top_left: Vector2 = Vector2.ZERO:
	get():
		return position - get_size() / 2
		
var zoom: float = 1
var speed: int = 400
var position: Vector2 # Camera's Center

# This calculates exactly how much of the game world the camera can see right now
func get_size() -> Vector2:
	var viewport_size = SceneInstances.viewport.get_visible_rect().size
	return viewport_size / zoom

# This calculates the exact Top-Left and Bottom-Right corners of the camera in the world
func get_camera_rect() -> Rect2:
	return Rect2(_top_left, get_size())

func update() -> void:
	if SceneInstances.entity_manager.player_id != -1:
		var player_trasnform_data = SceneInstances.entity_manager.transform_components[SceneInstances.entity_manager.player_id]
		# Apply the chaos on top of the strict player lock
		position = player_trasnform_data.position + offset
