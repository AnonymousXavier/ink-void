extends Node
class_name MovementSystem

func update(delta: float) -> void:
	var scaled_delta = delta * SceneInstances.time_scale
	
	var entity_manager = SceneInstances.entity_manager
	var screen_rect = get_viewport().get_visible_rect()
	
	screen_rect.size = screen_rect.size / SceneInstances.camera.zoom
	screen_rect.position = SceneInstances.camera._top_left
	
	for id in entity_manager.velocity_components:
		var transform = entity_manager.transform_components.get(id)
		var velocity = entity_manager.velocity_components.get(id)
		
		if velocity and velocity.direction != Vector2.ZERO:
			var old_pos = transform.position
			
			# Apply the continuous action vector!
			transform.position += velocity.direction * velocity.speed * scaled_delta
			
			# Update your highly optimized spatial hash
			entity_manager.update_chunk_map_for(old_pos, id)
			
			# Bullets, well delete them once theyre offscreen
			if entity_manager.is_a_bullet.has(id):
				if not screen_rect.has_point(transform.position):
					Factories.despawn_bullet(id)
