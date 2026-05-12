extends Node
class_name HomingSystem

func _process(_delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	# Loop through every bullet that has a homing component
	for bullet_id in entity_manager.homing_components.keys():
		var homing_data: HomingData = entity_manager.homing_components[bullet_id]
		var target_id = homing_data.target_id
		
		if not entity_manager.transform_components.has(target_id):
			entity_manager.homing_components.erase(bullet_id)
			continue
			
		# If the target is still alive, fetch its exact current position and inject it into the bullet's VelocityData
		var veleocityData: VelocityData = entity_manager.velocity_components.get(bullet_id)
		var transformData: TransformData = entity_manager.transform_components.get(target_id)
		
		if veleocityData and transformData:
			veleocityData.target = transformData.position
