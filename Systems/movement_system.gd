extends Node
class_name MovementSystem

func update(delta: float) -> void:
	var scaled_delta = delta * SceneInstances.time_scale
	
	var entity_manager = SceneInstances.entity_manager
	var screen_rect = SceneInstances.viewport.get_visible_rect()
	
	screen_rect.size = screen_rect.size / SceneInstances.camera.zoom
	screen_rect.position = SceneInstances.camera._top_left
	
	for id in entity_manager.velocity_components:
		var transform = entity_manager.transform_components.get(id)
		var velocity = entity_manager.velocity_components.get(id)
		var dash = entity_manager.dash_components.get(id) # Fetch dash data if it exists
		
		if not transform or not velocity: continue
			
		# If this entity is dashing, they use raw unscaled delta (immune to time stops!)
		# Otherwise, they are a slave to the global time scale.
		var active_delta = delta
		if dash and dash.is_dashing:
			active_delta = delta # Pure real-time speed
		else:
			active_delta = scaled_delta # Molasses speed
			
		var old_pos = transform.position
		
		# Process normal intentional directional movement using the calculated delta
		var movement_displacement = velocity.direction * velocity.speed * active_delta
		
		# Process external impact forces (Tanks parry recoil pushback)
		var knockback_displacement = Vector2.ZERO
		if "knockback_vector" in velocity and velocity.knockback_vector != Vector2.ZERO:
			# Apply recoil velocity over the frame step
			knockback_displacement = velocity.knockback_vector * scaled_delta
			
			# Friction/Decay curve: Dampen the force smoothly toward zero using unscaled delta.
			# This ensures your sliding feel remains completely consistent even if time slows down!
			velocity.knockback_vector = velocity.knockback_vector.lerp(Vector2.ZERO, delta * 12.0)
			if velocity.knockback_vector.length_squared() < 1.0:
				velocity.knockback_vector = Vector2.ZERO
		
		# Combine both vectors to calculate final spatial position
		transform.position += movement_displacement + knockback_displacement
		
		# Update your highly optimized spatial hash chunking maps if anything actually moved
		if transform.position != old_pos:
			entity_manager.update_chunk_map_for(old_pos, id)
		
		# Bullets safety cleanup boundaries pass
		if entity_manager.is_a_bullet.has(id):
			if not screen_rect.has_point(transform.position):
				despawn_bullet(id, transform)
				
func despawn_bullet(bullet_id, transform_data: TransformData):
	# 1. Fetch the bullet's exact color
	var render_data = SceneInstances.entity_manager.render_components.get(bullet_id)
	var bullet_color = render_data.modulate if render_data else Color(0.8, 0.8, 0.8)
	
	var impact_coordinate = Vector2(transform_data.position.x, transform_data.position.y)
	
	SceneInstances.events_manager.add_event({
		"type": Enums.EVENT_TYPES.SPAWN_IMPACT_PARTICLE, 
		"pos": impact_coordinate,
		"color": bullet_color 
	})

	Factories.despawn_bullet(bullet_id)
