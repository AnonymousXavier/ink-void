extends Node
class_name InputSystem

func update() -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1 or not entity_manager.active_entities.has(player_id):
		return
		
	var input_data: PlayerInputData = entity_manager.player_input_data
	
	if input_data:
		# Keyboard
		input_data.direction = Input.get_vector("left", "right", "up", "down")
		input_data.parry_pressed = Input.is_action_just_pressed("parry")
		input_data.dash_pressed = Input.is_action_just_pressed("dash")
		
		var viewport: Viewport = SceneInstances.viewport
		var screen_mouse_pos = viewport.get_mouse_position()
		var screen_center = viewport.get_visible_rect().size / 2.0
		var camera_pos = SceneInstances.camera.position
		var zoom = SceneInstances.camera.zoom
		var player_transform: TransformData = entity_manager.transform_components[player_id]
		
		# Translate screen pixel back into the ECS coordinate system
		input_data.aim_position = ((screen_mouse_pos - screen_center) / zoom) + camera_pos
		input_data.fire_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
		input_data.aim_direction = input_data.aim_position - player_transform.position
