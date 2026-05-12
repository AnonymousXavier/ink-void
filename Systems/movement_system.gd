extends Node
class_name MovementSystem

func _physics_process(delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	
	# Optional: Get screen bounds to clean up bullets as you suggested!
	var screen_rect = get_viewport().get_visible_rect()
	# If your camera moves, you'll want to pad this rect or use the camera's position
	
	for id in entity_manager.velocity_components:
		var transform = entity_manager.transform_components.get(id)
		var velocity = entity_manager.velocity_components.get(id)
		
		if velocity and velocity.direction != Vector2.ZERO:
			var old_pos = transform.position
			
			# Apply the continuous action vector!
			transform.position += velocity.direction.normalized() * velocity.speed * delta
			
			# Update your highly optimized spatial hash
			entity_manager.update_chunk_map_for(old_pos, id)
			
			# Your exact logic: "Bullets, well delete them once theyre offscreen"
			if entity_manager.is_a_bullet.has(id):
				if not screen_rect.has_point(transform.position):
					Factories.despawn_bullet(id)
