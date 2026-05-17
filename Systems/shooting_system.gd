extends Node
class_name ShootingSystem

func update(delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1 or not entity_manager.active_entities.has(player_id): return
		
	var player_transform = entity_manager.transform_components.get(player_id)
	if not player_transform: return

	var weapon_components = entity_manager.projectile_weopon_components
	var countdown_components = entity_manager.countdown_components
	var transform_components = entity_manager.transform_components
	
	var max_simultaneous_shots: int = 3 # THE SWARM THRESHOLD
	var current_aiming_count: int = 0
	
	# PASS 1: Process active aimers and count tokens
	for entity_id in weapon_components:
		var weapon_data: ProjectileWeaponData = weapon_components[entity_id]
		
		if weapon_data.is_aiming:
			current_aiming_count += 1
			weapon_data.aim_timer -= delta
			
			if weapon_data.aim_timer <= 0.0:
				# 1. Fire the bullet!
				var shoot_event = {
					"type": Enums.EVENT_TYPES.SHOOT_TARGET, 
					"id": entity_id, 
					"target": player_id, 
					"damage": weapon_data.damage
				}
				SceneInstances.events_manager.add_event(shoot_event)
				
				# 2. Release the token and go on global cooldown
				weapon_data.is_aiming = false
				current_aiming_count -= 1
				var cd_data = countdown_components.get(entity_id)
				if cd_data: CountDownSystem.start_countdown_for(cd_data)

	# PASS 2: Check for newly provoked enemies
	for entity_id in weapon_components:
		var weapon_data: ProjectileWeaponData = weapon_components[entity_id]
		var transform_data: TransformData = transform_components.get(entity_id)
		var countdown_data: CountDownData = countdown_components.get(entity_id)
		
		if not transform_data or not countdown_data: continue
		
		# If they aren't aiming, and aren't on cooldown, check the trap!
		if not weapon_data.is_aiming and not countdown_data.started:
			var distance_sq = transform_data.position.distance_squared_to(player_transform.position)
			var max_range_sq = weapon_data.attack_range * weapon_data.attack_range
			
			if distance_sq <= max_range_sq:
				# They are in the trap! Can they grab a token?
				if current_aiming_count < max_simultaneous_shots:
					weapon_data.is_aiming = true
					weapon_data.aim_timer = weapon_data.aim_duration
					current_aiming_count += 1
