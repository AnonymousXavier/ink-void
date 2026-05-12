extends Node
class_name ShootingSystem

func _process(_delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var transform_components = entity_manager.transform_components
	var weapon_components = entity_manager.projectile_weopon_components
	var countdown_components = entity_manager.countdown_components
	var cluster_hash = entity_manager.cluster_hash
	
	for entity_id in weapon_components: # Get the shooters
		var weapon_data: ProjectileWeaponData = weapon_components[entity_id]
		var transform_data: TransformData = transform_components[entity_id]
		var countdowndata: CountDownData = countdown_components[entity_id]
		
		var min_x = floori((transform_data.position.x - weapon_data.attack_range) / Constants.CHUNK_SIZE)
		var max_x = floori((transform_data.position.x + weapon_data.attack_range) / Constants.CHUNK_SIZE)
		var min_y = floori((transform_data.position.y - weapon_data.attack_range) / Constants.CHUNK_SIZE)
		var max_y = floori((transform_data.position.y + weapon_data.attack_range) / Constants.CHUNK_SIZE)
		
		# Get closest entity and shoot them
		var closest_enemy_distance = INF
		var closest_enemy_id: int = -1
		
		for x in range(min_x, max_x + 1):
			for y in range(min_y, max_y + 1):
				var chunk_pos = Vector2i(x, y)
				if chunk_pos not in cluster_hash:
					continue
					
				# Loop through this chunk's enemies
				for target_id in cluster_hash[chunk_pos]:
					# 1. Self Check
					if target_id == entity_id:
						continue
					
					# 2. Identity Check
					if not entity_manager.alignment_components.has(target_id):
						continue
					
					var target_alignment_data: AlignmentData = entity_manager.alignment_components[target_id]
					# 3. Allegiance Check
					if target_alignment_data.alignment not in weapon_data.target_alignments:
						continue
		
					# 4. Distance Math
					var target_transform_data = transform_components[target_id]
					var distance = transform_data.position.distance_squared_to(target_transform_data.position)
					var max_range_squared = weapon_data.attack_range * weapon_data.attack_range

					# ONLY target them if they are physically inside the range circle
					if distance <= max_range_squared:
						if distance < closest_enemy_distance:
							closest_enemy_distance = distance
							closest_enemy_id = target_id
						
		if closest_enemy_id != -1: # We found an enemy
			if not countdowndata.started: # If we can shoot
				# Queue that enemy to be shot
				var shoot_event = {"type": Enums.EVENT_TYPES.SHOOT_TARGET, "id": entity_id, "target": closest_enemy_id, "damage": weapon_data.damage}
				
				SceneInstances.events_manager.add_event(shoot_event)
				CountDownSystem.start_countdown_for(countdowndata)
			
