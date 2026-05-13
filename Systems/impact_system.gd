extends Node
class_name ImpactSystem

func update(_delta: float) -> void:
	var entity_manager = SceneInstances.entity_manager
	var player_id = entity_manager.player_id
	
	if player_id == -1: return
	
	var player_transform = entity_manager.transform_components.get(player_id)
	var player_parry = entity_manager.parry_components.get(player_id)
	var player_health = entity_manager.health_components.get(player_id)
	
	if not player_transform or not player_parry or not player_health: return
	
	# Loop through ONLY the bullets
	for bullet_id in entity_manager.is_a_bullet.keys():
		var bullet_transform = entity_manager.transform_components.get(bullet_id)
		var alignment = entity_manager.alignment_components.get(bullet_id)
	
		if not bullet_transform or not alignment: continue
		
		# We only check ENEMY bullets against the PLAYER
		if alignment.alignment == Enums.ALIGNMENTS.PLAYER:
			# fast distance check
			if player_transform.position.distance_to(bullet_transform.position) <= Constants.PARRY_RADIUS:
				# --- COLLISION DETECTED ---
				if player_parry.current_state == ParryData.State.PARRYING:
					# 1. THE CATCH IS SUCCESSFUL
					SceneInstances.time_scale = 0.1 # DEAD STOP EVERYTHING
					player_parry.current_state = ParryData.State.FROZEN_AIMING
					player_parry.hijacked_bullet_id = bullet_id
					
					# Snap the bullet perfectly to the player's center for visual feedback
					bullet_transform.position = player_transform.position
					var bullet_velocity_data = SceneInstances.entity_manager.velocity_components.get(bullet_id)
					if bullet_velocity_data:
						bullet_velocity_data.speed = 0.0
					
					print("CATCH SUCCESSFUL! TIME FROZEN!")
					break # Break out because we only want to catch ONE bullet per frame
					
				elif player_parry.current_state != ParryData.State.FROZEN_AIMING:
					# 2. THE WHIFF (Player takes a hit)
					player_health.health -= 1
					print("PLAYER HIT! HP: ", player_health.health)
					
					# Destroy the bullet that hit us
					Factories.despawn_bullet(bullet_id)
					break
