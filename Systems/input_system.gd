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
	
	# 1. READ BASE MOVEMENT
	input.direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	input.dash_pressed = Input.is_action_just_pressed("dash")
	
	# 2. READ BASE BUTTON PARRY (X Button, Shift, or Mobile Touch Button)
	# We set this first. We will NEVER force it to false later in the script!
	input.parry_pressed = Input.is_action_just_pressed("parry")
	
	# 3. READ THE RIGHT STICK
	var aim_vector = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	
	# 4. HYBRID AIMING & FLICK PARRY
	if aim_vector.length() > 0.05:
		input.aim_direction = aim_vector.normalized()
		
		# --- FLICK TO PARRY LOGIC ---
		if aim_vector.length() > 0.5: 
			if stick_was_reset:
				input.parry_pressed = true # ADDITIVE: Only turn it true, never force it false!
				stick_was_reset = false
		else:
			# Stick is resting in the inner deadzone
			stick_was_reset = true
			
	elif not OS.has_feature("mobile"):
		# IF ON PC & NO STICK INPUT: Fallback to mouse aiming
		var mouse_pos = SceneInstances.viewport.get_mouse_position()
		input.aim_direction = (mouse_pos - p_transform.position).normalized()
		stick_was_reset = true
		
	else:
		# IF ON MOBILE & NO STICK INPUT: Retain previous aim direction and reset stick memory
		stick_was_reset = true
