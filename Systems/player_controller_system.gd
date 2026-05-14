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
		velocity.direction = Vector2.ZERO # Lock movement
		
		# 1. Poll the absolute world position we already calculated!
		var mouse_pos = input.aim_position
		
		if input.fire_pressed and parry.hijacked_bullet_id != -1:
			var bullet_id = parry.hijacked_bullet_id
			var bullet_vel = entity_manager.velocity_components.get(bullet_id)
			var bullet_align = entity_manager.alignment_components.get(bullet_id)
			var p_transform = entity_manager.transform_components.get(player_id)
			
			if bullet_vel and bullet_align and p_transform:
				
				# 2. Calculate the exact vector from your core to the mouse
				var aim_dir = p_transform.position.direction_to(mouse_pos)
				
				# 3. Apply the hyper-speed return fire
				bullet_vel.direction = aim_dir
				bullet_vel.speed = 1200.0
				
				# 4. THE CRITICAL FIX: Flip the target so it attacks enemies!
				bullet_align.alignment = Enums.ALIGNMENTS.ENEMY
				
				# 5. Restore the engine state
				SceneInstances.time_scale = 1.0
				parry.current_state = ParryData.State.READY
				parry.hijacked_bullet_id = -1
				
				print("BULLET RELEASED AT MOUSE!")
				# Kick the screen with 80% maximum trauma to sell the 1200 speed!
				SceneInstances.events_manager.add_event({"type": Enums.EVENT_TYPES.SCREEN_SHAKE, "amount": 0.8})
