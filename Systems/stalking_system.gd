extends Node
class_name StalkingSystem

func update(delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1: return
		
	var player_transform = entity_manager.transform_components.get(player_id)
	if not player_transform: return

	var stalker_components = entity_manager.stalker_components
	var transform_components = entity_manager.transform_components
	var velocity_components = entity_manager.velocity_components
	
	for entity_id in stalker_components:
		var transform_data: TransformData = transform_components.get(entity_id)
		var velocity_data: VelocityData = velocity_components.get(entity_id)
		
		if not transform_data or not velocity_data: continue
		
		# Calculate base vector relative to the player target
		var vector_to_player = player_transform.position - transform_data.position
		var distance = vector_to_player.length()
		var direction_to_player = vector_to_player.normalized()
		
		# Extract weapon attributes to determine safety zones
		var weapon_data = entity_manager.projectile_weopon_components.get(entity_id)

		# THE SNIPER 
		if weapon_data and weapon_data.attack_range > Constants.CHUNK_SIZE * 0.6:
			# Define target combat distance (75% of max firing range)
			var optimal_distance = weapon_data.attack_range * 0.75
			var retreat_threshold = weapon_data.attack_range * 0.40
			
			if distance < retreat_threshold:
				# Player is too close! Back away to maintain advantage
				velocity_data.direction = -direction_to_player
			elif distance > optimal_distance:
				# Too far away to acquire a solid target lock, advance slightly
				velocity_data.direction = direction_to_player
			else:
				# Cross product provides a perpendicular vector for clean strafing
				var strafe_direction = Vector2(-direction_to_player.y, direction_to_player.x)
				velocity_data.direction = strafe_direction * 0.4 # Slow orbit
				
		# THE TANK SQUARE
		elif velocity_data.speed < 50.0: 
			# Tanks track completely relentlessly, ignoring minor player micro-movements
			# We can blend their tracking path slowly over frames to make them feel heavy
			velocity_data.direction = velocity_data.direction.lerp(direction_to_player, delta * 2.0).normalized()
			
		# THE NORMAL ENEMY
		else:
			# Baseline charging behavior
			velocity_data.direction = direction_to_player
