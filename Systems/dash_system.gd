extends Node
class_name DashSystem

func update(delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1: return
	
	var dash = entity_manager.dash_components.get(player_id)
	var input = entity_manager.player_input_data
	var parry = entity_manager.parry_components.get(player_id)
	
	if not dash or not input or not parry: return
	
	# Process the Cooldown
	if dash.cooldown_time_left > 0:
		dash.cooldown_time_left -= delta
		
	# Process an Active Speedster State
	if dash.is_dashing:
		dash.dash_time_left -= delta # Uses real-time delta!
		
		if dash.dash_time_left <= 0:
			SceneInstances.time_scale = 1.0 
			dash.is_dashing = false
		return 
		
	# Start Speedster Mode
	if input.dash_pressed and dash.cooldown_time_left <= 0 and parry.current_state != ParryData.State.PARRYING:
		dash.is_dashing = true
		dash.dash_time_left = dash.dash_duration
		dash.cooldown_time_left = dash.cooldown
		
		# Record where we started so the friction wake can calculate the distance traveled
		var p_trans = entity_manager.transform_components.get(player_id)
		if p_trans:
			dash.start_position = p_trans.position
		
		# Drop to 10% speed
		SceneInstances.time_scale = 0.1 
		SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.SCREEN_SHAKE, "amount": 0.4})
