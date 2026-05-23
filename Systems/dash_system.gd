extends Node
class_name DashSystem

func update(delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1: return
	
	var dash = entity_manager.dash_components.get(player_id)
	var input = entity_manager.player_input_data
	var parry = entity_manager.parry_components.get(player_id)
	
	# We no longer need the velocity component here because we aren't locking it!
	if not dash or not input or not parry: return
	
	# Process the Cooldown
	if dash.cooldown_time_left > 0:
		dash.cooldown_time_left -= delta
		
	# Process an Active Speedster State
	if dash.is_dashing:
		dash.dash_time_left -= delta # Uses pure real-time delta!
		
		if dash.dash_time_left <= 0:
			# Speedster mode finished!
			dash.is_dashing = false
			
			# 1. THAW THE UNIVERSE
			SceneInstances.time_scale = 1.0 
			
			# 2. Friction Wake (Calculates the straight line between where you started the freeze and where you ended up)
			var transform_data = entity_manager.transform_components.get(player_id)
			if transform_data and dash.get("friction_wake_radius") != null and dash.friction_wake_radius > 0.0:
				var all_enemies = entity_manager.is_an_enemy.keys()
				var dash_start = dash.start_position
				var dash_end = transform_data.position
				
				for e_id in all_enemies:
					var e_transform = entity_manager.transform_components.get(e_id)
					var e_vel = entity_manager.velocity_components.get(e_id)
					if not e_transform or not e_vel: continue
					
					var closest_point = Geometry2D.get_closest_point_to_segment(e_transform.position, dash_start, dash_end)
					var distance = e_transform.position.distance_to(closest_point)
					
					if distance <= dash.friction_wake_radius:
						e_vel.speed *= (1.0 - dash.friction_wake_slow_percent)
						
						var e_render = entity_manager.render_components.get(e_id)
						if e_render: e_render.modulate = Color(0.2, 0.5, 1.0)
			
		# NOTICE: No velocity locks here! You retain 100% full movement control.
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
		
		# ENGAGE THE MATRIX: Drop the universe to 10% speed!
		SceneInstances.time_scale = 0.1 
		SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.SCREEN_SHAKE, "amount": 0.4})
