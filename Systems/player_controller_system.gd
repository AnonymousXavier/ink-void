extends Node
class_name PlayerControllerSystem

func update(_delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1: return
		
	var input = entity_manager.player_input_data
	var velocity = entity_manager.velocity_components.get(player_id)
	var parry = entity_manager.parry_components.get(player_id)
	
	if not input or not velocity or not parry: return
	
	# 1. MOVEMENT STATES
	if parry.current_state == ParryData.State.READY:
		velocity.direction = input.direction
		
	elif parry.current_state == ParryData.State.PARRYING:
		velocity.direction = input.direction * 0.5 # Slowed during active frames
		
	elif parry.current_state == ParryData.State.RECOVERING:
		velocity.direction = Vector2.ZERO # Locked!
		
	# 2. TIME FREEZE & RELEASE STATE
	elif parry.current_state == ParryData.State.FROZEN_AIMING:
		velocity.direction = Vector2.ZERO # Locked!
		
		if input.fire_pressed and parry.hijacked_bullet_id != -1:
			var bullet_id = parry.hijacked_bullet_id
			var bullet_vel = entity_manager.velocity_components.get(bullet_id)
			var bullet_align = entity_manager.alignment_components.get(bullet_id)
			var p_transform = entity_manager.transform_components.get(player_id)
			
			if bullet_vel and bullet_align and p_transform:
				var aim_dir = (input.aim_position - p_transform.position).normalized()
				
				bullet_vel.direction = aim_dir
				bullet_vel.speed = 1200.0 # High-speed return fire
				bullet_align.alignment = Enums.ALIGNMENTS.PLAYER
				
				# Restore time and state
				SceneInstances.time_scale = 1.0
				parry.current_state = ParryData.State.READY
				parry.hijacked_bullet_id = -1
				print("BULLET RELEASED!")
