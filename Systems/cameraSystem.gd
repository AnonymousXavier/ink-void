extends Node
class_name Camera

var _top_left: Vector2 = Vector2.ZERO
var zoom: float = 0.5  # 1.0 is default, 2.0 is zoomed in, 0.5 is zoomed out
var speed: int = 400
var position:
	get:
		return get_center()
		
func get_center():
	var size = get_size()
	return _top_left + size / 2

# This calculates exactly how much of the game world the camera can see right now
func get_size() -> Vector2:
	var viewport_size = get_viewport().get_visible_rect().size
	return viewport_size / zoom

# This calculates the exact Top-Left and Bottom-Right corners of the camera in the world
func get_camera_rect() -> Rect2:
	return Rect2(_top_left, get_size())

func _process(delta: float) -> void:
	if Input.get_action_strength("left"):
		_top_left.x -= speed * delta
		
	elif Input.get_action_strength("right"):
		_top_left.x += speed * delta
		
	if Input.get_action_strength("down"):
		_top_left.y += speed * delta
		
	elif Input.get_action_strength("up"):
		_top_left.y -= speed * delta
