extends Node
class_name ProjectileDispatchSystem

func update(_delta: float) -> void:
	for event in SceneInstances.events_manager.events:
		if event["type"] == Enums.EVENT_TYPES.SHOOT_TARGET:
			var target_transform = SceneInstances.entity_manager.transform_components[event["target"]]
			var parent_transform = SceneInstances.entity_manager.transform_components[event["id"]]
			
			var bullet_speed = 300.0 # This should match the speed you pass to spawn_bullet
			var direction = Vector2.ZERO
			
			# Fetch the target's velocity to see how fast they are moving
			var target_velocity = SceneInstances.entity_manager.velocity_components.get(event["target"])
			
			if target_velocity and target_velocity.direction != Vector2.ZERO:
				# Calculate base naive time
				var distance = parent_transform.position.distance_to(target_transform.position)
				var travel_time = distance / bullet_speed
				
				# Calculate the raw projected vector
				var projected_movement = target_velocity.direction * target_velocity.speed * travel_time
				
				# THE FIX: Clamp the prediction length. 
				# The AI is never allowed to predict a movement larger than 75% of the total distance between you.
				# This guarantees the target point can never "cross behind" the sniper.
				var max_prediction = distance * 0.75
				if projected_movement.length() > max_prediction:
					projected_movement = projected_movement.normalized() * max_prediction
				
				var future_position = target_transform.position + projected_movement
				direction = (future_position - parent_transform.position).normalized()
			else:
				# If the player is standing completely still, just shoot straight at them
				direction = (target_transform.position - parent_transform.position).normalized()

			var parent_render = SceneInstances.entity_manager.render_components.get(event["id"])
			var bullet_color = parent_render.modulate if parent_render else Color("ff0033")
			
			Factories.spawn_bullet(parent_transform.position, direction, event["damage"], event["target"], bullet_speed, bullet_color)
			SceneInstances.audio_system.play_sound("shoot")
