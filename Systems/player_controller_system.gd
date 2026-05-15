extends Node
class_name PlayerControllerSystem

func update(_delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1: return
		
	var input = entity_manager.player_input_data
	var velocity = entity_manager.velocity_components.get(player_id)
	var parry = entity_manager.parry_components.get(player_id)
	var health = entity_manager.health_components.get(player_id)
	
	if not input or not velocity or not parry: return
	
	# THE DEATH OVERRIDE
	if health and health.health <= 0:
		velocity.direction = Vector2.ZERO # Stop sliding
		
		# Change texture to a dead/shattered version (if you have one)
		var render: RenderingData = entity_manager.render_components.get(player_id)
		if render:
			render.modulate = Color(0.2, 0.2, 0.2, 0.5) # Ghostly dark gray
			
		return # Completely lock out all player input and actions!
	
	# MOVEMENT STATES
	if parry.current_state == ParryData.State.READY:
		velocity.direction = input.direction
		
	elif parry.current_state == ParryData.State.PARRYING:
		velocity.direction = input.direction * 0.5 # Slowed during active frames
		
	elif parry.current_state == ParryData.State.RECOVERING:
		velocity.direction = Vector2.ZERO # Locked!
		
	# TIME FREEZE & RELEASE STATE
	elif parry.current_state == ParryData.State.FROZEN_AIMING:
		velocity.direction = Vector2.ZERO # Lock movement
		
		var mouse_pos = input.aim_position
		
		if input.fire_pressed and parry.hijacked_bullet_id != -1:
			var bullet_id = parry.hijacked_bullet_id
			var bullet_vel = entity_manager.velocity_components.get(bullet_id)
			var bullet_align = entity_manager.alignment_components.get(bullet_id)
			var p_transform = entity_manager.transform_components.get(player_id)
			
			if bullet_vel and bullet_align and p_transform:
				
				var aim_dir = p_transform.position.direction_to(mouse_pos)
				
				bullet_vel.direction = aim_dir
				bullet_vel.speed = 1200.0
				
				bullet_align.alignment = Enums.ALIGNMENTS.ENEMY
				
				# Restore the engine state
				SceneInstances.time_scale = 1.0
				parry.current_state = ParryData.State.READY
				parry.hijacked_bullet_id = -1

				SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.SCREEN_SHAKE, "amount": 0.8})
				
		var dash = entity_manager.dash_components.get(player_id)
	
		# Dash
		if not dash or not dash.is_dashing:
			if input.direction != Vector2.ZERO:
				velocity.direction = input.direction.normalized()
			else:
				velocity.direction = Vector2.ZERO
