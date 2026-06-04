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
	
	# 1. PROCESS ACTIVE DASH FIRST
	if dash.is_dashing:
		dash.dash_time_left -= delta # Uses real-time delta!
		
		if dash.dash_time_left <= 0:
			dash.is_dashing = false
			dash.cooldown_time_left = dash.cooldown 
			
			# CHRONO-CLASH FIX: Only end Quicksilver if a HitStop isn't currently freezing the game!
			if SceneInstances.time_scale != 0.0:
				SceneInstances.time_scale = 1.0 
		return 
		
	# 2. PROCESS COOLDOWN
	if dash.cooldown_time_left > 0:
		dash.cooldown_time_left -= delta
		
	# 3. START DASH
	if input.dash_pressed and dash.cooldown_time_left <= 0 and parry.current_state != ParryData.State.PARRYING:
		dash.is_dashing = true
		SceneInstances.audio_system.play_sound("dash")
		dash.dash_time_left = dash.dash_duration
		
		var p_trans = entity_manager.transform_components.get(player_id)
		if p_trans:
			dash.start_position = p_trans.position
		
		SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.SCREEN_SHAKE, "amount": 0.4})
		
		# CHRONO-CLASH FIX: Don't accidentally speed the game up to 0.1 if a HitStop is currently at 0.0
		if SceneInstances.time_scale != 0.0:
			SceneInstances.time_scale = 0.1
