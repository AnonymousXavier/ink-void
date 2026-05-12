extends Node
class_name StalkingSystem

func update():
	var entity_manager = SceneInstances.entity_manager
	var transform_components = entity_manager.transform_components
	var stalker_components = entity_manager.stalker_components
	var velocity_components = entity_manager.velocity_components
	
	for entity_id in stalker_components:
		var stalkerData: StalkerData = stalker_components[entity_id]
		var target_id = stalkerData.target_id
		
		if target_id not in transform_components:
			continue
		
		if entity_id not in transform_components or entity_id not in velocity_components:
			continue
			
		var target_transform_data: TransformData = transform_components[target_id]
		var entity_transform_data: TransformData = transform_components[entity_id]
		
		var velocity_data = velocity_components[entity_id]
		var direction = (target_transform_data.position - entity_transform_data.position).normalized()
		
		velocity_data.direction = direction
