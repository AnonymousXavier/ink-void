extends Node
class_name ProjectileDispatchSystem

func update(_delta: float) -> void:
	for event in SceneInstances.events_manager.events:
		if event["type"] == Enums.EVENT_TYPES.SHOOT_TARGET:
			var target_transform = SceneInstances.entity_manager.transform_components[event["target"]]
			var parent_transform = SceneInstances.entity_manager.transform_components[event["id"]]
			
			var direction = (target_transform.position - parent_transform.position).normalized()
			
			# Extract the parent's base render color to give to the bullet!
			var parent_render = SceneInstances.entity_manager.render_components.get(event["id"])
			var bullet_color = parent_render.modulate if parent_render else Color("ff0033")
			
			Factories.spawn_bullet(parent_transform.position, direction, event["damage"], event["target"], 300.0, bullet_color)
