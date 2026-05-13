extends Node

func update(_delta: float) -> void:
	for event in SceneInstances.events_manager.events:
		if event["type"] == Enums.EVENT_TYPES.SHOOT_TARGET:
			var target_transform_data: TransformData = SceneInstances.entity_manager.transform_components[event["target"]]
			var parent_transform_data: TransformData = SceneInstances.entity_manager.transform_components[event["id"]]
			
			var direction = (target_transform_data.position - parent_transform_data.position).normalized()
			Factories.spawn_bullet(parent_transform_data.position, direction, event["damage"], event["target"], 300.0)
