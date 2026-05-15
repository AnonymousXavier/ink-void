extends Node
class_name DashSystem

func update(delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1: return
	
	var dash = entity_manager.dash_components.get(player_id)
	var input = entity_manager.player_input_data
	var velocity = entity_manager.velocity_components.get(player_id)
	var parry = entity_manager.parry_components.get(player_id)
	
	if not dash or not input or not velocity or not parry: return
	
	# Process the Cooldown
	if dash.cooldown_time_left > 0:
		dash.cooldown_time_left -= delta
		
	# Process an Active Dash
	if dash.is_dashing:
		dash.dash_time_left -= delta
		if dash.dash_time_left <= 0:
			# Dash finished! Return to normal physics
			dash.is_dashing = false
			velocity.speed = 400.0 
		else:
			# Lock the speed and direction while dashing
			velocity.speed = dash.dash_speed
			velocity.direction = dash.dash_direction
		return # Skip the trigger check below
		
	# Start Dash
	if input.dash_pressed and dash.cooldown_time_left <= 0 and parry.current_state != ParryData.State.FROZEN_AIMING:
		dash.is_dashing = true
		dash.dash_time_left = dash.dash_duration
		dash.cooldown_time_left = dash.cooldown
		
		# Lock in the current movement direction. If standing still, dash towards the mouse!
		if input.direction != Vector2.ZERO:
			dash.dash_direction = input.direction.normalized()
		else:
			var player_pos = entity_manager.transform_components[player_id].position
			dash.dash_direction = player_pos.direction_to(input.aim_position)
		
		velocity.speed = dash.dash_speed
		velocity.direction = dash.dash_direction
		
		SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.SCREEN_SHAKE, "amount": 0.4})
