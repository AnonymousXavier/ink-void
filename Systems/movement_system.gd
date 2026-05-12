extends Node


func _process(delta: float) -> void:
	# Safely duplicate keys so we can erase from the original dictionary while looping
	var entity_manager = SceneInstances.entity_manager

	for entity_id in entity_manager.velocity_components.keys():
		var transform_data = SceneInstances.entity_manager.transform_components.get(entity_id)
		var velocity_data = SceneInstances.entity_manager.velocity_components.get(entity_id)
		
		if not transform_data:
			continue
		
		var prev_position = transform_data.position
		transform_data.position = transform_data.position.move_toward(velocity_data.target, delta * velocity_data.speed)
		entity_manager.update_chunk_map_for(prev_position, entity_id)
		
		if transform_data.position == velocity_data.target:
			# 1. Stop moving
			SceneInstances.entity_manager.velocity_components.erase(entity_id)
			# 2. Blindly announce arrival
			SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.TARGET_REACHED, "id": entity_id})
		
