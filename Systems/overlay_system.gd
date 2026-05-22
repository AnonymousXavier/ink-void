extends Node
class_name OverlaySystem

func update(_delta: float) -> void:
	for event in SceneInstances.events_manager.events:
		if event["type"] == Enums.EVENT_TYPES.MOUSE_MOTION and Cache.is_ready :
			var transform_data = SceneInstances.entity_manager.transform_components[SceneInstances.entity_manager.cell_overlay_id]
			transform_data.position = Misc.convert_screen_pos_to_world_pos(event["position"])
