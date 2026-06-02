extends Node
class_name InteractionSystem

func update() -> void:
	var em = SceneInstances.entity_manager
	var player_id = em.player_id
	if player_id == -1: return
	
	var p_transform = em.transform_components.get(player_id)
	var input = em.player_input_data
	if not p_transform or not input: return
	
	for interactable_id in em.interactable_components.keys():
		var i_transform = em.transform_components.get(interactable_id)
		var i_data: InteractableData = em.interactable_components.get(interactable_id)
		
		# Grab the render data to apply the visual feedback!
		var i_render = em.render_components.get(interactable_id)
		
		if not i_transform or not i_data: continue
		
		# Check distance
		var distance = p_transform.position.distance_to(i_transform.position)
		i_data.is_player_in_range = (distance <= i_data.interaction_radius)
		
		if i_render:
			if i_data.is_player_in_range:
				# Swell up and glow intensely
				i_render.rendering_scale = Vector2(1.2, 1.2)
				i_render.modulate = i_data.hover_color
			else:
				# Return to normal
				i_render.rendering_scale = Vector2.ONE
				i_render.modulate = i_data.base_color
		
		# If in range and player clicks/presses action button
		if i_data.is_player_in_range and input.parry_pressed:
			# Freeze the player so they don't slide around while the shop is open
			var p_vel = em.velocity_components.get(player_id)
			if p_vel: p_vel.direction = Vector2.ZERO
			
			# Tell the UI Manager to open this specific menu!
			SceneInstances.events_manager.add_event({
				"type": i_data.event_to_fire,
				"terminal_id": interactable_id
			})
			
			# Consume the input so we don't spam the event
			input.parry_pressed = false
