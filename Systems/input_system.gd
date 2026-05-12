extends Node
class_name InputSystem

func _physics_process(delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1 or not entity_manager.active_entities.has(player_id):
		return
		
	var input_data: PlayerInputData = entity_manager.player_input_data
	
	if input_data:
		# Keyboard
		input_data.direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		input_data.parry_pressed = Input.is_action_just_pressed("ui_accept")
		
		# Mouse (Replaces the old EventsManager push)
		input_data.aim_position = SceneInstances.rendering_system.get_global_mouse_position()
		input_data.fire_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
