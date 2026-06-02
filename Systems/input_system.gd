extends Node
class_name InputSystem

var stick_was_reset: bool = true

func update() -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	if player_id == -1: return
	
	var input = entity_manager.player_input_data
	var p_transform = entity_manager.transform_components.get(player_id)
	if not input or not p_transform: return
	
	# 1. MOVEMENT & DASH (Works automatically for both)
	input.direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	input.dash_pressed = Input.is_action_just_pressed("dash")
	
	# 2. READ THE RIGHT STICK
	var aim_vector = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	
	# 3. THE SPLIT LOGIC
	if aim_vector.length() > 0.1:
		# --- CONTROLLER FLICK PARRY MODE ---
		input.aim_direction = aim_vector.normalized()
		
		# If the stick is pushed past 50% (The Flick)
		if aim_vector.length() > 0.5: 
			if stick_was_reset:
				input.parry_pressed = true
				stick_was_reset = false
			else:
				input.parry_pressed = false 
		else:
			# The stick is in the inner deadzone, ready for the next flick
			stick_was_reset = true
			input.parry_pressed = false
			
	else:
		# --- KEYBOARD & MOUSE MODE ---
		var mouse_pos = SceneInstances.viewport.get_mouse_position()
		input.aim_direction = (mouse_pos - p_transform.position).normalized()
		input.parry_pressed = Input.is_action_just_pressed("parry")
		stick_was_reset = true # Keep the stick reset in case they grab the controller again
