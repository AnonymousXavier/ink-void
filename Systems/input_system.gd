extends Node
class_name InputSystem

func update() -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	if player_id == -1: return
	
	var input = entity_manager.player_input_data
	var p_transform = entity_manager.transform_components.get(player_id)
	if not input or not p_transform: return
	
	# 1. RAW INPUT ACTIONS (Brawl Stars Style)
	# The physical/virtual buttons are the ONLY things that trigger these now.
	input.direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	input.dash_pressed = Input.is_action_just_pressed("dash")
	input.parry_pressed = Input.is_action_just_pressed("parry")
	
	# 2. READ THE RIGHT STICK (Aiming Only)
	var aim_vector = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	
	# 3. SMART AIM MEMORY
	if aim_vector.length() > 0.05:
		# If the player is actively dragging the stick, update the aim vector.
		input.aim_direction = aim_vector.normalized()
		
	elif not OS.has_feature("mobile"):
		# IF ON PC: Fallback to the mouse cursor position.
		var mouse_pos = SceneInstances.viewport.get_mouse_position()
		input.aim_direction = (mouse_pos - p_transform.position).normalized()
		
	# IF ON MOBILE: Notice there is no "else" block.
	# If you let go of the right stick to press the UI Parry button, 
	# the ECS simply remembers your last `input.aim_direction` and holds it perfectly steady!
