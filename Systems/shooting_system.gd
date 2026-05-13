extends Node
class_name ShootingSystem

func update(_delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1 or not entity_manager.active_entities.has(player_id):
		return
		
	var player_transform = entity_manager.transform_components.get(player_id)
	if not player_transform:
		return

	var weapon_components = entity_manager.projectile_weopon_components
	var countdown_components = entity_manager.countdown_components
	var transform_components = entity_manager.transform_components
	
	# Loop through ONLY the entities that have guns
	for entity_id in weapon_components:
		var weapon_data: ProjectileWeaponData = weapon_components[entity_id]
		var transform_data: TransformData = transform_components.get(entity_id)
		var countdown_data: CountDownData = countdown_components.get(entity_id)
		
		if not transform_data or not countdown_data:
			continue
			
		# Pure, direct distance check. No chunk mapping required!
		var distance_squared = transform_data.position.distance_squared_to(player_transform.position)
		var max_range_squared = weapon_data.attack_range * weapon_data.attack_range
		
		if distance_squared <= max_range_squared:
			if not countdown_data.started:
				# Trigger the shot directly at the player
				var shoot_event = {
					"type": Enums.EVENT_TYPES.SHOOT_TARGET, 
					"id": entity_id, 
					"target": player_id, 
					"damage": weapon_data.damage
				}
				SceneInstances.events_manager.add_event(shoot_event)
				CountDownSystem.start_countdown_for(countdown_data)
