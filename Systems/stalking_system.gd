extends Node
class_name StalkingSystem

func update(delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1: return
		
	var player_transform = entity_manager.transform_components.get(player_id)
	if not player_transform: return

	# Notice we loop through ALL enemies now, not just stalkers!
	for entity_id in entity_manager.is_an_enemy.keys():
		var transform_data: TransformData = entity_manager.transform_components.get(entity_id)
		var velocity_data: VelocityData = entity_manager.velocity_components.get(entity_id)
		var ai_data: AIData = entity_manager.ai_components.get(entity_id)
		
		if not transform_data or not velocity_data or not ai_data: continue
		
		var vector_to_player = player_transform.position - transform_data.position
		var distance_to_player = vector_to_player.length()
		var direction_to_player = vector_to_player.normalized()
		
		# Calculate Separation 
		var separation_vector = Vector2.ZERO
		var neighbor_count = 0
		var personal_space = 70.0 # How far they push away from each other
		
		# We loop through enemies to see who is standing too close
		for other_id in entity_manager.is_an_enemy.keys():
			if other_id == entity_id: continue
			
			var other_trans = entity_manager.transform_components.get(other_id)
			if not other_trans: continue
			
			var dist_to_ally = transform_data.position.distance_to(other_trans.position)
			if dist_to_ally < personal_space and dist_to_ally > 0:
				# The closer they are, the harder they push away (inverse scaling)
				var push_force = (personal_space - dist_to_ally) / personal_space
				separation_vector += (transform_data.position - other_trans.position).normalized() * push_force
				neighbor_count += 1
				
		if neighbor_count > 0:
			separation_vector /= neighbor_count
			
		# State Machine Evaluation
		var target_direction = Vector2.ZERO
		var weapon_data = entity_manager.projectile_weopon_components.get(entity_id)

		# If they have a weapon that can shoot further than a standard melee lunge (e.g., 150px)
		if weapon_data and weapon_data.attack_range > 150.0:
			# SNIPER / RANGED LOGIC
			var optimal_distance = weapon_data.attack_range * 0.75
			var retreat_threshold = weapon_data.attack_range * 0.40
			
			if distance_to_player < retreat_threshold:
				ai_data.current_state = AIData.State.RETREATING
				target_direction = -direction_to_player
			elif distance_to_player > optimal_distance:
				ai_data.current_state = AIData.State.CHASING
				target_direction = direction_to_player
			else:
				ai_data.current_state = AIData.State.STRAFING
				target_direction = Vector2(-direction_to_player.y, direction_to_player.x)
		else:
			# MELEE LOGIC (Tanks and Grunts)
			ai_data.current_state = AIData.State.CHASING
			target_direction = direction_to_player
			
		# Combine Forces
		# Blend the desire to attack the player with the claustrophobic need to avoid allies
		var final_direction = target_direction + (separation_vector * ai_data.separation_weight)
		
		# Use lerp to give them momentum, making them turn smoothly rather than snapping instantly
		velocity_data.direction = velocity_data.direction.lerp(final_direction.normalized(), delta * 6.0).normalized()
