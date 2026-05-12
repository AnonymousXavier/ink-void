extends Node

func _process(_delta: float) -> void:
	for event in SceneInstances.events_manager.events:
		if event["type"] == Enums.EVENT_TYPES.SHOOT_TARGET:
			var target_transform_data: TransformData = SceneInstances.entity_manager.transform_components[event["target"]]
			var parent_transform_data: TransformData = SceneInstances.entity_manager.transform_components[event["id"]]
			
			Factories.spawn_bullet(parent_transform_data.position, target_transform_data.position, event["damage"], event["target"], 1000.0)
