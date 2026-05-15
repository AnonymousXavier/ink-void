extends Node
class_name ShockwaveSystem

func update(delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var dead_shockwaves: Array = []
	
	for wave_id in entity_manager.shockwave_components.keys():
		var wave_data = entity_manager.shockwave_components[wave_id]
		var wave_transform = entity_manager.transform_components[wave_id]
		
		# Expand the circle
		wave_data.radius += wave_data.speed * delta
		
		# Vaporize enemies caught in the blast
		for enemy_id in entity_manager.is_an_enemy.keys():
			var enemy_transform = entity_manager.transform_components.get(enemy_id)
			if enemy_transform:
				var dist = wave_transform.position.distance_to(enemy_transform.position)
				if dist <= wave_data.radius:
					# Fire the kill event so the Graveyard stamps their blood!
					SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.ENTITY_KILLED, "id": enemy_id})
		
		# If it covers the whole screen, delete it and trigger the UI
		if wave_data.radius >= wave_data.max_radius:
			dead_shockwaves.append(wave_id)
			print("WAVE COMPLETE! SHOW ROGUELIKE UI!")
			# SceneInstances.ui_manager.show_cards()
			
	for id in dead_shockwaves:
		entity_manager.shockwave_components.erase(id)
		entity_manager.transform_components.erase(id)
		entity_manager.active_entities.erase(id)
